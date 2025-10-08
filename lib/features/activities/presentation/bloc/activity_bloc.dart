import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pacemate/features/activities/domain/entities/activity.dart'
    as ent;
import 'package:pacemate/features/activities/domain/usecases/usecases.dart';
import 'package:pacemate/features/tracking/domain/enums/activity_type.dart';

part 'activity_events.dart';
part 'activity_state.dart';

class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  final ListActivities listActivities;
  final GetActivityById getActivityById;
  final ListUserActivities listUserActivities;
  final GetStats getStats;
  final GetFeed getFeed;
  final GetFriendActivities getFriendActivities;
  final CreateActivity createActivity;
  final UpdateActivity updateActivity;
  final DeleteActivity deleteActivity;
  final ToggleLike toggleLike;

  ActivityBloc({
    required this.listActivities,
    required this.getActivityById,
    required this.listUserActivities,
    required this.getStats,
    required this.getFeed,
    required this.getFriendActivities,
    required this.createActivity,
    required this.updateActivity,
    required this.deleteActivity,
    required this.toggleLike,
  }) : super(const ActivityState()) {
    on<FetchActivitiesEvent>(_onFetchActivities);
    on<FetchPublicActivitiesEvent>(_onFetchPublicActivities);
    on<FetchActivityByIdEvent>(_onFetchActivityById);
    on<FetchUserActivitiesEvent>(_onFetchUserActivities);
    on<FetchStatsEvent>(_onFetchStats);
    on<FetchFeedEvent>(_onFetchFeed);
    on<FetchFriendActivitiesEvent>(_onFetchFriendActivities);
    on<CreateActivityEvent>(_onCreateActivity);
    on<UpdateActivityEvent>(_onUpdateActivity);
    on<DeleteActivityEvent>(_onDeleteActivity);
    on<ToggleLikeEvent>(_onToggleLike);
  }

  Future<void> _onFetchActivities(
    FetchActivitiesEvent event,
    Emitter<ActivityState> emit,
  ) async {
    emit(state.copyWith(status: ActivityStatus.loading));
    try {
      final result = await listActivities(
        page: event.page,
        limit: event.limit,
        type: event.type,
        userId: event.userId,
        sortBy: event.sortBy,
        sortOrder: event.sortOrder,
        isPublic: false,
      );
      emit(
        state.copyWith(
          status: ActivityStatus.success,
          activities: result.activities,
          pagination: result.pagination,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: ActivityStatus.failure, message: e.toString()),
      );
    }
  }

  Future<void> _onFetchPublicActivities(
    FetchPublicActivitiesEvent event,
    Emitter<ActivityState> emit,
  ) async {
    emit(state.copyWith(status: ActivityStatus.loading));
    try {
      final result = await listActivities(
        page: event.page,
        limit: event.limit,
        type: event.type,
        userId: event.userId,
        sortBy: event.sortBy,
        sortOrder: event.sortOrder,
        isPublic: true,
      );
      emit(
        state.copyWith(
          status: ActivityStatus.success,
          activities: result.activities,
          pagination: result.pagination,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: ActivityStatus.failure, message: e.toString()),
      );
    }
  }

  Future<void> _onFetchActivityById(
    FetchActivityByIdEvent event,
    Emitter<ActivityState> emit,
  ) async {
    emit(state.copyWith(detailStatus: ActivityStatus.loading));
    try {
      final item = await getActivityById(event.id, isPublic: event.isPublic);
      emit(
        state.copyWith(detailStatus: ActivityStatus.success, activity: item),
      );
    } catch (e) {
      emit(
        state.copyWith(
          detailStatus: ActivityStatus.failure,
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> _onFetchUserActivities(
    FetchUserActivitiesEvent event,
    Emitter<ActivityState> emit,
  ) async {
    emit(state.copyWith(status: ActivityStatus.loading));
    try {
      final result = await listUserActivities(
        page: event.page,
        limit: event.limit,
        type: event.type,
      );
      emit(
        state.copyWith(
          status: ActivityStatus.success,
          activities: result.activities,
          pagination: result.pagination,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: ActivityStatus.failure, message: e.toString()),
      );
    }
  }

  Future<void> _onFetchStats(
    FetchStatsEvent event,
    Emitter<ActivityState> emit,
  ) async {
    emit(state.copyWith(statsStatus: ActivityStatus.loading));
    try {
      final s = await getStats(period: event.period);
      emit(state.copyWith(statsStatus: ActivityStatus.success, stats: s));
    } catch (e) {
      emit(
        state.copyWith(
          statsStatus: ActivityStatus.failure,
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> _onFetchFeed(
    FetchFeedEvent event,
    Emitter<ActivityState> emit,
  ) async {
    emit(state.copyWith(feedStatus: ActivityStatus.loading));
    try {
      final result = await getFeed(page: event.page, limit: event.limit);
      final merged = event.page <= 1
          ? result.activities
          : [...state.feed, ...result.activities];
      emit(
        state.copyWith(
          feedStatus: ActivityStatus.success,
          feed: merged,
          feedPagination: result.pagination,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          feedStatus: ActivityStatus.failure,
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> _onFetchFriendActivities(
    FetchFriendActivitiesEvent event,
    Emitter<ActivityState> emit,
  ) async {
    // We reuse status to show loading state in friend activities context only if first page
    if (event.page <= 1) emit(state.copyWith(status: ActivityStatus.loading));
    try {
      final result = await getFriendActivities(
        event.friendId,
        page: event.page,
        limit: event.limit,
      );
      final merged = event.page <= 1
          ? result.activities
          : [...state.friendActivities, ...result.activities];
      emit(
        state.copyWith(
          status: ActivityStatus.success,
          friendActivities: merged,
          friendPagination: result.pagination,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: ActivityStatus.failure, message: e.toString()),
      );
    }
  }

  Future<void> _onCreateActivity(
    CreateActivityEvent event,
    Emitter<ActivityState> emit,
  ) async {
    emit(state.copyWith(mutateStatus: ActivityStatus.loading));
    try {
      final created = await createActivity(
        type: event.type,
        duration: event.duration,
        distance: event.distance,
        calories: event.calories,
        route: event.route,
        elevation: event.elevation,
        averagePace: event.averagePace,
        feeling: event.feeling,
        weather: event.weather,
        image: event.image,
      );
      final updated = [created, ...state.activities];
      emit(
        state.copyWith(
          mutateStatus: ActivityStatus.success,
          activities: updated,
          lastMutated: created,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          mutateStatus: ActivityStatus.failure,
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdateActivity(
    UpdateActivityEvent event,
    Emitter<ActivityState> emit,
  ) async {
    emit(state.copyWith(mutateStatus: ActivityStatus.loading));
    try {
      final updated = await updateActivity(event.id, event.update);
      final list = state.activities
          .map((a) => a.id == updated.id ? updated : a)
          .toList();
      emit(
        state.copyWith(
          mutateStatus: ActivityStatus.success,
          activities: list,
          lastMutated: updated,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          mutateStatus: ActivityStatus.failure,
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleteActivity(
    DeleteActivityEvent event,
    Emitter<ActivityState> emit,
  ) async {
    emit(state.copyWith(mutateStatus: ActivityStatus.loading));
    try {
      await deleteActivity(event.id);
      final list = state.activities.where((a) => a.id != event.id).toList();
      emit(
        state.copyWith(mutateStatus: ActivityStatus.success, activities: list),
      );
    } catch (e) {
      emit(
        state.copyWith(
          mutateStatus: ActivityStatus.failure,
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> _onToggleLike(
    ToggleLikeEvent event,
    Emitter<ActivityState> emit,
  ) async {
    try {
      final result = await toggleLike(event.id);
      final list = state.activities
          .map((a) => a.id == result.activity.id ? result.activity : a)
          .toList();
      emit(state.copyWith(activities: list, lastMutated: result.activity));
    } catch (e) {
      emit(state.copyWith(message: e.toString()));
    }
  }
}
