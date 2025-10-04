import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/enums/leaderboard_category.dart';
import '../../domain/repositories/leaderboard_repository.dart';

part 'leaderboard_state.dart';

class LeaderboardCubit extends Cubit<LeaderboardState> {
  LeaderboardCubit(this._repo) : super(const LeaderboardState.initial());

  final LeaderboardRepository _repo;

  Future<void> load() async {
    emit(state.copyWith(loading: true));
    final categories = LeaderboardCategory.values;
    final map = <LeaderboardCategory, List<LeaderboardEntry>>{};
    for (final c in categories) {
      map[c] = await _repo.fetchCategory(c);
    }
    final topper = _pickTopper(map);
    emit(
      state.copyWith(
        loading: false,
        byCategory: map,
        topper: topper,
        message: _motivation(topper),
      ),
    );
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
