import 'package:pacemate/features/activities/data/datasources/activity_remote_datasource.dart';
import 'package:pacemate/features/activities/data/repositories/activity_repository_impl.dart';
import 'package:pacemate/features/activities/domain/repositories/activity_repository.dart';
import 'package:pacemate/features/activities/domain/usecases/usecases.dart';
import 'package:pacemate/features/activities/presentation/bloc/activity_bloc.dart';

class ActivitiesDI {
  static final ActivityRemoteDataSource _remote = ActivityRemoteDataSource();
  static final ActivityRepository _repo = ActivityRepositoryImpl(_remote);

  static final ListActivities listActivities = ListActivities(_repo);
  static final GetActivityById getActivityById = GetActivityById(_repo);
  static final ListUserActivities listUserActivities = ListUserActivities(
    _repo,
  );
  static final GetStats getStats = GetStats(_repo);
  static final GetFeed getFeed = GetFeed(_repo);
  static final GetFriendActivities getFriendActivities = GetFriendActivities(
    _repo,
  );
  static final CreateActivity createActivity = CreateActivity(_repo);
  static final UpdateActivity updateActivity = UpdateActivity(_repo);
  static final DeleteActivity deleteActivity = DeleteActivity(_repo);
  static final ToggleLike toggleLike = ToggleLike(_repo);

  static ActivityBloc getBloc() => ActivityBloc(
    listActivities: listActivities,
    getActivityById: getActivityById,
    listUserActivities: listUserActivities,
    getStats: getStats,
    getFeed: getFeed,
    getFriendActivities: getFriendActivities,
    createActivity: createActivity,
    updateActivity: updateActivity,
    deleteActivity: deleteActivity,
    toggleLike: toggleLike,
  );

  static ActivityRepository getRepository() => _repo;
}
