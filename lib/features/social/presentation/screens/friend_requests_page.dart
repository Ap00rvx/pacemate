import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pacemate/core/router/app_router.dart';
import 'package:pacemate/core/router/route_names.dart';
import 'package:pacemate/core/theme/app_theme.dart';
import 'package:pacemate/features/social/presentation/bloc/social_bloc.dart';

class FriendRequestsPage extends StatefulWidget {
  const FriendRequestsPage({super.key});

  @override
  State<FriendRequestsPage> createState() => _FriendRequestsPageState();
}

class _FriendRequestsPageState extends State<FriendRequestsPage> {
  @override
  void initState() {
    super.initState();
    context.read<SocialBloc>().add(const FetchFriendRequestsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Friend requests')),
      body: BlocConsumer<SocialBloc, SocialState>(
        listenWhen: (p, c) => p.actionStatus != c.actionStatus,
        listener: (context, state) {
          if (state.actionStatus == SocialStatus.failure &&
              state.message != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message!)));
          }
        },
        builder: (context, state) {
          final loading =
              state.requestsStatus == SocialStatus.loading &&
              state.friendRequests.isEmpty;
          if (loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.requestsStatus == SocialStatus.failure) {
            return Center(
              child: Text(state.message ?? 'Failed to load requests'),
            );
          }
          final list = state.friendRequests;
          if (list.isEmpty) {
            return const Center(child: Text('No friend requests'));
          }
          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final u = list[i];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.surfaceVariant,
                  backgroundImage: (u.avatar != null && u.avatar!.isNotEmpty)
                      ? NetworkImage(u.avatar!)
                      : null,
                  child: (u.avatar == null || u.avatar!.isEmpty)
                      ? Text(
                          u.fullname.isNotEmpty
                              ? u.fullname[0].toUpperCase()
                              : '',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryLight,
                          ),
                        )
                      : null,
                ),
                title: Text(u.fullname),
                subtitle: u.location != null ? Text(u.location!) : null,
                onTap: () => AppRouter.push(
                  RouteNames().viewProfile,
                  context,
                  queryParams: {'id': u.id},
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Accept',
                      onPressed: () => context.read<SocialBloc>().add(
                        RespondFriendEvent(u.id, true),
                      ),
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                    ),
                    IconButton(
                      tooltip: 'Decline',
                      onPressed: () => context.read<SocialBloc>().add(
                        RespondFriendEvent(u.id, false),
                      ),
                      icon: const Icon(Icons.cancel, color: Colors.redAccent),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
