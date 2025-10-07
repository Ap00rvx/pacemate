part of 'social_bloc.dart';

enum SocialStatus { initial, loading, success, failure }

class SocialState extends Equatable {
  final SocialStatus searchStatus;
  final SocialStatus profileStatus;
  final SocialStatus actionStatus;
  final SocialStatus requestsStatus;
  final SocialStatus friendsStatus;
  final List<SocialUser> results;
  final List<SocialUser> friendRequests;
  final List<SocialUser> friends;
  final SocialUser? viewed;
  final bool isFriend;
  final String? message;

  const SocialState({
    this.searchStatus = SocialStatus.initial,
    this.profileStatus = SocialStatus.initial,
    this.actionStatus = SocialStatus.initial,
    this.requestsStatus = SocialStatus.initial,
    this.friendsStatus = SocialStatus.initial,
    this.results = const [],
    this.friendRequests = const [],
    this.friends = const [],
    this.viewed,
    this.isFriend = false,
    this.message,
  });

  SocialState copyWith({
    SocialStatus? searchStatus,
    SocialStatus? profileStatus,
    SocialStatus? actionStatus,
    SocialStatus? requestsStatus,
    SocialStatus? friendsStatus,
    List<SocialUser>? results,
    List<SocialUser>? friendRequests,
    List<SocialUser>? friends,
    SocialUser? viewed,
    bool? isFriend,
    String? message,
  }) => SocialState(
    searchStatus: searchStatus ?? this.searchStatus,
    profileStatus: profileStatus ?? this.profileStatus,
    actionStatus: actionStatus ?? this.actionStatus,
    requestsStatus: requestsStatus ?? this.requestsStatus,
    friendsStatus: friendsStatus ?? this.friendsStatus,
    results: results ?? this.results,
    friendRequests: friendRequests ?? this.friendRequests,
    friends: friends ?? this.friends,
    viewed: viewed ?? this.viewed,
    isFriend: isFriend ?? this.isFriend,
    message: message,
  );

  @override
  List<Object?> get props => [
    searchStatus,
    profileStatus,
    actionStatus,
    requestsStatus,
    friendsStatus,
    results,
    friendRequests,
    friends,
    viewed,
    isFriend,
    message,
  ];
}
