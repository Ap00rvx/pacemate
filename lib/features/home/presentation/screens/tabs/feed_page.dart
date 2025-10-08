import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pacemate/core/router/app_router.dart';
import 'package:pacemate/core/router/route_names.dart';
import 'package:pacemate/core/theme/app_theme.dart';
import 'package:pacemate/features/activities/presentation/bloc/activity_bloc.dart';
import 'package:pacemate/features/home/presentation/widgets/feed_card.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final _controller = ScrollController();
  int _page = 1;
  final int _limit = 10;
  bool _loadingMore = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _refresh();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_loadingMore) return;
    if (!_controller.hasClients) return;
    final max = _controller.position.maxScrollExtent;
    final offset = _controller.offset;
    if (offset > max - 300) {
      _loadMore();
    }
  }

  Future<void> _refresh() async {
    _page = 1;
    context.read<ActivityBloc>().add(
      FetchFeedEvent(page: _page, limit: _limit),
    );
  }

  void _loadMore() {
    final state = context.read<ActivityBloc>().state;
    final hasNext = state.feedPagination?.hasNextPage ?? false;
    if (!hasNext) return;
    setState(() => _loadingMore = true);
    _page += 1;
    context.read<ActivityBloc>().add(
      FetchFeedEvent(page: _page, limit: _limit),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ActivityBloc, ActivityState>(
        listener: (context, state) {
          if (state.feedStatus != ActivityStatus.loading) {
            _loadingMore = false;
          }
        },
        builder: (context, state) {
          final items = state.feed;
          final isLoading =
              state.feedStatus == ActivityStatus.loading && items.isEmpty;

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (items.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: CustomScrollView(
                controller: _controller,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    expandedHeight: 200,
                    actionsPadding: const EdgeInsets.only(right: 8),
                    title: const Text(
                      'Recent Activities',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.person_add_alt_1_outlined),
                        onPressed: () {
                          AppRouter.push(RouteNames().searchUsers, context);
                        },
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Iconsax.notification4),
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 24.0,
                        ),
                        alignment: Alignment.bottomLeft,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primary.withAlpha(100),
                              AppTheme.primary.withAlpha(70),
                              AppTheme.primary.withAlpha(0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [const SizedBox(height: 10)],
                        ),
                      ),
                      collapseMode: CollapseMode.parallax,
                    ),
                    elevation: 4,
                    shadowColor: Colors.black26,
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Image.asset("assets/images/no_feed.jpg"),
                            Text(
                              'No activities from people you follow yet.\nFind and follow friends to see their activities here!',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                    fontSize: 16,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: CustomScrollView(
              controller: _controller,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 200,
                  actionsPadding: const EdgeInsets.only(right: 8),
                  title: const Text(
                    'Recent Activities',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.person_add_alt_1_outlined),
                      onPressed: () {
                        AppRouter.push(RouteNames().searchUsers, context);
                      },
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Iconsax.notification4),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 24.0,
                      ),
                      alignment: Alignment.bottomLeft,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primary.withAlpha(100),
                            AppTheme.primary.withAlpha(100),
                            AppTheme.primary.withAlpha(0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const SizedBox(height: 10),
                          const Text(
                            'ONE ACTIVITY TODAY TAKES YOU ONE STEP CLOSER TO YOUR GOAL 🔥',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              height: 1.4,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    collapseMode: CollapseMode.parallax,
                  ),
                  elevation: 4,
                  shadowColor: Colors.black26,
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, i) {
                      final a = items[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: FeedCard(
                          activity: a,
                          onTap: () => AppRouter.push(
                            RouteNames().activityDetail,
                            context,
                            queryParams: {'id': a.id},
                          ),
                        ),
                      );
                    }, childCount: items.length),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Builder(
                    builder: (context) {
                      final hasNext =
                          state.feedPagination?.hasNextPage ?? false;
                      if (!hasNext) return const SizedBox.shrink();
                      return const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
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
