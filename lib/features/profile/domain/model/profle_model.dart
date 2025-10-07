import 'package:equatable/equatable.dart';

class ProfileModel extends Equatable {
  final String id;
  final String fullname;
  final String email;
  final String? location;
  final int? age;
  final DateTime? dob;
  final String? gender;
  final int? height;
  final int? weight;
  final String? avatar;
  final double
  totalDistance; // km or meters? API seems to store km; keep as double
  final int totalTime; // seconds
  final int totalCalories;
  final int totalRuns;
  final List<ProfileFriend> friends;
  final List<ProfileFriendRequest> friendRequests;
  final List<dynamic>
  activities; // placeholder: integrate Activity domain later if needed
  final List<dynamic> badges; // placeholder
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final double? bmi;

  const ProfileModel({
    required this.id,
    required this.fullname,
    required this.email,
    this.location,
    this.age,
    this.dob,
    this.gender,
    this.height,
    this.weight,
    required this.totalDistance,
    required this.totalTime,
    required this.totalCalories,
    required this.totalRuns,
    required this.friends,
    required this.friendRequests,
    required this.activities,
    required this.badges,
    this.createdAt,
    this.updatedAt,
    this.avatar
  ,
    this.bmi,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    double? _parseDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) {
        final d = double.tryParse(v);
        if (d == null || d.isNaN) return null;
        return d;
      }
      return null;
    }

    int _parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    DateTime? _parseDate(dynamic v) {
      if (v == null) return null;
      if (v is String) return DateTime.tryParse(v);
      return null;
    }

    final friendsList =
        (json['friends'] as List?)
            ?.map((e) => ProfileFriend.fromJson(e as Map<String, dynamic>))
            .toList() ??
        <ProfileFriend>[];
    final requestsList =
        (json['friendRequests'] as List?)
            ?.map(
              (e) => ProfileFriendRequest.fromJson(e as Map<String, dynamic>),
            )
            .toList() ??
        <ProfileFriendRequest>[];

    return ProfileModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      fullname: (json['fullname'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      location: (json['location'] as String?),
      age: json['age'] is num
          ? (json['age'] as num).toInt()
          : int.tryParse('${json['age']}'),
      dob: _parseDate(json['dob']),
      gender: json['gender'] as String?,
      height: json['height'] is num
          ? (json['height'] as num).toInt()
          : int.tryParse('${json['height']}'),
      weight: json['weight'] is num
          ? (json['weight'] as num).toInt()
          : int.tryParse('${json['weight']}'),
      totalDistance: _parseDouble(json['total_distance']) ?? 0.0,
      totalTime: _parseInt(json['total_time']),
      totalCalories: _parseInt(json['total_calories']),
      totalRuns: _parseInt(json['total_runs']),
      friends: friendsList,
      friendRequests: requestsList,
      activities: (json['activities'] as List?) ?? const [],
      badges: (json['badges'] as List?) ?? const [],
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
      bmi: _parseDouble(json['bmi']),
      avatar: (json['avatar'] as String?),
    );
  }

  @override
  List<Object?> get props => [
    id,
    fullname,
    email,
    location,
    age,
    dob,
    gender,
    height,
    weight,
    totalDistance,
    totalTime,
    totalCalories,
    totalRuns,
    friends,
    friendRequests,
    activities,
    badges,
    createdAt,
    updatedAt,
    bmi,
  ];
}

class ProfileFriend extends Equatable {
  final String id;
  final String fullname;
  final String email;
  final String? avatar;
  final double? bmi;

  const ProfileFriend({
    required this.id,
    required this.fullname,
    required this.email,
    this.avatar,
    this.bmi,
  });

  factory ProfileFriend.fromJson(Map<String, dynamic> json) {
    double? _parseDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) {
        final d = double.tryParse(v);
        if (d == null || d.isNaN) return null;
        return d;
      }
      return null;
    }

    final avatarVal = json['avatar'];
    String? avatar;
    if (avatarVal is String && avatarVal.isNotEmpty) avatar = avatarVal;

    return ProfileFriend(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      fullname: (json['fullname'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      avatar: avatar,
      bmi: _parseDouble(json['bmi']),
    );
  }

  @override
  List<Object?> get props => [id, fullname, email, avatar, bmi];
}

class ProfileFriendRequest extends Equatable {
  final String id;
  final String fullname;
  final String email;
  final String? avatar;

  const ProfileFriendRequest({
    required this.id,
    required this.fullname,
    required this.email,
    this.avatar,
  });

  factory ProfileFriendRequest.fromJson(Map<String, dynamic> json) {
    final avatarVal = json['avatar'];
    String? avatar;
    if (avatarVal is String && avatarVal.isNotEmpty) avatar = avatarVal;
    return ProfileFriendRequest(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      fullname: (json['fullname'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      avatar: avatar,
    );
  }

  @override
  List<Object?> get props => [id, fullname, email, avatar];
}
