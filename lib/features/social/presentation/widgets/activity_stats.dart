import 'package:flutter/material.dart';
import 'package:pacemate/features/social/domain/entities/social_user.dart';

class ActivityStats extends StatefulWidget {
  const ActivityStats({super.key, required this.user});
  final SocialUser user;

  @override
  State<ActivityStats> createState() => _ActivityStatsState();
}

class _ActivityStatsState extends State<ActivityStats> {
  @override
  Widget build(BuildContext context) {
    // return grid with total distance, duraction and calories burned
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StatItem(
            label: 'Total Distance',
            value:
                '${(widget.user.totalDistance! / 1000).toStringAsFixed(1)} km',
            icon: Icons.directions_run,
          ),
          _StatItem(
            label: 'Total Duration',
            value: _formatDuration(widget.user.totalTime ?? 0),
            icon: Icons.timer,
          ),
          _StatItem(
            label: 'Calories Burned',
            value: '${widget.user.totalCalories} kcal',
            icon: Icons.local_fire_department,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(
              context,
            ).textTheme.bodySmall?.color?.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}

String _formatDuration(int totalSeconds) {
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;
  if (hours > 0) {
    return '${hours}h ${minutes}m';
  } else if (minutes > 0) {
    return '${minutes}m ${seconds}s';
  } else {
    return '${seconds}s';
  }
}
