import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pacemate/features/home/presentation/screens/tabs/map_screen.dart';

import '../../presentation/bloc/bottom_nav_cubit.dart';
import 'tabs/activity_page.dart';
import 'tabs/feed_page.dart';
import 'tabs/leaderboard_page.dart';
import '../../../profile/presentation/profile_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BottomNavCubit(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  static final _pages = <Widget>[
    const FeedPage(),
    const ActivityPage(),
    const MapScreen(),
    const LeaderboardPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BottomNavCubit, int>(
      builder: (context, index) {
        return Scaffold(
          body: IndexedStack(index: index, children: _pages),
          bottomNavigationBar: NavigationBar(
            height: 70,
            selectedIndex: index,
            onDestinationSelected: context.read<BottomNavCubit>().setIndex,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.festival_rounded),
                label: 'Feed',
              ),
              NavigationDestination(
                icon: Icon(Icons.rocket_launch_outlined),
                label: 'Activity',
              ),
              NavigationDestination(
                icon: Icon(Icons.directions_run),
                label: 'Run',
              ),
              NavigationDestination(icon: Icon(Iconsax.cup), label: 'Leaders'),
              NavigationDestination(
                icon: Icon(Icons.person_outline_sharp),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}
