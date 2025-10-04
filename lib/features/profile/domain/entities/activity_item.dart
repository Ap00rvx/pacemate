import 'package:equatable/equatable.dart';
import '../../../tracking/domain/enums/activity_type.dart';

class ActivityItem extends Equatable {
  final String id;
  final DateTime dateTime;
  final ActivityType type;
  final double distanceKm;
  final int durationSeconds;
  final int calories;

  const ActivityItem({
    required this.id,
    required this.dateTime,
    required this.type,
    required this.distanceKm,
    required this.durationSeconds,
    required this.calories,
  });

  @override
  List<Object?> get props => [
    id,
    dateTime,
    type,
    distanceKm,
    durationSeconds,
    calories,
  ];
}
