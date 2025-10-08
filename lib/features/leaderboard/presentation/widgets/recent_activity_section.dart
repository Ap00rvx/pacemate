
import 'package:flutter/material.dart';

class RecentActivitiesSection extends StatelessWidget {
  const RecentActivitiesSection({
    required this.title,
    required this.activities,
  });
  final String title;
  final List activities; // List<Activity>

  String _formatDistance(double meters) =>
      '${(meters / 1000).toStringAsFixed(2)} km';
  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        ...activities.take(5).map((a) {
          final user = a.user;
          final avatar = user?.avatar;
          final name = user?.fullname ?? '';
          final distance = _formatDistance(a.distance as double);
          final duration = _formatDuration(a.duration as int);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: (avatar != null && avatar.isNotEmpty)
                      ? NetworkImage(avatar)
                      : null,
                  child: (avatar == null || avatar.isEmpty)
                      ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?')
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '$name • $distance',
                    style: theme.textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(duration, style: theme.textTheme.bodyMedium),
              ],
            ),
          );
        }),
      ],
    );
  }
}
