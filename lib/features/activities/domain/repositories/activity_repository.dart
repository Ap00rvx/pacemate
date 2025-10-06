import 'package:pacemate/features/activities/domain/entities/activity.dart';
import 'package:pacemate/features/tracking/domain/enums/activity_type.dart';

abstract class ActivityRepository {
  Future<({List<Activity> activities, Pagination pagination})> getActivities({
    int page,
    int limit,
    ActivityType? type,
    String? userId,
    String sortBy,
    String sortOrder,
    bool isPublic,
  });

  Future<Activity> getActivityById(String id, {bool isPublic});

  Future<({List<Activity> activities, Pagination pagination})>
  getUserActivities({int page, int limit, ActivityType? type});

  Future<ActivityStats> getActivityStats({String period});

  Future<({List<Activity> activities, Pagination pagination})> getFeed({
    int page,
    int limit,
  });

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
  });

  Future<Activity> updateActivity(String id, Map<String, dynamic> update);

  Future<void> deleteActivity(String id);

  Future<({Activity activity, bool isLiked})> toggleLike(String id);
}
