part of 'activity_bloc.dart';

abstract class ActivityEvent extends Equatable {
  const ActivityEvent();
  @override
  List<Object?> get props => [];
}

class FetchActivitiesEvent extends ActivityEvent {
  final int page;
  final int limit;
  final ActivityType? type;
  final String? userId;
  final String sortBy;
  final String sortOrder;
  const FetchActivitiesEvent({
    this.page = 1,
    this.limit = 10,
    this.type,
    this.userId,
    this.sortBy = 'createdAt',
    this.sortOrder = 'desc',
  });
}

class FetchPublicActivitiesEvent extends ActivityEvent {
  final int page;
  final int limit;
  final ActivityType? type;
  final String? userId;
  final String sortBy;
  final String sortOrder;
  const FetchPublicActivitiesEvent({
    this.page = 1,
    this.limit = 10,
    this.type,
    this.userId,
    this.sortBy = 'createdAt',
    this.sortOrder = 'desc',
  });
}

class FetchActivityByIdEvent extends ActivityEvent {
  final String id;
  final bool isPublic;
  const FetchActivityByIdEvent(this.id, {this.isPublic = false});
}

class FetchUserActivitiesEvent extends ActivityEvent {
  final int page;
  final int limit;
  final ActivityType? type;
  const FetchUserActivitiesEvent({this.page = 1, this.limit = 10, this.type});
}

class FetchStatsEvent extends ActivityEvent {
  final String period; // day|week|month|year|all
  const FetchStatsEvent({this.period = 'all'});
}

class FetchFeedEvent extends ActivityEvent {
  final int page;
  final int limit;
  const FetchFeedEvent({this.page = 1, this.limit = 10});
}

class CreateActivityEvent extends ActivityEvent {
  final ActivityType type;
  final int duration;
  final double distance;
  final int calories;
  final List<(double lat, double lng)>? route;
  final double? elevation;
  final double? averagePace;
  final String? feeling;
  final String? weather;
  final String? image;
  const CreateActivityEvent({
    required this.type,
    required this.duration,
    required this.distance,
    required this.calories,
    this.route,
    this.elevation,
    this.averagePace,
    this.feeling,
    this.weather,
    this.image,
  });
}

class UpdateActivityEvent extends ActivityEvent {
  final String id;
  final Map<String, dynamic> update;
  const UpdateActivityEvent(this.id, this.update);
}

class DeleteActivityEvent extends ActivityEvent {
  final String id;
  const DeleteActivityEvent(this.id);
}

class ToggleLikeEvent extends ActivityEvent {
  final String id;
  const ToggleLikeEvent(this.id);
}
