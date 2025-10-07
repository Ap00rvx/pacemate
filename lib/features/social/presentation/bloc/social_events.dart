part of 'social_bloc.dart';

abstract class SocialEvent extends Equatable {
  const SocialEvent();
  @override
  List<Object?> get props => [];
}

class SearchUsersEvent extends SocialEvent {
  final String query;
  const SearchUsersEvent(this.query);
}

class ViewUserProfileEvent extends SocialEvent {
  final String id;
  const ViewUserProfileEvent(this.id);
}

class AddFriendEvent extends SocialEvent {
  final String friendId;
  const AddFriendEvent(this.friendId);
}

class RespondFriendEvent extends SocialEvent {
  final String requesterId;
  final bool accept;
  const RespondFriendEvent(this.requesterId, this.accept);
}

class FetchFriendRequestsEvent extends SocialEvent {
  const FetchFriendRequestsEvent();
}

class FetchFriendsListEvent extends SocialEvent {
  const FetchFriendsListEvent();
}
