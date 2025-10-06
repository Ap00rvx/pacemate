import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pacemate/core/router/app_router.dart';
import 'package:pacemate/core/router/route_names.dart';
import 'package:pacemate/core/theme/app_theme.dart';
import 'package:pacemate/features/activities/presentation/bloc/activity_bloc.dart';
import 'package:pacemate/features/auth/domain/model/user_model.dart';
import 'package:pacemate/features/tracking/domain/enums/activity_type.dart';

class ActivitiesSection extends StatefulWidget {
  const ActivitiesSection({super.key, required this.user});
  final UserModel user;

  @override
  State<ActivitiesSection> createState() => _ActivitiesSectionState();
}

class _ActivitiesSectionState extends State<ActivitiesSection> {
  bool _fetched = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_fetched) {
      _fetched = true;
      // Fetch all-time stats and user's recent activities
      context.read<ActivityBloc>().add(const FetchStatsEvent(period: 'all'));
      context.read<ActivityBloc>().add(
        const FetchUserActivitiesEvent(page: 1, limit: 10),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: BlocBuilder<ActivityBloc, ActivityState>(
        builder: (context, state) {
          final stats = state.stats;
          final totalDistanceKm =
              (stats?.totalDistance ?? widget.user.totalDistance) / 1000;
          final totalCalories =
              stats?.totalCalories ?? widget.user.totalCalories;
          final totalDurationSec =
              stats?.totalDuration ?? widget.user.totalTime;
          final bmiVal = widget.user.bmi;
          final bmiCategory = widget.user.bmiCategory;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your Stats', style: Theme.of(context).textTheme.titleLarge),

              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 500;
                  final cols = isWide ? 3 : 2;
                  final items = <(String, String, IconData)>[
                    (
                      'BMI',
                      '${bmiVal.toStringAsFixed(1)} ($bmiCategory)',
                      Iconsax.health,
                    ),
                    (
                      'Total Distance',
                      '${totalDistanceKm.toStringAsFixed(2)} km',
                      Iconsax.route_square,
                    ),
                    (
                      'Total Calories',
                      '${totalCalories.toString()} kcal',
                      Icons.local_fire_department,
                    ),
                    (
                      'Total Time',
                      _fmtDuration(totalDurationSec),
                      Iconsax.timer_1,
                    ),
                  ];

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 2.2,
                    ),
                    itemBuilder: (context, i) {
                      final (label, value, icon) = items[i];
                      return _StatTile(label: label, value: value, icon: icon);
                    },
                  );
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'Recent Activities',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      // manual refresh
                      context.read<ActivityBloc>().add(
                        const FetchUserActivitiesEvent(page: 1, limit: 10),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh',
                  ),
                ],
              ),
              if (state.status == ActivityStatus.loading &&
                  state.activities.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.activities.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'No activities yet. Start tracking from the map to create one!',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppTheme.muted),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.activities.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final a = state.activities[i];
                    IconData icon;
                    icon = switch (a.type) {
                      ActivityType.running => Icons.directions_run,
                      ActivityType.cycling => Icons.directions_bike,
                      ActivityType.walking => Icons.directions_walk,
                    };
                    return _ActivityTile(
                      icon: icon,
                      title:
                          a.type.name[0].toUpperCase() +
                          a.type.name.substring(1),
                      subtitle:
                          '${(a.distance / 1000).toStringAsFixed(2)} km • ${_fmtDuration(a.duration)}',
                      date: _fmtDate(a.createdAt),
                      onTap: () {
                        AppRouter.push(
                          RouteNames().activityDetail,
                          context,
                          queryParams: {'id': a.id},
                        );
                      },
                    );
                  },
                ),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }

  String _fmtDuration(int sec) {
    final h = (sec ~/ 3600);
    final m = ((sec % 3600) ~/ 60);
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  String _fmtDate(DateTime dt) {
    final d = dt.toLocal();
    final y = d.year.toString();
    final mo = d.month.toString().padLeft(2, '0');
    final da = d.day.toString().padLeft(2, '0');
    return '$y-$mo-$da';
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outlineVariant),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primary, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.title,
    required this.icon,
    required this.subtitle,
    required this.date,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final String date;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              date,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.muted),
            ),
          ],
        ),
      ),
    );
  }
}
