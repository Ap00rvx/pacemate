import 'package:dio/dio.dart';
import 'package:pacemate/core/network/dio.dart';
import 'package:pacemate/features/activities/domain/entities/activity.dart'
    as ent;
import 'package:pacemate/features/tracking/domain/enums/activity_type.dart';
import 'package:pacemate/features/auth/data/datasources/auth_local_datasource.dart';

import '../domain/entities/leaderboard_models.dart';

class LeaderboardRemoteDataSource {
  final Dio _dio = DioNetworkClient().client;
  final AuthLocalDataSource _authLocal = AuthLocalDataSource();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _authLocal.getAccessToken();
    return token != null ? {'Authorization': 'Bearer $token'} : {};
  }

  LeaderboardUser _mapUser(dynamic u) {
    if (u is Map) {
      final id = (u['_id'] ?? u['id'] ?? '').toString();
      final name = (u['fullname'] ?? u['name'] ?? '').toString();
      final avatarRaw = u['avatar'];
      final avatar = avatarRaw is String && avatarRaw.isNotEmpty
          ? avatarRaw
          : '';
      return LeaderboardUser(id: id, name: name, avatarUrl: avatar);
    }
    return LeaderboardUser(id: u.toString(), name: '', avatarUrl: '');
  }

  ent.Activity _mapActivity(Map<String, dynamic> a) {
    // Reuse simplified fields from activities domain, keeping only required subset
    final user = a['userId'];
    final typeStr = (a['type'] as String?)?.toLowerCase() ?? 'running';
    final createdAtStr =
        (a['createdAt'] ?? a['date'] ?? DateTime.now().toIso8601String())
            .toString();

    // Fallback minimal mapping to avoid tight coupling
    return ent.Activity(
      id: (a['_id'] ?? a['id']).toString(),
      type: switch (typeStr) {
        'walking' => ActivityType.walking,
        'cycling' => ActivityType.cycling,
        _ => ActivityType.running,
      },
      duration: (a['duration'] is num) ? (a['duration'] as num).toInt() : 0,
      distance: (a['distance'] is num)
          ? (a['distance'] as num).toDouble()
          : 0.0,
      calories: (a['calories'] is num) ? (a['calories'] as num).toInt() : 0,
      userId: (user is Map ? (user['_id'] ?? user['id'] ?? '') : user)
          .toString(),
      user: user is Map
          ? ent.ActivityUser(
              id: (user['_id'] ?? user['id'] ?? '').toString(),
              fullname: (user['fullname'] ?? user['name'] ?? '').toString(),
              avatar:
                  (user['avatar'] is String &&
                      (user['avatar'] as String).isNotEmpty)
                  ? (user['avatar'] as String)
                  : null,
              bmi: (user['bmi'] is num)
                  ? (user['bmi'] as num).toDouble()
                  : null,
            )
          : null,
      route: const [],
      createdAt: DateTime.tryParse(createdAtStr) ?? DateTime.now(),
      elevation: (a['elevation'] is num)
          ? (a['elevation'] as num).toDouble()
          : null,
      averagePace: (a['averagePace'] is num)
          ? (a['averagePace'] as num).toDouble()
          : null,
      feeling: a['feeling'] as String?,
      weather: a['weather'] as String?,
      image: a['image'] as String?,
      likes: const [],
    );
  }

  LeaderboardDistanceEntry _mapEntry(dynamic e) {
    if (e is Map) {
      final user = _mapUser(e['user'] ?? e['friend'] ?? e['userId']);
      // distance may be in meters or km; we assume km if value < 10000, else convert m->km
      double distance = 0.0;
      final val = e['distance'] ?? e['value'];
      if (val is num) distance = val.toDouble();
      if (distance > 10000) distance = distance / 1000.0;
      final rank = (e['rank'] is num) ? (e['rank'] as num).toInt() : null;
      return LeaderboardDistanceEntry(
        user: user,
        distanceKm: distance,
        rank: rank,
      );
    }
    return LeaderboardDistanceEntry(
      user: LeaderboardUser(id: '', name: '', avatarUrl: ''),
      distanceKm: 0.0,
    );
  }

  Future<LeaderboardData> fetchLeaderboard({
    String period = 'week',
    int leaderboardLimit = 10,
    int activitiesLimit = 10,
  }) async {
    final headers = await _authHeaders();
    final resp = await _dio.get(
      '/api/activities/leaderboard',
      queryParameters: {
        'period': period,
        'leaderboardLimit': leaderboardLimit,
        'activitiesLimit': activitiesLimit,
      },
      options: Options(headers: headers.isEmpty ? null : headers),
    );
    final data = resp.data['data'] as Map<String, dynamic>? ?? {};

    final friendsLb =
        (data['friendsLeaderboard'] as List?)?.map(_mapEntry).toList() ??
        <LeaderboardDistanceEntry>[];
    final globalLb =
        (data['globalLeaderboard'] as List?)?.map(_mapEntry).toList() ??
        <LeaderboardDistanceEntry>[];
    final myRecent = ((data['myRecentActivities'] as List?) ?? const [])
        .whereType<Map>()
        .map((e) => _mapActivity(Map<String, dynamic>.from(e)))
        .toList();
    final friendsRecent =
        ((data['friendsRecentActivities'] as List?) ?? const [])
            .whereType<Map>()
            .map((e) => _mapActivity(Map<String, dynamic>.from(e)))
            .toList();
    final myRank = (data['myGlobalRankDistance'] is num)
        ? (data['myGlobalRankDistance'] as num).toInt()
        : null;

    return LeaderboardData(
      period: (data['period'] ?? period).toString(),
      friendsLeaderboard: friendsLb,
      globalLeaderboard: globalLb,
      myRecentActivities: myRecent,
      friendsRecentActivities: friendsRecent,
      myGlobalRankDistance: myRank,
    );
  }
}
