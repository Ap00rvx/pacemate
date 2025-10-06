import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/tracking_point.dart';
import '../../domain/enums/activity_type.dart';
import '../../utils/calorie_utils.dart';

part 'tracking_state.dart';

class TrackingCubit extends Cubit<TrackingState> {
  TrackingCubit() : super(const TrackingState.initial());

  Timer? _timer;

  void start(ActivityType type) {
    _timer?.cancel();
    emit(
      state.copyWith(
        activityType: type,
        isTracking: true,
        isPaused: false,
        startedAt: DateTime.now(),
        durationSeconds: 0,
        points: const [],
        distanceMeters: 0,
        calories: 0,
      ),
    );
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!state.isTracking || state.isPaused || state.startedAt == null)
        return;
      final now = DateTime.now();
      final dur = now.difference(state.startedAt!).inSeconds;
      emit(state.copyWith(durationSeconds: dur));
    });
  }

  void stop() {
    _timer?.cancel();
    emit(
      state.copyWith(
        isTracking: false,
        isPaused: false,
        points: [],
        distanceMeters: 0,
        calories: 0,
        durationSeconds: 0,
        startedAt: null,
        activityType: null,
      ),
    );
  }

  void pause() {
    if (!state.isTracking || state.isPaused) return;
    emit(state.copyWith(isPaused: true));
  }

  void resume() {
    if (!state.isTracking || !state.isPaused) return;
    emit(state.copyWith(isPaused: false));
  }

  // Add a new GPS point; distanceFromLast should be precomputed by the caller with Haversine
  void addPoint(TrackingPoint p) {
    if (!state.isTracking || state.isPaused) return;
    final updatedPoints = List<TrackingPoint>.from(state.points)..add(p);
    final distance = state.distanceMeters + p.distanceFromLast;
    final calories = estimateCalories(
      type: state.activityType ?? ActivityType.running,
      distanceKm: distance / 1000.0,
      durationSeconds: state.durationSeconds,
    );
    final elevation = max(p.elevation, state.elevation ?? 0);
    emit(
      state.copyWith(
        points: updatedPoints,
        distanceMeters: distance,
        calories: calories,
        elevation: elevation,
      ),
    );
  }
}
