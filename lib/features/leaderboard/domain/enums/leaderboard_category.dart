enum LeaderboardCategory { calories, streak, monthlyDistance }

extension LeaderboardCategoryX on LeaderboardCategory {
  String get label => switch (this) {
    LeaderboardCategory.calories => 'Most Calories Burned',
    LeaderboardCategory.streak => 'Highest Streak',
    LeaderboardCategory.monthlyDistance => 'Most Distance (This Month)',
  };
}
