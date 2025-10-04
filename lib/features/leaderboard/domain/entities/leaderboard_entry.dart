import '../enums/leaderboard_category.dart';
import 'friend.dart';

class LeaderboardEntry {
  final Friend friend;
  final LeaderboardCategory category;
  final double value; // e.g., kcal, km, days

  const LeaderboardEntry({
    required this.friend,
    required this.category,
    required this.value,
  });
}
