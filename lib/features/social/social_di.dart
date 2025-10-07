import 'package:pacemate/features/social/data/datasources/social_remote_datasource.dart';
import 'package:pacemate/features/social/data/repositories/social_repository_impl.dart';
import 'package:pacemate/features/social/domain/usecases/social_usecases.dart';
import 'package:pacemate/features/social/presentation/bloc/social_bloc.dart';

class SocialDI {
  static final _remote = SocialRemoteDataSource();
  static final _repo = SocialRepositoryImpl(_remote);

  static final _search = SearchUsersUseCase(_repo);
  static final _view = ViewProfileUseCase(_repo);
  static final _add = AddFriendUseCase(_repo);
  static final _respond = RespondFriendUseCase(_repo);
  static final _requests = GetFriendRequestsUseCase(_repo);
  static final _friends = GetFriendsListUseCase(_repo);

  static SocialBloc getBloc() => SocialBloc(
    searchUsers: _search,
    viewProfile: _view,
    addFriend: _add,
    respondFriend: _respond,
    getFriendRequests: _requests,
    getFriendsList: _friends,
  );
}
