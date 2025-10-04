part of 'leaderboard_cubit.dart';

class LeaderboardState extends Equatable {
  final bool loading;
  final Map<LeaderboardCategory, List<LeaderboardEntry>> byCategory;
  final LeaderboardEntry? topper;
  final String message;

  const LeaderboardState({
    required this.loading,
    required this.byCategory,
    required this.topper,
    required this.message,
  });

  const LeaderboardState.initial()
    : loading = false,
      byCategory = const {},
      topper = null,
      message = '';

  LeaderboardState copyWith({
    bool? loading,
    Map<LeaderboardCategory, List<LeaderboardEntry>>? byCategory,
    LeaderboardEntry? topper,
    String? message,
  }) {
    return LeaderboardState(
      loading: loading ?? this.loading,
      byCategory: byCategory ?? this.byCategory,
      topper: topper ?? this.topper,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [loading, byCategory, topper, message];
}
