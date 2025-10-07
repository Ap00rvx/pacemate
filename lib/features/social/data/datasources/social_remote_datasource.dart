import 'package:dio/dio.dart';
import 'package:pacemate/core/network/dio.dart';
import 'package:pacemate/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:pacemate/features/social/domain/entities/social_user.dart';

class SocialRemoteDataSource {
  final Dio _dio = DioNetworkClient().client;
  final AuthLocalDataSource _authLocal = AuthLocalDataSource();

  Future<Map<String, dynamic>> _authHeaders() async {
    final token = await _authLocal.getAccessToken();
    return token != null ? {'Authorization': 'Bearer $token'} : {};
  }

  SocialUser _mapUser(Map<String, dynamic> u) => SocialUser(
    id: (u['_id'] ?? u['id']).toString(),
    fullname: (u['fullname'] ?? '').toString(),
    avatar: (u['avatar'] is String && (u['avatar'] as String).isNotEmpty)
        ? u['avatar'] as String
        : null,
    location: u['location'] as String?,
  );

  Future<List<SocialUser>> search(String query) async {
    final headers = await _authHeaders();
    final resp = await _dio.get(
      '/api/users/search',
      queryParameters: {'query': query},
      options: Options(headers: headers.isEmpty ? null : headers),
    );
    final data = resp.data['data'];
    final list =
        (data['users'] as List?)?.map((e) => _mapUser(e)).toList() ?? [];
    return list;
  }

  Future<ViewProfile> viewProfile(String id) async {
    final headers = await _authHeaders();
    final resp = await _dio.get(
      '/api/users/view-profile/$id',
      options: Options(headers: headers.isEmpty ? null : headers),
    );
    final user = _mapUser(resp.data['user']);
    final isFriend = resp.data['isFriend'] as bool? ?? false;
    return ViewProfile(user: user, isFriend: isFriend);
  }

  Future<void> addFriend(String friendId) async {
    final headers = await _authHeaders();
    await _dio.post(
      '/api/users/friends',
      data: {'friendId': friendId},
      options: Options(headers: headers.isEmpty ? null : headers),
    );
  }

  Future<void> respondToFriendRequest(String requesterId, bool accept) async {
    final headers = await _authHeaders();
    await _dio.post(
      '/api/users/friends/respond',
      data: {'requesterId': requesterId, 'accept': accept},
      options: Options(headers: headers.isEmpty ? null : headers),
    );
  }
}
