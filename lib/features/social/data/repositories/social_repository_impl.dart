import 'package:pacemate/features/social/domain/entities/social_user.dart';
import 'package:pacemate/features/social/domain/repositories/social_repository.dart';
import '../datasources/social_remote_datasource.dart';

class SocialRepositoryImpl implements SocialRepository {
  final SocialRemoteDataSource remote;
  SocialRepositoryImpl(this.remote);

  @override
  Future<void> addFriend(String friendId) => remote.addFriend(friendId);

  @override
  Future<void> respondToFriendRequest(String requesterId, bool accept) =>
      remote.respondToFriendRequest(requesterId, accept);

  @override
  Future<List<SocialUser>> searchUsers(String query) => remote.search(query);

  @override
  Future<ViewProfile> viewProfile(String id) => remote.viewProfile(id);
}
