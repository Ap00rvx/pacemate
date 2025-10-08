import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import 'package:pacemate/core/network/dio.dart';
import 'package:pacemate/features/activities/domain/entities/activity.dart'
    as ent;
import 'package:pacemate/features/tracking/domain/enums/activity_type.dart';
import 'package:pacemate/features/auth/data/datasources/auth_local_datasource.dart';

class ActivityRemoteDataSource {
  final Dio _dio = DioNetworkClient().client;
  final AuthLocalDataSource _authLocal = AuthLocalDataSource();

  Future<Map<String, dynamic>> _authHeaders() async {
    final token = await _authLocal.getAccessToken();
    return token != null ? {'Authorization': 'Bearer $token'} : {};
  }

  ent.Activity _mapActivity(Map<String, dynamic> a) {
    final user = a['userId'];
    final likes =
        (a['likes'] as List?)
            ?.map(
              (e) => e is Map
                  ? (e['_id'] ?? e['id'] ?? '') as String
                  : e.toString(),
            )
            .where((s) => s.isNotEmpty)
            .toList() ??
        [];
    final routeList =
        (a['route'] as List?)?.map((p) {
          final lat = (p['lat'] as num).toDouble();
          final lng = (p['lng'] as num).toDouble();
          return LatLng(lat, lng);
        }).toList() ??
        <LatLng>[];

    final typeStr = (a['type'] as String).toLowerCase();
    final type = switch (typeStr) {
      'running' => ActivityType.running,
      'walking' => ActivityType.walking,
      'cycling' => ActivityType.cycling,
      _ => ActivityType.running,
    };

    // Map optional expanded user details
    ent.ActivityUser? activityUser;
    if (user is Map) {
      final id = (user['_id'] ?? user['id'] ?? '').toString();
      final fullname = (user['fullname'] ?? '').toString();
      final avatarVal = user['avatar'];
      String? avatar;
      if (avatarVal is String && avatarVal.isNotEmpty) {
        avatar = avatarVal;
      } else {
        avatar = null;
      }
      double? bmi;
      if (user['bmi'] != null) {
        final v = user['bmi'];
        if (v is num) {
          bmi = v.toDouble();
        } else if (v is String) {
          final parsed = double.tryParse(v);
          bmi = parsed?.isNaN == true ? null : parsed;
        }
      }
      activityUser = ent.ActivityUser(
        id: id,
        fullname: fullname,
        avatar: avatar,
        bmi: bmi,
      );
    }

    return ent.Activity(
      id: (a['_id'] ?? a['id']).toString(),
      type: type,
      duration: (a['duration'] as num).toInt(),
      distance: (a['distance'] as num).toDouble(),
      calories: (a['calories'] as num).toInt(),
      userId: (user is Map ? (user['_id'] ?? user['id'] ?? '') : user)
          .toString(),
      user: activityUser,
      route: routeList,
      createdAt: DateTime.parse(a['createdAt'] as String),
      elevation: a['elevation'] == null
          ? null
          : (a['elevation'] as num).toDouble(),
      averagePace: a['averagePace'] == null
          ? null
          : (a['averagePace'] as num).toDouble(),
      feeling: a['feeling'] as String?,
      weather: a['weather'] as String?,
      image: a['image'] as String?,
      likes: likes,
    );
  }

  ent.ActivityStats _mapStats(Map<String, dynamic> s) => ent.ActivityStats(
    totalActivities: (s['totalActivities'] as num).toInt(),
    totalDistance: (s['totalDistance'] as num).toDouble(),
    totalDuration: (s['totalDuration'] as num).toInt(),
    totalCalories: (s['totalCalories'] as num).toInt(),
    averageDistance: (s['averageDistance'] as num).toDouble(),
    averageDuration: (s['averageDuration'] as num).toDouble(),
    averageCalories: (s['averageCalories'] as num).toDouble(),
  );

  ent.Pagination _mapPagination(Map<String, dynamic> p) => ent.Pagination(
    currentPage: (p['currentPage'] as num).toInt(),
    totalPages: (p['totalPages'] as num).toInt(),
    totalItems: (p['totalActivities'] as num).toInt(),
    hasNextPage: p['hasNextPage'] as bool,
    hasPrevPage: p['hasPrevPage'] as bool,
  );

  Future<({List<ent.Activity> activities, ent.Pagination pagination})>
  getActivities({
    int page = 1,
    int limit = 10,
    ActivityType? type,
    String? userId,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
    bool isPublic = true,
  }) async {
    final headers = await _authHeaders();
    final resp = await _dio.get(
      isPublic ? '/api/activities/public' : '/api/activities',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (type != null)
          'type': switch (type) {
            ActivityType.running => 'running',
            ActivityType.walking => 'walking',
            ActivityType.cycling => 'cycling',
          },
        if (userId != null) 'userId': userId,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      },
      options: Options(headers: headers.isEmpty ? null : headers),
    );
    final data = resp.data['data'];
    final list = (data['activities'] as List)
        .map((e) => _mapActivity(e))
        .toList();
    final pag = _mapPagination(data['pagination']);
    return (activities: list, pagination: pag);
  }

  Future<ent.Activity> getActivityById(
    String id, {
    bool isPublic = false,
  }) async {
    final headers = await _authHeaders();
    final resp = await _dio.get(
      isPublic ? '/api/activities/public/$id' : '/api/activities/$id',
      options: Options(headers: headers.isEmpty ? null : headers),
    );
    return _mapActivity(resp.data['data']['activity']);
  }

  Future<({List<ent.Activity> activities, ent.Pagination pagination})>
  getUserActivities({int page = 1, int limit = 10, ActivityType? type}) async {
    final headers = await _authHeaders();
    final resp = await _dio.get(
      '/api/activities/my-activities',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (type != null)
          'type': switch (type) {
            ActivityType.running => 'running',
            ActivityType.walking => 'walking',
            ActivityType.cycling => 'cycling',
          },
      },
      options: Options(headers: headers.isEmpty ? null : headers),
    );
    final data = resp.data['data'];
    final list = (data['activities'] as List)
        .map((e) => _mapActivity(e))
        .toList();
    final pag = _mapPagination(data['pagination']);
    return (activities: list, pagination: pag);
  }

  Future<ent.ActivityStats> getStats({String period = 'all'}) async {
    final headers = await _authHeaders();
    final resp = await _dio.get(
      '/api/activities/stats',
      queryParameters: period == 'all' ? null : {'period': period},
      options: Options(headers: headers.isEmpty ? null : headers),
    );
    return _mapStats(resp.data['data']['stats']);
  }

  Future<({List<ent.Activity> activities, ent.Pagination pagination})> getFeed({
    int page = 1,
    int limit = 10,
  }) async {
    final headers = await _authHeaders();
    final resp = await _dio.get(
      '/api/activities/feed',
      queryParameters: {'page': page, 'limit': limit},
      options: Options(headers: headers.isEmpty ? null : headers),
    );
    final data = resp.data['data'];
    final list = (data['activities'] as List)
        .map((e) => _mapActivity(e))
        .toList();
    final pag = _mapPagination(data['pagination']);
    return (activities: list, pagination: pag);
  }

  Future<({List<ent.Activity> activities, ent.Pagination pagination})>
  getFriendActivities(String friendId, {int page = 1, int limit = 15}) async {
    final headers = await _authHeaders();
    final resp = await _dio.get(
      '/api/activities/friends/$friendId/activities',
      queryParameters: {'page': page, 'limit': limit},
      options: Options(headers: headers.isEmpty ? null : headers),
    );
    final data = resp.data['data'];
    final list = (data['activities'] as List)
        .map((e) => _mapActivity(e))
        .toList();
    final pag = _mapPagination(data['pagination']);
    return (activities: list, pagination: pag);
  }

  Future<ent.Activity> createActivity({
    required ActivityType type,
    required int duration,
    required double distance,
    required int calories,
    List<(double lat, double lng)>? route,
    double? elevation,
    double? averagePace,
    String? feeling,
    String? weather,
    String? image,
  }) async {
    final headers = await _authHeaders();
    final body = {
      'type': switch (type) {
        ActivityType.running => 'running',
        ActivityType.walking => 'walking',
        ActivityType.cycling => 'cycling',
      },
      'duration': duration,
      'distance': distance,
      'calories': calories,
      if (route != null)
        'route': [
          for (final p in route) {'lat': p.$1, 'lng': p.$2},
        ],
      if (elevation != null) 'elevation': elevation,
      if (averagePace != null) 'averagePace': averagePace,
      if (feeling != null) 'feeling': feeling,
      if (weather != null) 'weather': weather,
      if (image != null) 'image': image,
    };
    final resp = await _dio.post(
      '/api/activities',
      data: body,
      options: Options(headers: headers.isEmpty ? null : headers),
    );
    return _mapActivity(resp.data['data']['activity']);
  }

  Future<ent.Activity> updateActivity(
    String id,
    Map<String, dynamic> update,
  ) async {
    final headers = await _authHeaders();
    dynamic dataToSend = update;
    Options options = Options(headers: headers.isEmpty ? null : headers);
    // Support multipart if a local file path is provided under 'imageFilePath'
    try {
      if (update.containsKey('imageFilePath') &&
          update['imageFilePath'] is String) {
        // Build FormData
        final path = update['imageFilePath'] as String;
        final form = FormData();
        for (final entry in update.entries) {
          if (entry.key == 'imageFilePath') continue;
          form.fields.add(MapEntry(entry.key, entry.value.toString()));
        }
        form.files.add(MapEntry('image', await MultipartFile.fromFile(path)));
        dataToSend = form;
        options = options.copyWith(contentType: 'multipart/form-data');
      }
    } catch (_) {}

    final resp = await _dio.put(
      '/api/activities/$id',
      data: dataToSend,
      options: options,
    );
    return _mapActivity(resp.data['data']['activity']);
  }

  Future<void> deleteActivity(String id) async {
    final headers = await _authHeaders();
    await _dio.delete(
      '/api/activities/$id',
      options: Options(headers: headers.isEmpty ? null : headers),
    );
  }

  Future<({ent.Activity activity, bool isLiked})> toggleLike(String id) async {
    final headers = await _authHeaders();
    final resp = await _dio.post(
      '/api/activities/$id/like',
      options: Options(headers: headers.isEmpty ? null : headers),
    );
    final data = resp.data['data'];
    return (
      activity: _mapActivity(data['activity']),
      isLiked: data['isLiked'] as bool,
    );
  }
}
