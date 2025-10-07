import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pacemate/core/router/app_router.dart';
import 'package:pacemate/core/router/route_names.dart';
import 'package:pacemate/core/theme/app_theme.dart';
import 'package:pacemate/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pacemate/features/profile/presentation/widgets/activities_section.dart';
import 'package:pacemate/features/activities/presentation/bloc/activity_bloc.dart';
import 'package:pacemate/features/profile/presentation/widgets/header_section.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ProfileView();
  }
}

class _ProfileView extends StatefulWidget {
  const _ProfileView();

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  @override
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const GetProfileEvent());
  }
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state.status == AuthStatus.error) {
          return Column(
            spacing: 30,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                state.message ?? 'An error occurred',
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              // retry button
              ElevatedButton(
                onPressed: () {
                  context.read<AuthBloc>().add(const GetProfileEvent());
                },
                child: const Text('Retry'),
              ),
            ],
          );
        }
        if (state.status == AuthStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == AuthStatus.authenticated && state.profile != null) {
          final u = state.profile!;
          return Scaffold(
            body: RefreshIndicator(
              onRefresh: () async {
                context.read<AuthBloc>().add(const GetProfileEvent());
                // Also refresh activities and stats for the profile screen
                context.read<ActivityBloc>().add(
                  const FetchUserActivitiesEvent(page: 1, limit: 10),
                );
                context.read<ActivityBloc>().add(
                  const FetchStatsEvent(period: 'all'),
                );
              },
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    HeaderSection(user: u),
                    ActivitiesSection(user: state.profile!),
                    const SizedBox(height: 12),
                    LogoutButton(),
                  ],
                ),
              ),
            ),
          );
        }
        // Not authenticated or no user yet
        return const Center(child: Text('Sign in to view your profile'));
      },
    );
  }
}

class LogoutButton extends StatelessWidget {
  LogoutButton({super.key});

  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: AppTheme.onBg,
            ),
            onPressed: () async {
              context.read<AuthBloc>().add(LogoutEvent());
              Navigator.of(context).pop();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (BuildContext context, AuthState state) {
        if (state.status == AuthStatus.unauthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logged out successfully')),
          );
          // Navigate to home page or login page
          AppRouter.go(RouteNames().onboarding, context);
        }
      },
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: AppTheme.onBg,
            fixedSize: Size(double.infinity, 48),
          ),
          onPressed: () {
            showLogoutDialog(context);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 10,
            children: [Text('Logout'), Icon(Icons.logout, size: 20)],
          ),
        ),
      ),
    );
  }
}
