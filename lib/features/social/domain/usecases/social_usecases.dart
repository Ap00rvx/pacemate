import 'package:pacemate/features/social/domain/entities/social_user.dart';
import 'package:pacemate/features/social/domain/repositories/social_repository.dart';

class SearchUsersUseCase {
  final SocialRepository repo;
  SearchUsersUseCase(this.repo);
  Future<List<SocialUser>> call(String query) => repo.searchUsers(query);
}

class ViewProfileUseCase {
  final SocialRepository repo;
  ViewProfileUseCase(this.repo);
  Future<ViewProfile> call(String id) => repo.viewProfile(id);
}

class AddFriendUseCase {
  final SocialRepository repo;
  AddFriendUseCase(this.repo);
  Future<void> call(String friendId) => repo.addFriend(friendId);
}

class RespondFriendUseCase {
  final SocialRepository repo;
  RespondFriendUseCase(this.repo);
  Future<void> call(String requesterId, bool accept) =>
      repo.respondToFriendRequest(requesterId, accept);
}
