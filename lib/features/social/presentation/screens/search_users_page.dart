import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pacemate/core/router/app_router.dart';
import 'package:pacemate/core/router/route_names.dart';
import 'package:pacemate/core/theme/app_theme.dart';
import 'package:pacemate/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pacemate/features/social/presentation/bloc/social_bloc.dart';

class SearchUsersPage extends StatefulWidget {
  const SearchUsersPage({super.key});

  @override
  State<SearchUsersPage> createState() => _SearchUsersPageState();
}

class _SearchUsersPageState extends State<SearchUsersPage> {
  final _controller = TextEditingController();
  Timer? _debounce;

  void _onChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      context.read<SocialBloc>().add(SearchUsersEvent(v.trim()));
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search users')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _controller,
              onChanged: _onChanged,
              decoration: InputDecoration(
                hintText: 'Search by name or email',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primaryLight),
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<SocialBloc, SocialState>(
              builder: (context, state) {
                if (state.searchStatus == SocialStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.searchStatus == SocialStatus.failure) {
                  return Center(
                    child: Text(state.message ?? 'Something went wrong'),
                  );
                }
                final users = state.results;
                if (users.isEmpty) {
                  return const Center(child: Text('No users found'));
                }
                return ListView.separated(
                  itemCount: users.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final u = users[i];
                    final currentUserId = context
                        .read<AuthBloc>()
                        .state
                        .user
                        ?.id;
                    if (u.id == currentUserId) {
                      return const SizedBox.shrink();
                    }

                    return ListTile(
                      leading: CircleAvatar(
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
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryLight,
                                ),
                              )
                            : null,
                      ),
                      title: Text(u.fullname),
                      subtitle: u.location != null
                          ? Text(u.location!)
                          : const SizedBox.shrink(),
                      onTap: () {
                        AppRouter.push(
                          RouteNames().viewProfile,
                          context,
                          queryParams: {'id': u.id},
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
