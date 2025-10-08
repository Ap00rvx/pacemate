import 'package:pacemate/features/activities/data/datasources/activity_remote_datasource.dart';
import 'package:pacemate/features/activities/domain/entities/activity.dart';
import 'package:pacemate/features/activities/domain/repositories/activity_repository.dart';
import 'package:pacemate/features/tracking/domain/enums/activity_type.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  final ActivityRemoteDataSource remote;
  ActivityRepositoryImpl(this.remote);

  @override
  Future<({List<Activity> activities, Pagination pagination})> getActivities({
    int page = 1,
    int limit = 10,
    ActivityType? type,
    String? userId,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
    bool isPublic = true,
  }) => remote.getActivities(
    page: page,
    limit: limit,
    type: type,
    userId: userId,
    sortBy: sortBy,
    sortOrder: sortOrder,
    isPublic: isPublic,
  );

  @override
  Future<Activity> getActivityById(String id, {bool isPublic = false}) =>
      remote.getActivityById(id, isPublic: isPublic);

  @override
  Future<({List<Activity> activities, Pagination pagination})>
  getUserActivities({int page = 1, int limit = 10, ActivityType? type}) =>
      remote.getUserActivities(page: page, limit: limit, type: type);

  @override
  Future<ActivityStats> getActivityStats({String period = 'all'}) =>
      remote.getStats(period: period);

  @override
  Future<({List<Activity> activities, Pagination pagination})> getFeed({
    int page = 1,
    int limit = 10,
  }) => remote.getFeed(page: page, limit: limit);

  @override
  Future<({List<Activity> activities, Pagination pagination})>
  getFriendActivities(String friendId, {int page = 1, int limit = 15}) =>
      remote.getFriendActivities(friendId, page: page, limit: limit);

  @override
  Future<Activity> createActivity({
    required ActivityType type,
    required int duration,
    required double distance,
    required int calories,
    List<(double lat, double lng)>? route,
    double? elevation,
    double? averagePace,
    String? feeling,
    String? weather,
    String? image,
  }) => remote.createActivity(
    type: type,
    duration: duration,
    distance: distance,
    calories: calories,
    route: route,
    elevation: elevation,
    averagePace: averagePace,
    feeling: feeling,
    weather: weather,
    image: image,
  );

  @override
  Future<Activity> updateActivity(String id, Map<String, dynamic> update) =>
      remote.updateActivity(id, update);

  @override
  Future<void> deleteActivity(String id) => remote.deleteActivity(id);

  @override
  Future<({Activity activity, bool isLiked})> toggleLike(String id) =>
      remote.toggleLike(id);
}
