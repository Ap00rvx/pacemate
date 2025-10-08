import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/web.dart';
import 'package:pacemate/core/theme/app_theme.dart';
import 'package:pacemate/features/activities/domain/entities/activity.dart';
import 'package:pacemate/features/social/presentation/bloc/social_bloc.dart';
import 'package:pacemate/features/social/presentation/widgets/activity_stats.dart'
    as social_stats;
import 'package:pacemate/features/social/presentation/widgets/header.dart';
import 'package:pacemate/features/activities/presentation/bloc/activity_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:pacemate/features/social/domain/entities/social_user.dart';

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
          return _FriendProfileBody(user: u, isFriend: state.isFriend);
        },
      ),
    );
  }
}

class _FriendProfileBody extends StatefulWidget {
  const _FriendProfileBody({required this.user, required this.isFriend});
  final SocialUser user;
  final bool isFriend;

  @override
  State<_FriendProfileBody> createState() => _FriendProfileBodyState();
}

class _FriendProfileBodyState extends State<_FriendProfileBody> {
  int _page = 1;
  final int _limit = 15;
  final _scrollController = ScrollController();
  bool _listenerAttached = false;

  @override
  void initState() {
    super.initState();
    if (widget.isFriend) {
      _fetchFirstPage();
      _attachScrollListener();
    }
  }

  @override
  void dispose() {
    if (_listenerAttached) {
      _scrollController.removeListener(_onScroll);
    }
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _FriendProfileBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If friendship status just turned true, start fetching and attach listener
    if (!oldWidget.isFriend && widget.isFriend) {
      _page = 1;
      _fetchFirstPage(reset: true);
      _attachScrollListener();
    }
  }

  void _onScroll() {
    final st = context.read<ActivityBloc>().state;
    final pag = st.friendPagination;
    if (pag?.hasNextPage == true &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
      _page += 1;
      context.read<ActivityBloc>().add(
        FetchFriendActivitiesEvent(widget.user.id, page: _page, limit: _limit),
      );
    }
  }

  void _fetchFirstPage({bool reset = false}) {
    context.read<ActivityBloc>().add(
      FetchFriendActivitiesEvent(widget.user.id, page: _page, limit: _limit),
    );
  }

  void _attachScrollListener() {
    if (_listenerAttached) return;
    _scrollController.addListener(_onScroll);
    _listenerAttached = true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivityBloc, ActivityState>(
      builder: (context, astate) {
        if (!widget.isFriend) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeaderSection(user: widget.user, isFriend: widget.isFriend),
              social_stats.ActivityStats(user: widget.user),
              const SizedBox(height: 20),
              Row(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.calendar_month,
                    color: AppTheme.primaryLight,
                    size: 16,
                  ),
                  Text(
                    "Joined on ${widget.user.createdAt?.toLocal().toString().split(' ').first}",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              const Divider(),
              const SizedBox(height: 15),
              Center(
                child: Text(
                  "To View Full Profile,\n Add ${widget.user.fullname} as Friend",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.muted,
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        }

        final items = astate.friendActivities;
        return CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: HeaderSection(
                user: widget.user,
                isFriend: widget.isFriend,
              ),
            ),
            if (items.isEmpty && astate.status == ActivityStatus.loading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (items.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('No activities yet')),
              )
            else ...[
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    social_stats.ActivityStats(user: widget.user),
                    const SizedBox(height: 12),
                    Text(
                      "Joined on ${widget.user.createdAt?.toLocal().toString().split(' ').first}",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.primaryLight,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Divider(color: AppTheme.muted.withOpacity(0.3)),
                    const SizedBox(height: 10),
                    Text(
                      "Recent Activities",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.onBg,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.9,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final a = items[index];
                    return _ActivityMiniTile(key: ValueKey(a.id), activity: a);
                  }, childCount: items.length),
                ),
              ),
              SliverToBoxAdapter(
                child: Visibility(
                  visible: astate.friendPagination?.hasNextPage == true,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _ActivityMiniTile extends StatelessWidget {
  const _ActivityMiniTile({Key? key, required this.activity}) : super(key: key);
  final Activity activity; // ent.Activity

  @override
  Widget build(BuildContext context) {
    Logger().d(activity);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final distanceKm = (activity.distance) / 1000.0;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.primary.withOpacity(0.06)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  color: cs.primaryContainer,
                  child: _MiniMapPolyline(points: activity.route),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${activity.type.name.toUpperCase()} • ${distanceKm.toStringAsFixed(2)} km • ${activity.duration ~/ 60} min',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
            Text(
              '${activity.createdAt.toLocal().toString().split(' ').first} • ${activity.createdAt.toLocal().toString().split(' ').last.split(".")[0].split(":")[0]}:${activity.createdAt.toLocal().toString().split(' ').last.split(".")[0].split(":")[1]}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: AppTheme.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniMapPolyline extends StatelessWidget {
  const _MiniMapPolyline({required this.points});
  final List points; // List<LatLng>
  double getZoomLevel() {
    if (points.isEmpty) return 20;
    if (points.length <= 10) return 18;
    if (points.length <= 50) return 16;
    if (points.length <= 100) return 14;
    return 12;
  }

  @override
  Widget build(BuildContext context) {
    final pts = points.cast<LatLng>();
    return FlutterMap(
      key: pts.isNotEmpty
          ? ValueKey(
              '${pts.first.latitude}_${pts.first.longitude}_${pts.length}',
            )
          : null,
      options: MapOptions(
        initialZoom: pts.isEmpty ? 20 : getZoomLevel(),
        initialCenter: pts.isNotEmpty
            ? pts[(pts.length / 2).floor()]
            : const LatLng(0, 0),
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.none,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'com.pacemate.pacemate',
        ),
        if (pts.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(points: pts, strokeWidth: 2.5, color: AppTheme.primary),
            ],
          ),
      ],
    );
  }
}
