import '../entities/leaderboard_entry.dart';
import '../enums/leaderboard_category.dart';
import '../entities/leaderboard_models.dart';

abstract class LeaderboardRepository {
  Future<List<LeaderboardEntry>> fetchCategory(LeaderboardCategory category);
  Future<LeaderboardData> fetchLeaderboard({
    String period = 'week',
    int leaderboardLimit = 10,
    int activitiesLimit = 10,
  });
}
