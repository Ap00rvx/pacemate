part of 'tracking_cubit.dart';

class TrackingState extends Equatable {
  final bool isTracking;
  final bool isPaused;
  final ActivityType? activityType;
  final DateTime? startedAt;
  final int durationSeconds;
  final List<TrackingPoint> points;
  final double distanceMeters;
  final int calories;

  const TrackingState({
    required this.isTracking,
    required this.isPaused,
    required this.activityType,
    required this.startedAt,
    required this.durationSeconds,
    required this.points,
    required this.distanceMeters,
    required this.calories,
  });

  const TrackingState.initial()
    : isTracking = false,
      isPaused = false,
      activityType = null,
      startedAt = null,
      durationSeconds = 0,
      points = const [],
      distanceMeters = 0,
      calories = 0;

  TrackingState copyWith({
    bool? isTracking,
    bool? isPaused,
    ActivityType? activityType,
    DateTime? startedAt,
    int? durationSeconds,
    List<TrackingPoint>? points,
    double? distanceMeters,
    int? calories,
  }) {
    return TrackingState(
      isTracking: isTracking ?? this.isTracking,
      isPaused: isPaused ?? this.isPaused,
      activityType: activityType ?? this.activityType,
      startedAt: startedAt ?? this.startedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      points: points ?? this.points,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      calories: calories ?? this.calories,
    );
  }

  @override
  List<Object?> get props => [
    isTracking,
    isPaused,
    activityType,
    startedAt,
    durationSeconds,
    points,
    distanceMeters,
    calories,
  ];
}
