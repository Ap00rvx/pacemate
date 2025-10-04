import 'dart:math';

import '../domain/entities/friend.dart';
import '../domain/entities/leaderboard_entry.dart';
import '../domain/enums/leaderboard_category.dart';
import '../domain/repositories/leaderboard_repository.dart';

class FakeLeaderboardRepository implements LeaderboardRepository {
  final _friends = const [
    Friend(id: 'u1', name: 'Aarav'),
    Friend(id: 'u2', name: 'Mia'),
    Friend(id: 'u3', name: 'Noah'),
    Friend(id: 'u4', name: 'Zara'),
    Friend(id: 'u5', name: 'Leo'),
  ];

  @override
  Future<List<LeaderboardEntry>> fetchCategory(
    LeaderboardCategory category,
  ) async {
    // Simulate slight async
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final rnd = Random(category.index + 7);
    List<LeaderboardEntry> list = [];

    switch (category) {
      case LeaderboardCategory.calories:
        list = _friends
            .map(
              (f) => LeaderboardEntry(
                friend: f,
                category: category,
                value: 1200 + rnd.nextInt(2200) + rnd.nextDouble(), // kcal
              ),
            )
            .toList();
        break;
      case LeaderboardCategory.streak:
        list = _friends
            .map(
              (f) => LeaderboardEntry(
                friend: f,
                category: category,
                value: 3 + rnd.nextInt(30).toDouble(), // days
              ),
            )
            .toList();
        break;
      case LeaderboardCategory.monthlyDistance:
        list = _friends
            .map(
              (f) => LeaderboardEntry(
                friend: f,
                category: category,
                value:
                    (20 + rnd.nextInt(180)).toDouble() + rnd.nextDouble(), // km
              ),
            )
            .toList();
        break;
    }

    list.sort((a, b) => b.value.compareTo(a.value));
    return list;
  }
}
