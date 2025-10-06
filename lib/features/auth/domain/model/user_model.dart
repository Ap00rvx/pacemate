import 'package:equatable/equatable.dart';

/// Badge earned by user for achievements
class UserBadge extends Equatable {
  final String name;
  final String description;
  final String type;
  final String criteria;

  const UserBadge({
    required this.name,
    required this.description,
    required this.type,
    required this.criteria,
  });

  factory UserBadge.fromJson(Map<String, dynamic> json) {
    return UserBadge(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      criteria: json['criteria'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'type': type,
      'criteria': criteria,
    };
  }

  @override
  List<Object?> get props => [name, description, type, criteria];
}

/// User model representing a registered user in the app
class UserModel extends Equatable {
  final String? id;
  final String fullname;
  final String email;
  final String? password;
  final String? location;
  final List<UserBadge> badges;
  final String? avatar;
  final DateTime createdAt;
  final DateTime dateOfBirth;
  final String gender;
  final int age;
  final double height; // in cm
  final double weight; // in kg
  final String? googleId;
  final double totalDistance; // in km
  final int totalTime; // in seconds
  final int totalCalories;
  final int totalRuns;
  final List<String> friends; // User IDs
  final List<String> friendRequests; // User IDs
  final List<String> activities; // Activity IDs

  const UserModel({
    this.id,
    required this.fullname,
    required this.email,
    this.password,
    this.location,
    this.badges = const [],
    this.avatar,
    required this.createdAt,
    required this.dateOfBirth,
    required this.gender,
    required this.age,
    required this.height,
    required this.weight,
    this.googleId,
    this.totalDistance = 0.0,
    this.totalTime = 0,
    this.totalCalories = 0,
    this.totalRuns = 0,
    this.friends = const [],
    this.friendRequests = const [],
    this.activities = const [],
  });

  /// Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'],
      fullname: json['fullname'] ?? '',
      email: json['email'] ?? '',
      password: json['password'],
      location: json['location'],
      badges:
          (json['badges'] as List<dynamic>?)
              ?.map(
                (badge) => UserBadge.fromJson(badge as Map<String, dynamic>),
              )
              .toList() ??
          [],
      avatar: json['avatar'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      dateOfBirth: DateTime.tryParse(json['dob'] ?? '') ?? DateTime.now(),
      gender: json['gender'] ?? '',
      age: json['age'] ?? 0,
      height: (json['height'] ?? 0).toDouble(),
      weight: (json['weight'] ?? 0).toDouble(),
      googleId: json['googleId'],
      totalDistance: (json['total_distance'] ?? 0).toDouble(),
      totalTime: json['total_time'] ?? 0,
      totalCalories: json['total_calories'] ?? 0,
      totalRuns: json['total_runs'] ?? 0,
      friends: List<String>.from(json['friends'] ?? []),
      friendRequests: List<String>.from(json['friendRequests'] ?? []),
      activities: List<String>.from(json['activities'] ?? []),
    );
  }

  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'fullname': fullname,
      'email': email,
      if (password != null) 'password': password,
      if (location != null) 'location': location,
      'badges': badges.map((badge) => badge.toJson()).toList(),
      if (avatar != null) 'avatar': avatar,
      'createdAt': createdAt.toIso8601String(),
      'dob': dateOfBirth.toIso8601String(),
      'gender': gender,
      'age': age,
      'height': height,
      'weight': weight,
      if (googleId != null) 'googleId': googleId,
      'total_distance': totalDistance,
      'total_time': totalTime,
      'total_calories': totalCalories,
      'total_runs': totalRuns,
      'friends': friends,
      'friendRequests': friendRequests,
      'activities': activities,
    };
  }

  /// Copy UserModel with updated fields
  UserModel copyWith({
    String? id,
    String? fullname,
    String? email,
    String? password,
    String? location,
    List<UserBadge>? badges,
    String? avatar,
    DateTime? createdAt,
    DateTime? dateOfBirth,
    String? gender,
    int? age,
    double? height,
    double? weight,
    String? googleId,
    double? totalDistance,
    int? totalTime,
    int? totalCalories,
    int? totalRuns,
    List<String>? friends,
    List<String>? friendRequests,
    List<String>? activities,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullname: fullname ?? this.fullname,
      email: email ?? this.email,
      password: password ?? this.password,
      location: location ?? this.location,
      badges: badges ?? this.badges,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      googleId: googleId ?? this.googleId,
      totalDistance: totalDistance ?? this.totalDistance,
      totalTime: totalTime ?? this.totalTime,
      totalCalories: totalCalories ?? this.totalCalories,
      totalRuns: totalRuns ?? this.totalRuns,
      friends: friends ?? this.friends,
      friendRequests: friendRequests ?? this.friendRequests,
      activities: activities ?? this.activities,
    );
  }

  /// Get user's initials for avatar display
  String get initials {
    final parts = fullname.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  /// Calculate BMI (Body Mass Index)
  double get bmi {
    if (height <= 0 || weight <= 0) return 0.0;
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  /// Get BMI category
  String get bmiCategory {
    final bmiValue = bmi;
    if (bmiValue < 18.5) return 'Underweight';
    if (bmiValue < 25.0) return 'Normal';
    if (bmiValue < 30.0) return 'Overweight';
    return 'Obese';
  }

  /// Calculate average pace (minutes per km)
  double get averagePace {
    if (totalDistance <= 0 || totalTime <= 0) return 0.0;
    return (totalTime / 60) / totalDistance; // minutes per km
  }

  /// Format total time as readable string
  String get formattedTotalTime {
    final hours = totalTime ~/ 3600;
    final minutes = (totalTime % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  @override
  List<Object?> get props => [
    id,
    fullname,
    email,
    password,
    location,
    badges,
    avatar,
    createdAt,
    dateOfBirth,
    gender,
    age,
    height,
    weight,
    googleId,
    totalDistance,
    totalTime,
    totalCalories,
    totalRuns,
    friends,
    friendRequests,
    activities,
  ];
}
