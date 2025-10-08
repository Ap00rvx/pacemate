import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/entities/friend.dart';
import '../../domain/enums/leaderboard_category.dart';
import '../../domain/repositories/leaderboard_repository.dart';
import '../../domain/entities/leaderboard_models.dart';

part 'leaderboard_state.dart';

class LeaderboardCubit extends Cubit<LeaderboardState> {
  LeaderboardCubit(this._repo) : super(const LeaderboardState.initial());

  final LeaderboardRepository _repo;

  Future<void> load() async {
    emit(state.copyWith(loading: true));
    // Fetch real leaderboard from backend using current period
    final data = await _repo.fetchLeaderboard(period: state.period);
    // For backward-compat UI tabs, fill monthlyDistance from global leaderboard
    final map = <LeaderboardCategory, List<LeaderboardEntry>>{};
    map[LeaderboardCategory.monthlyDistance] = data.globalLeaderboard
        .map(
          (e) => LeaderboardEntry(
            friend: Friend(
              id: e.user.id,
              name: e.user.name,
              avatarUrl: e.user.avatarUrl,
            ),
            category: LeaderboardCategory.monthlyDistance,
            value: e.distanceKm,
          ),
        )
        .toList();

    // Pick topper based on available map
    final topper = _pickTopper(map);
    emit(
      state.copyWith(
        loading: false,
        byCategory: map,
        topper: topper,
        message: _motivation(topper),
        data: data,
      ),
    );
  }

  void setPeriod(String period) {
    if (period == state.period) return;
    emit(state.copyWith(period: period));
    // fire and forget; UI shows loading state
    load();
  }

  LeaderboardEntry? _pickTopper(
    Map<LeaderboardCategory, List<LeaderboardEntry>> m,
  ) {
    LeaderboardEntry? best;
    for (final list in m.values) {
      if (list.isEmpty) continue;
      final top = list.first;
      if (best == null || top.value > best.value) best = top;
    }
    return best;
  }

  String _motivation(LeaderboardEntry? top) {
    if (top == null) return 'Keep moving—your best is yet to come!';
    return switch (top.category) {
      LeaderboardCategory.calories =>
        "${top.friend.name} is on fire! Push a bit harder today 🔥",
      LeaderboardCategory.streak =>
        "${top.friend.name}'s consistency wins. One day at a time. You got this.",
      LeaderboardCategory.monthlyDistance =>
        "${top.friend.name} is going the distance—add one more km today!",
    };
  }
}
