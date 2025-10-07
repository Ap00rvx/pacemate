import '../entities/social_user.dart';

abstract class SocialRepository {
  Future<List<SocialUser>> searchUsers(String query);
  Future<ViewProfile> viewProfile(String id);
  Future<void> addFriend(String friendId);
  Future<void> respondToFriendRequest(String requesterId, bool accept);
  Future<List<SocialUser>> getFriendRequests();
  Future<List<SocialUser>> getFriendsList();
}
