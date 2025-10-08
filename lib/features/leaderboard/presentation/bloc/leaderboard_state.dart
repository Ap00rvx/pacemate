part of 'leaderboard_cubit.dart';

class LeaderboardState extends Equatable {
  final bool loading;
  final Map<LeaderboardCategory, List<LeaderboardEntry>> byCategory;
  final LeaderboardEntry? topper;
  final String message;
  final LeaderboardData? data;
  final String period; // 'week' | 'month' | 'year' | 'all'

  const LeaderboardState({
    required this.loading,
    required this.byCategory,
    required this.topper,
    required this.message,
    required this.data,
    required this.period,
  });

  const LeaderboardState.initial()
    : loading = false,
      byCategory = const {},
      topper = null,
      message = '',
      data = null,
      period = 'week';

  LeaderboardState copyWith({
    bool? loading,
    Map<LeaderboardCategory, List<LeaderboardEntry>>? byCategory,
    LeaderboardEntry? topper,
    String? message,
    LeaderboardData? data,
    String? period,
  }) {
    return LeaderboardState(
      loading: loading ?? this.loading,
      byCategory: byCategory ?? this.byCategory,
      topper: topper ?? this.topper,
      message: message ?? this.message,
      data: data ?? this.data,
      period: period ?? this.period,
    );
  }

  @override
  List<Object?> get props => [
    loading,
    byCategory,
    topper,
    message,
    data,
    period,
  ];
}
