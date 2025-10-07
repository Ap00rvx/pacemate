import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pacemate/core/theme/app_theme.dart';
import 'package:pacemate/features/social/presentation/bloc/social_bloc.dart';

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
      appBar: AppBar(title: const Text('Profile')),
      body: BlocBuilder<SocialBloc, SocialState>(
        builder: (context, state) {
          if (state.profileStatus == SocialStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          final u = state.viewed;
          if (u == null) {
            return const Center(child: Text('User not found'));
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppTheme.surfaceVariant,
                      backgroundImage:
                          (u.avatar != null && u.avatar!.isNotEmpty)
                          ? NetworkImage(u.avatar!)
                          : null,
                      child: (u.avatar == null || u.avatar!.isEmpty)
                          ? Text(
                              u.fullname.isNotEmpty
                                  ? u.fullname[0].toUpperCase()
                                  : '',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primary,
                                fontSize: 24,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            u.fullname,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          if (u.location != null && u.location!.isNotEmpty)
                            Text(u.location!),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (state.isFriend)
                  const Text('You are friends')
                else
                  ElevatedButton(
                    onPressed: () {
                      context.read<SocialBloc>().add(AddFriendEvent(u.id));
                    },
                    child: const Text('Add friend'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
