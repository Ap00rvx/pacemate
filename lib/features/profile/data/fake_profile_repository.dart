import 'dart:math';

import '../../tracking/domain/enums/activity_type.dart';
import '../domain/entities/activity_item.dart';
import '../domain/entities/user_profile.dart';
import '../domain/repositories/profile_repository.dart';

class FakeProfileRepository implements ProfileRepository {
  final Random _rng = Random(42);

  @override
  Future<UserProfile> fetchProfile() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final now = DateTime.now();
    final activities = List.generate(8, (i) {
      final type = ActivityType.values[i % ActivityType.values.length];
      final distance = _round(_rng.nextDouble() * 8 + 2, 2); // 2-10 km
      final durationSec = (distance * (5.5 + _rng.nextDouble() * 2.5) * 60)
          .toInt();
      final calories = (distance * (60 + _rng.nextInt(60))).toInt();
      return ActivityItem(
        id: 'act_$i',
        dateTime: now.subtract(Duration(days: i * 2 + _rng.nextInt(2))),
        type: type,
        distanceKm: distance,
        durationSeconds: durationSec,
        calories: calories,
      );
    });

    return UserProfile(
      id: 'u_1',
      name: 'Alex Johnson',
      avatarUrl: null,
      followers: 128 + _rng.nextInt(200),
      following: 56 + _rng.nextInt(120),
      joinedAt: DateTime(
        now.year - 1,
        now.month,
        now.day,
      ).subtract(const Duration(days: 37)),
      recentActivities: activities,
    );
  }

  double _round(double v, int f) {
    final m = pow(10, f).toDouble();
    return (v * m).roundToDouble() / m;
  }
}
