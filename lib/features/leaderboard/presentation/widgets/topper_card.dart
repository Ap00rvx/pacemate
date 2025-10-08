
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:logger/logger.dart';
import 'package:pacemate/features/leaderboard/domain/entities/leaderboard_entry.dart';
import 'package:pacemate/features/leaderboard/domain/enums/leaderboard_category.dart';

class TopperCard extends StatelessWidget {
  const TopperCard({required this.message, required this.topper});
  final String message;
  final LeaderboardEntry? topper;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Logger().i(topper?.toJson());
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

