import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pacemate/core/theme/app_theme.dart';
import 'package:pacemate/features/social/presentation/bloc/social_bloc.dart';
import 'package:pacemate/features/social/presentation/widgets/activity_stats.dart';
import 'package:pacemate/features/social/presentation/widgets/header.dart';

class ViewProfilePage extends StatefulWidget {
  const ViewProfilePage({super.key, required this.userId});
  final String userId;

  @override
  State<ViewProfilePage> createState() => _ViewProfilePageState();
}

class _ViewProfilePageState extends State<ViewProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<SocialBloc>().add(ViewUserProfileEvent(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: BlocBuilder<SocialBloc, SocialState>(
        builder: (context, state) {
          if (state.profileStatus == SocialStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          final u = state.viewed;
          if (u == null) {
            return const Center(child: Text('User not found'));
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeaderSection(user: u, isFriend: state.isFriend),
              ActivityStats(user: u),
              SizedBox(height: 20),
              if (state.isFriend)
                Container()
              else
                Column(
                  children: [
                    Row(
                      spacing: 10,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_month,
                          color: AppTheme.primaryLight,
                          size: 16,
                        ),
                        Text(
                          "Joined on ${u.createdAt?.toLocal().toString().split(' ').first}",
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.primaryLight),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const Divider(),
                    const SizedBox(height: 15),
                    Center(
                      child: Text(
                        "To View Full Profile,\n Add ${u.fullname} as Friend",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.muted,
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}
