import 'package:equatable/equatable.dart';

class SocialUser extends Equatable {
  final String id;
  final String fullname;
  final String? avatar; // nullable
  final String? location;
  final double? bmi;
  final double? totalDistance; // meters or km per API, display accordingly
  final int? totalTime; // seconds
  final int? totalCalories; // kcal
  final int? totalRuns;
  final String? gender;
  final List<String>? friends; 
  final List<String>? friendRequests;
  final DateTime? createdAt;

  const SocialUser({
    required this.id,
    required this.fullname,
    this.avatar,
    this.location,
    this.bmi,
    this.totalDistance,
    this.totalTime,
    this.totalCalories,
    this.totalRuns,
    this.createdAt,
    this.gender,
    this.friends,
    this.friendRequests,
  });

  @override
  List<Object?> get props => [
    id,
    fullname,
    avatar,
    location,
    friends,
    bmi,
    totalDistance,
    totalTime,
    totalCalories,
    totalRuns,
    friendRequests,
  ];
}

class ViewProfile extends Equatable {
  final SocialUser user;
  final bool isFriend;

  const ViewProfile({required this.user, required this.isFriend});

  @override
  List<Object?> get props => [user, isFriend];
}
