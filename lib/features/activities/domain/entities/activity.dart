import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import 'package:pacemate/features/tracking/domain/enums/activity_type.dart';

class Activity extends Equatable {
  final String id;
  final ActivityType type;
  final int duration; // seconds
  final double distance; // meters
  final int calories;
  final String userId;
  final List<LatLng> route; // optional path
  final DateTime createdAt;
  final double? elevation;
  final double? averagePace; // min/km
  final String? feeling;
  final String? weather;
  final String? image;
  final List<String> likes; // user ids

  const Activity({
    required this.id,
    required this.type,
    required this.duration,
    required this.distance,
    required this.calories,
    required this.userId,
    required this.route,
    required this.createdAt,
    this.elevation,
    this.averagePace,
    this.feeling,
    this.weather,
    this.image,
    this.likes = const [],
  });

  @override
  List<Object?> get props => [
    id,
    type,
    duration,
    distance,
    calories,
    userId,
    route,
    createdAt,
    elevation,
    averagePace,
    feeling,
    weather,
    image,
    likes,
  ];
}

class ActivityStats extends Equatable {
  final int totalActivities;
  final double totalDistance;
  final int totalDuration;
  final int totalCalories;
  final double averageDistance;
  final double averageDuration;
  final double averageCalories;

  const ActivityStats({
    required this.totalActivities,
    required this.totalDistance,
    required this.totalDuration,
    required this.totalCalories,
    required this.averageDistance,
    required this.averageDuration,
    required this.averageCalories,
  });

  @override
  List<Object?> get props => [
    totalActivities,
    totalDistance,
    totalDuration,
    totalCalories,
    averageDistance,
    averageDuration,
    averageCalories,
  ];
}

class Pagination extends Equatable {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool hasNextPage;
  final bool hasPrevPage;

  const Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  @override
  List<Object?> get props => [
    currentPage,
    totalPages,
    totalItems,
    hasNextPage,
    hasPrevPage,
  ];
}
