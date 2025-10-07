part of 'leaderboard_cubit.dart';

class LeaderboardState extends Equatable {
  final bool loading;
  final Map<LeaderboardCategory, List<LeaderboardEntry>> byCategory;
  final LeaderboardEntry? topper;
  final String message;
  final LeaderboardData? data;

  const LeaderboardState({
    required this.loading,
    required this.byCategory,
    required this.topper,
    required this.message,
    required this.data,
  });

  const LeaderboardState.initial()
    : loading = false,
      byCategory = const {},
      topper = null,
      message = '',
      data = null;

  LeaderboardState copyWith({
    bool? loading,
    Map<LeaderboardCategory, List<LeaderboardEntry>>? byCategory,
    LeaderboardEntry? topper,
    String? message,
    LeaderboardData? data,
  }) {
    return LeaderboardState(
      loading: loading ?? this.loading,
      byCategory: byCategory ?? this.byCategory,
      topper: topper ?? this.topper,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }

  @override
  List<Object?> get props => [loading, byCategory, topper, message, data];
}
