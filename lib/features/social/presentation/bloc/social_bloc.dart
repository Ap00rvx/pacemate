import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pacemate/features/social/domain/entities/social_user.dart';
import 'package:pacemate/features/social/domain/usecases/social_usecases.dart';

part 'social_events.dart';
part 'social_state.dart';

class SocialBloc extends Bloc<SocialEvent, SocialState> {
  final SearchUsersUseCase searchUsers;
  final ViewProfileUseCase viewProfile;
  final AddFriendUseCase addFriend;
  final RespondFriendUseCase respondFriend;
  final GetFriendRequestsUseCase getFriendRequests;
  final GetFriendsListUseCase getFriendsList;

  SocialBloc({
    required this.searchUsers,
    required this.viewProfile,
    required this.addFriend,
    required this.respondFriend,
    required this.getFriendRequests,
    required this.getFriendsList,
  }) : super(const SocialState()) {
    on<SearchUsersEvent>(_onSearch);
    on<ViewUserProfileEvent>(_onViewProfile);
    on<AddFriendEvent>(_onAddFriend);
    on<RespondFriendEvent>(_onRespond);
    on<FetchFriendRequestsEvent>(_onFetchRequests);
    on<FetchFriendsListEvent>(_onFetchFriends);
  }

  Future<void> _onSearch(SearchUsersEvent e, Emitter<SocialState> emit) async {
    emit(state.copyWith(searchStatus: SocialStatus.loading));
    try {
      final list = await searchUsers(e.query);
      emit(state.copyWith(searchStatus: SocialStatus.success, results: list));
    } catch (err) {
      emit(state.copyWith(searchStatus: SocialStatus.failure, message: '$err'));
    }
  }

  Future<void> _onViewProfile(
    ViewUserProfileEvent e,
    Emitter<SocialState> emit,
  ) async {
    emit(state.copyWith(profileStatus: SocialStatus.loading));
    try {
      final vp = await viewProfile(e.id);
      emit(
        state.copyWith(
          profileStatus: SocialStatus.success,
          viewed: vp.user,
          isFriend: vp.isFriend,
        ),
      );
    } catch (err) {
      emit(
        state.copyWith(profileStatus: SocialStatus.failure, message: '$err'),
      );
    }
  }

  Future<void> _onAddFriend(AddFriendEvent e, Emitter<SocialState> emit) async {
    emit(state.copyWith(actionStatus: SocialStatus.loading));
    try {
      await addFriend(e.friendId);
      emit(state.copyWith(actionStatus: SocialStatus.success));
    } catch (err) {
      emit(state.copyWith(actionStatus: SocialStatus.failure, message: '$err'));
    }
  }

  Future<void> _onRespond(
    RespondFriendEvent e,
    Emitter<SocialState> emit,
  ) async {
    emit(state.copyWith(actionStatus: SocialStatus.loading));
    try {
      await respondFriend(e.requesterId, e.accept);
      emit(state.copyWith(actionStatus: SocialStatus.success));
      // refresh requests list
      add(const FetchFriendRequestsEvent());
    } catch (err) {
      emit(state.copyWith(actionStatus: SocialStatus.failure, message: '$err'));
    }
  }

  Future<void> _onFetchRequests(
    FetchFriendRequestsEvent e,
    Emitter<SocialState> emit,
  ) async {
    emit(state.copyWith(requestsStatus: SocialStatus.loading));
    try {
      final list = await getFriendRequests();
      emit(
        state.copyWith(
          requestsStatus: SocialStatus.success,
          friendRequests: list,
        ),
      );
    } catch (err) {
      emit(
        state.copyWith(requestsStatus: SocialStatus.failure, message: '$err'),
      );
    }
  }

  Future<void> _onFetchFriends(
    FetchFriendsListEvent e,
    Emitter<SocialState> emit,
  ) async {
    emit(state.copyWith(friendsStatus: SocialStatus.loading));
    try {
      final list = await getFriendsList();
      emit(state.copyWith(friendsStatus: SocialStatus.success, friends: list));
    } catch (err) {
      emit(
        state.copyWith(friendsStatus: SocialStatus.failure, message: '$err'),
      );
    }
  }
}
