import 'package:equatable/equatable.dart';
import 'package:pacemate/features/activities/domain/entities/activity.dart'
    as ent;

class LeaderboardUser extends Equatable {
  final String id;
  final String name;
  final String avatarUrl;
  const LeaderboardUser({
    required this.id,
    required this.name,
    this.avatarUrl = '',
  });

  @override
  List<Object?> get props => [id, name, avatarUrl];
}

class LeaderboardDistanceEntry extends Equatable {
  final LeaderboardUser user;
  final double distanceKm;
  final int? rank;
  const LeaderboardDistanceEntry({
    required this.user,
    required this.distanceKm,
    this.rank,
  });

  @override
  List<Object?> get props => [user, distanceKm, rank];
}

class LeaderboardData extends Equatable {
  final String period; // e.g., 'week','month','year','all'
  final List<LeaderboardDistanceEntry> friendsLeaderboard;
  final List<LeaderboardDistanceEntry> globalLeaderboard;
  final List<ent.Activity> myRecentActivities;
  final List<ent.Activity> friendsRecentActivities;
  final int? myGlobalRankDistance;
  final LeaderboardSummary? mySummary;

  const LeaderboardData({
    required this.period,
    required this.friendsLeaderboard,
    required this.globalLeaderboard,
    required this.myRecentActivities,
    required this.friendsRecentActivities,
    required this.myGlobalRankDistance,
    this.mySummary,
  });

  @override
  List<Object?> get props => [
    period,
    friendsLeaderboard,
    globalLeaderboard,
    myRecentActivities,
    friendsRecentActivities,
    myGlobalRankDistance,
    mySummary,
  ];
}

class LeaderboardSummary extends Equatable {
  final int totalActivities;
  final double totalDistance;
  final int totalDuration;
  final int totalCalories;
  final double averageDistance;
  final int averageDuration;
  final double averageCalories;

  const LeaderboardSummary({
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
