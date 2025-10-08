import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pacemate/features/leaderboard/presentation/widgets/friends_leaderboard.dart';
import 'package:pacemate/features/leaderboard/presentation/widgets/global_leaderboard_section.dart';
import 'package:pacemate/features/leaderboard/presentation/widgets/my_summary_card.dart';
import 'package:pacemate/features/leaderboard/presentation/widgets/period_selector.dart';
import 'package:pacemate/features/leaderboard/presentation/widgets/recent_activity_section.dart';
import 'package:pacemate/features/leaderboard/presentation/widgets/topper_card.dart';
import '../../data/leaderboard_repository_impl.dart';
import '../../data/leaderboard_remote_datasource.dart';
import '../bloc/leaderboard_cubit.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Removed categories/tabbed view in favor of a clearer, scrollable layout with period selector.
    return BlocProvider(
      create: (_) => LeaderboardCubit(
        LeaderboardRepositoryImpl(remote: LeaderboardRemoteDataSource()),
      )..load(),
      child: BlocBuilder<LeaderboardCubit, LeaderboardState>(
        builder: (context, state) {
          if (state.loading && state.byCategory.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Scaffold(
            appBar: AppBar(title: const Text('Leaderboard')),
            body: Column(
              children: [
                // Header topper card uses overall topper/motivation
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TopperCard(
                    message: state.message,
                    topper: state.topper,
                  ),
                ),
                if (state.data?.mySummary != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: MySummaryCard(),
                  ),
                // Period selector
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: PeriodSelector(
                    period: state.period,
                    onChanged: (p) =>
                        context.read<LeaderboardCubit>().setPeriod(p),
                  ),
                ),
                if (state.data?.myGlobalRankDistance != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.secondaryContainer,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Iconsax.ranking, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'My global rank: ${state.data!.myGlobalRankDistance}',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => context.read<LeaderboardCubit>().load(),
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        if ((state.data?.friendsLeaderboard.isNotEmpty ??
                            false))
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                            child: FriendsLeaderboardSection(
                              entries: state.data!.friendsLeaderboard,
                            ),
                          ),
                        if ((state.data?.globalLeaderboard.isNotEmpty ?? false))
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: GlobalLeaderboardSection(
                              entries: state.data!.globalLeaderboard,
                            ),
                          ),
                        if ((state.data?.myRecentActivities.isNotEmpty ??
                            false))
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: RecentActivitiesSection(
                              title: 'My Recent Activities',
                              activities: state.data!.myRecentActivities,
                            ),
                          ),
                        if ((state.data?.friendsRecentActivities.isNotEmpty ??
                            false))
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: RecentActivitiesSection(
                              title: 'Friends\' Recent Activities',
                              activities: state.data!.friendsRecentActivities,
                            ),
                          ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
