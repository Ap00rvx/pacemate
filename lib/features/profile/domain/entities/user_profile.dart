import 'package:equatable/equatable.dart';

import 'activity_item.dart';

class UserProfile extends Equatable {
  final String id;
  final String name;
  final String? avatarUrl;
  final int followers;
  final int following;
  final DateTime joinedAt;
  final List<ActivityItem> recentActivities;

  const UserProfile({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.followers,
    required this.following,
    required this.joinedAt,
    required this.recentActivities,
  });

  String get initials {
    final parts = name.trim().split(RegExp(r"\s+"));
    if (parts.isEmpty) return '';
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  @override
  List<Object?> get props => [
    id,
    name,
    avatarUrl,
    followers,
    following,
    joinedAt,
    recentActivities,
  ];
}
