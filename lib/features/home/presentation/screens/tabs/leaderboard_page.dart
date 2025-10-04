import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../leaderboard/data/fake_leaderboard_repository.dart';
import '../../../../leaderboard/domain/entities/leaderboard_entry.dart';
import '../../../../leaderboard/domain/enums/leaderboard_category.dart';
import '../../../../leaderboard/presentation/bloc/leaderboard_cubit.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = LeaderboardCategory.values;
    return BlocProvider(
      create: (_) => LeaderboardCubit(FakeLeaderboardRepository())..load(),
      child: BlocBuilder<LeaderboardCubit, LeaderboardState>(
        builder: (context, state) {
          if (state.loading && state.byCategory.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Scaffold(
            appBar: AppBar(title: const Text('Leaderboard')),
            body: DefaultTabController(
              length: categories.length,
              child: Column(
                children: [
                  // Header topper card uses overall topper/motivation
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: _TopperCard(
                      message: state.message,
                      topper: state.topper,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TabBar(
                      isScrollable: true,
                      tabs: [for (final c in categories) Tab(text: c.label)],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: TabBarView(
                      children: [
                        for (final c in categories)
                          RefreshIndicator(
                            onRefresh: () =>
                                context.read<LeaderboardCubit>().load(),
                            child: _CategoryView(
                              category: c,
                              entries:
                                  (state.byCategory[c] ??
                                  const <LeaderboardEntry>[]),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TopperCard extends StatelessWidget {
  const _TopperCard({required this.message, required this.topper});
  final String message;
  final LeaderboardEntry? topper;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: cs.primary.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: cs.primary.withOpacity(0.2),
              child: const Icon(Iconsax.cup, color: Colors.amber, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topper == null ? 'No topper yet' : topper!.friend.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message.isEmpty
                        ? 'Keep moving—your best is yet to come!'
                        : message,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  if (topper != null)
                    _AnimatedValueBar(
                      factor: 1.0, // topper gets full bar
                      label: _formatByCategory(topper!.category, topper!.value),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryView extends StatelessWidget {
  const _CategoryView({required this.category, required this.entries});
  final LeaderboardCategory category;
  final List<LeaderboardEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (entries.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 200),
          Center(child: Text('No data yet')),
        ],
      );
    }

    final maxValue = entries.first.value;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: entries.length,
      itemBuilder: (context, i) {
        final e = entries[i];
        final factor = (e.value / maxValue).clamp(0.0, 1.0);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.08),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '#${i + 1}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          e.friend.name,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        _formatByCategory(category, e.value),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _AnimatedValueBar(factor: factor, label: ''),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedValueBar extends StatelessWidget {
  const _AnimatedValueBar({required this.factor, required this.label});
  final double factor; // 0..1
  final String label; // optional trailing label inside bar

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Stack(
          children: [
            Container(
              height: 8,
              width: width,
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.15),
                borderRadius: const BorderRadius.all(Radius.circular(6)),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              height: 8,
              width: width * factor,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [cs.primary, cs.secondary]),
                borderRadius: const BorderRadius.all(Radius.circular(6)),
              ),
            ),
          ],
        );
      },
    );
  }
}

String _formatByCategory(LeaderboardCategory c, double v) {
  switch (c) {
    case LeaderboardCategory.calories:
      return '${v.round()} kcal';
    case LeaderboardCategory.streak:
      return '${v.round()} days';
    case LeaderboardCategory.monthlyDistance:
      return '${v.toStringAsFixed(1)} km';
  }
}
