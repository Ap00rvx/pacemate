import '../domain/entities/leaderboard_entry.dart' as dom;
import '../domain/entities/friend.dart';
import '../domain/entities/leaderboard_models.dart';
import '../domain/enums/leaderboard_category.dart';
import '../domain/repositories/leaderboard_repository.dart';
import 'leaderboard_remote_datasource.dart';

class LeaderboardRepositoryImpl implements LeaderboardRepository {
  final LeaderboardRemoteDataSource remote;
  LeaderboardRepositoryImpl({required this.remote});

  @override
  Future<LeaderboardData> fetchLeaderboard({
    String period = 'week',
    int leaderboardLimit = 10,
    int activitiesLimit = 10,
  }) {
    return remote.fetchLeaderboard(
      period: period,
      leaderboardLimit: leaderboardLimit,
      activitiesLimit: activitiesLimit,
    );
  }

  // For backward compatibility with the existing Cubit/UI during refactor:
  @override
  Future<List<dom.LeaderboardEntry>> fetchCategory(
    LeaderboardCategory category,
  ) async {
    final data = await fetchLeaderboard();
    switch (category) {
      case LeaderboardCategory.monthlyDistance:
        // Use global leaderboard distances as a proxy; convert to entries
        return data.globalLeaderboard
            .map(
              (e) => dom.LeaderboardEntry(
                friend: Friend(
                  id: e.user.id,
                  name: e.user.name,
                  avatarUrl: e.user.avatarUrl,
                ),
                category: category,
                value: e.distanceKm,
              ),
            )
            .toList();
      case LeaderboardCategory.calories:
        // No calories info from backend response right now; return empty
        return <dom.LeaderboardEntry>[];
      case LeaderboardCategory.streak:
        // No streak info from backend response right now; return empty
        return <dom.LeaderboardEntry>[];
    }
  }
}
