import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pacemate/core/widgets/logo_place.dart';
import 'package:pacemate/features/activities/presentation/bloc/activity_bloc.dart';
import 'package:pacemate/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pacemate/features/home/presentation/widgets/activity_button.dart';
import 'package:pacemate/features/home/presentation/widgets/daily_count_section.dart';
import 'package:pacemate/features/home/presentation/widgets/header.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  bool _fetched = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_fetched) {
      _fetched = true;
      // Load all-time stats and user activities for metrics
      context.read<ActivityBloc>().add(const FetchStatsEvent(period: 'all'));
      context.read<ActivityBloc>().add(
        const FetchUserActivitiesEvent(page: 1, limit: 50),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppLogo(),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications, size: 18),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, auth) {
          return BlocBuilder<ActivityBloc, ActivityState>(
            builder: (context, act) {
              final user = auth.user;
              final totalDistanceKm =
                  act.stats?.totalDistance ?? user?.totalDistance ?? 0.0;

              final now = DateTime.now();
              final startOfDay = DateTime(now.year, now.month, now.day);
              final startOfWeek = startOfDay.subtract(
                Duration(days: startOfDay.weekday % 7),
              ); // Sunday start
              // Aggregate today's distance (km) and calories, and weekly calories
              double todaysDistanceKm = 0.0;
              int todaysCalories = 0;
              final weekCals = List<int>.filled(7, 0);

              for (final a in act.activities) {
                final d = a.createdAt.toLocal();
                final isToday =
                    d.isAfter(startOfDay) || d.isAtSameMomentAs(startOfDay);
                if (isToday) {
                  todaysDistanceKm += a.distance / 1000.0;
                  todaysCalories += a.calories;
                }
                // Within this week range?
                final dayStart = DateTime(d.year, d.month, d.day);
                final withinWeek =
                    dayStart.isAfter(
                      startOfWeek.subtract(const Duration(days: 1)),
                    ) &&
                    dayStart.isBefore(startOfWeek.add(const Duration(days: 7)));
                if (withinWeek) {
                  final idx = dayStart.weekday % 7; // Sunday=0
                  weekCals[idx] += a.calories;
                }
              }

              // Determine today's index (Sunday=0..Saturday=6)
              final todayIdx = startOfDay.weekday % 7;

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    spacing: 12,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const HomeHeader(),
                      ActivityButton(
                        totalDistanceKm: double.parse(
                          (totalDistanceKm / 1000).toStringAsFixed(4),
                        ),
                      ),
                      DailyCountSection(
                        distanceKm: todaysDistanceKm,
                        calories: todaysCalories,
                        weeklyCalories: weekCals,
                        todayIndex: todayIdx,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
