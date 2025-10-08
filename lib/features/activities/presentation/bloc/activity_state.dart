part of 'activity_bloc.dart';

enum ActivityStatus { initial, loading, success, failure }

class ActivityState extends Equatable {
  final ActivityStatus status;
  final ActivityStatus detailStatus;
  final ActivityStatus statsStatus;
  final ActivityStatus feedStatus;
  final ActivityStatus mutateStatus;

  final List<ent.Activity> activities;
  final ent.Pagination? pagination;

  final ent.Activity? activity;

  final ent.ActivityStats? stats;

  final List<ent.Activity> feed;
  final ent.Pagination? feedPagination;

  final ent.Activity? lastMutated;

  final String? message;

  // Friend activities view
  final List<ent.Activity> friendActivities;
  final ent.Pagination? friendPagination;

  const ActivityState({
    this.status = ActivityStatus.initial,
    this.detailStatus = ActivityStatus.initial,
    this.statsStatus = ActivityStatus.initial,
    this.feedStatus = ActivityStatus.initial,
    this.mutateStatus = ActivityStatus.initial,
    this.activities = const [],
    this.pagination,
    this.activity,
    this.stats,
    this.feed = const [],
    this.feedPagination,
    this.lastMutated,
    this.message,
    this.friendActivities = const [],
    this.friendPagination,
  });

  ActivityState copyWith({
    ActivityStatus? status,
    ActivityStatus? detailStatus,
    ActivityStatus? statsStatus,
    ActivityStatus? feedStatus,
    ActivityStatus? mutateStatus,
    List<ent.Activity>? activities,
    ent.Pagination? pagination,
    ent.Activity? activity,
    ent.ActivityStats? stats,
    List<ent.Activity>? feed,
    ent.Pagination? feedPagination,
    ent.Activity? lastMutated,
    String? message,
    List<ent.Activity>? friendActivities,
    ent.Pagination? friendPagination,
  }) => ActivityState(
    status: status ?? this.status,
    detailStatus: detailStatus ?? this.detailStatus,
    statsStatus: statsStatus ?? this.statsStatus,
    feedStatus: feedStatus ?? this.feedStatus,
    mutateStatus: mutateStatus ?? this.mutateStatus,
    activities: activities ?? this.activities,
    pagination: pagination ?? this.pagination,
    activity: activity ?? this.activity,
    stats: stats ?? this.stats,
    feed: feed ?? this.feed,
    feedPagination: feedPagination ?? this.feedPagination,
    lastMutated: lastMutated ?? this.lastMutated,
    message: message,
    friendActivities: friendActivities ?? this.friendActivities,
    friendPagination: friendPagination ?? this.friendPagination,
  );

  @override
  List<Object?> get props => [
    status,
    detailStatus,
    statsStatus,
    feedStatus,
    mutateStatus,
    activities,
    pagination,
    activity,
    stats,
    feed,
    feedPagination,
    lastMutated,
    message,
    friendActivities,
    friendPagination,
  ];
}
