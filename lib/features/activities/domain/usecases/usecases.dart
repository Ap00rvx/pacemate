import 'package:pacemate/features/activities/domain/entities/activity.dart';
import 'package:pacemate/features/activities/domain/repositories/activity_repository.dart';
import 'package:pacemate/features/tracking/domain/enums/activity_type.dart';

class ListActivities {
  final ActivityRepository repo;
  ListActivities(this.repo);
  Future<({List<Activity> activities, Pagination pagination})> call({
    int page = 1,
    int limit = 10,
    ActivityType? type,
    String? userId,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
    bool isPublic = true,
  }) => repo.getActivities(
    page: page,
    limit: limit,
    type: type,
    userId: userId,
    sortBy: sortBy,
    sortOrder: sortOrder,
    isPublic: isPublic,
  );
}

class GetActivityById {
  final ActivityRepository repo;
  GetActivityById(this.repo);
  Future<Activity> call(String id, {bool isPublic = false}) =>
      repo.getActivityById(id, isPublic: isPublic);
}

class ListUserActivities {
  final ActivityRepository repo;
  ListUserActivities(this.repo);
  Future<({List<Activity> activities, Pagination pagination})> call({
    int page = 1,
    int limit = 10,
    ActivityType? type,
  }) => repo.getUserActivities(page: page, limit: limit, type: type);
}

class GetStats {
  final ActivityRepository repo;
  GetStats(this.repo);
  Future<ActivityStats> call({String period = 'all'}) =>
      repo.getActivityStats(period: period);
}

class GetFeed {
  final ActivityRepository repo;
  GetFeed(this.repo);
  Future<({List<Activity> activities, Pagination pagination})> call({
    int page = 1,
    int limit = 10,
  }) => repo.getFeed(page: page, limit: limit);
}

class GetFriendActivities {
  final ActivityRepository repo;
  GetFriendActivities(this.repo);
  Future<({List<Activity> activities, Pagination pagination})> call(
    String friendId, {
    int page = 1,
    int limit = 15,
  }) => repo.getFriendActivities(friendId, page: page, limit: limit);
}

class CreateActivity {
  final ActivityRepository repo;
  CreateActivity(this.repo);
  Future<Activity> call({
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
  }) => repo.createActivity(
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
}

class UpdateActivity {
  final ActivityRepository repo;
  UpdateActivity(this.repo);
  Future<Activity> call(String id, Map<String, dynamic> update) =>
      repo.updateActivity(id, update);
}

class DeleteActivity {
  final ActivityRepository repo;
  DeleteActivity(this.repo);
  Future<void> call(String id) => repo.deleteActivity(id);
}

class ToggleLike {
  final ActivityRepository repo;
  ToggleLike(this.repo);
  Future<({Activity activity, bool isLiked})> call(String id) =>
      repo.toggleLike(id);
}
