import 'package:flutter/material.dart';

class GlobalLeaderboardSection extends StatelessWidget {
  const GlobalLeaderboardSection({required this.entries});
  final List<dynamic> entries; // List<LeaderboardDistanceEntry>

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Global Leaderboard',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        ...entries.take(5).map((e) {
          final name = e.user.name as String;
          final valueStr = '${(e.distanceKm / 1000).toStringAsFixed(3)} km';
          final rank = e.rank;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                if (rank != null)
                  Text(
                    '#$rank',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                if (rank != null) const SizedBox(width: 8),
                Expanded(child: Text(name, style: theme.textTheme.bodyMedium)),
                Text(valueStr, style: theme.textTheme.bodyMedium),
              ],
            ),
          );
        }),
      ],
    );
  }
}
