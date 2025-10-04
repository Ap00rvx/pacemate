import '../entities/leaderboard_entry.dart';
import '../enums/leaderboard_category.dart';

abstract class LeaderboardRepository {
  Future<List<LeaderboardEntry>> fetchCategory(LeaderboardCategory category);
}
