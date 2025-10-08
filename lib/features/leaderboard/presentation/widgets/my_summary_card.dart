
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pacemate/features/leaderboard/presentation/bloc/leaderboard_cubit.dart';

class MySummaryCard extends StatelessWidget {
  const MySummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.read<LeaderboardCubit>().state;
    final s = state.data!.mySummary!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    Widget stat(String label, String value) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
    String fmtKm(double km) => '${(km / 1000).toStringAsFixed(2)} km';
    String fmtMin(int secs) => '${(secs / 60).toStringAsFixed(0)} min';
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        border: Border.all(color: cs.primary.withOpacity(0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Summary',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                stat('Activities', s.totalActivities.toString()),
                stat('Distance', fmtKm(s.totalDistance)),
                stat('Time', fmtMin(s.totalDuration)),
                stat('Calories', s.totalCalories.toString()),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                stat('Avg Dist', fmtKm(s.averageDistance / 1000)),
                stat('Avg Time', fmtMin(s.averageDuration)),
                stat('Avg Cals', s.averageCalories.toStringAsFixed(1)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
