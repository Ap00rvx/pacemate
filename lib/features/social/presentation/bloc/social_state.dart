part of 'social_bloc.dart';

enum SocialStatus { initial, loading, success, failure }

class SocialState extends Equatable {
  final SocialStatus searchStatus;
  final SocialStatus profileStatus;
  final SocialStatus actionStatus;
  final List<SocialUser> results;
  final SocialUser? viewed;
  final bool isFriend;
  final String? message;

  const SocialState({
    this.searchStatus = SocialStatus.initial,
    this.profileStatus = SocialStatus.initial,
    this.actionStatus = SocialStatus.initial,
    this.results = const [],
    this.viewed,
    this.isFriend = false,
    this.message,
  });

  SocialState copyWith({
    SocialStatus? searchStatus,
    SocialStatus? profileStatus,
    SocialStatus? actionStatus,
    List<SocialUser>? results,
    SocialUser? viewed,
    bool? isFriend,
    String? message,
  }) => SocialState(
    searchStatus: searchStatus ?? this.searchStatus,
    profileStatus: profileStatus ?? this.profileStatus,
    actionStatus: actionStatus ?? this.actionStatus,
    results: results ?? this.results,
    viewed: viewed ?? this.viewed,
    isFriend: isFriend ?? this.isFriend,
    message: message,
  );

  @override
  List<Object?> get props => [
    searchStatus,
    profileStatus,
    actionStatus,
    results,
    viewed,
    isFriend,
    message,
  ];
}
