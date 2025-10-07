import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:pacemate/core/router/app_router.dart';
import 'package:pacemate/core/router/route_names.dart';
import 'package:pacemate/core/theme/app_theme.dart';
import 'package:pacemate/core/utils/times_ago.dart';
import 'package:pacemate/features/activities/domain/entities/activity.dart';
import 'package:pacemate/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pacemate/features/home/presentation/bloc/bottom_nav_cubit.dart';
import 'package:latlong2/latlong.dart';

class FeedCard extends StatelessWidget {
  FeedCard({required this.activity, required this.onTap});
  final Activity activity;
  final VoidCallback onTap;

  double calculateMapZoomLevel(List<LatLng> points) {
    if (points.isEmpty) return 13;
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    final latDiff = maxLat - minLat;
    final lngDiff = maxLng - minLng;
    final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;

    print('Lat diff: $latDiff, Lng diff: $lngDiff, Max diff: $maxDiff');

    if (maxDiff < 0.005) return 19; // very close
    if (maxDiff < 0.02) return 16;
    if (maxDiff < 0.1) return 15;
    if (maxDiff < 0.5) return 14;
    if (maxDiff < 1.0) return 13;
    if (maxDiff < 2.0) return 12;
    if (maxDiff < 5.0) return 11;
    return 8; // far
  }

  final MapController mapController = MapController();

  String formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => onTap(),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // show user details
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          final auth = context.read<AuthBloc>();
                          final self = activity.userId == auth.state.user?.id;
                          if (self) {
                            context.read<BottomNavCubit>().setIndex(4);
                          } else if (activity.user != null) {
                            AppRouter.push(
                              RouteNames().viewProfile,
                              context,
                              queryParams: {'id': activity.user!.id},
                            );
                          }
                        },
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: AppTheme.surfaceVariant,
                          backgroundImage: activity.user?.avatar != null
                              ? NetworkImage(activity.user?.avatar ?? '')
                              : null,
                          child: activity.user?.avatar == null
                              ? Text(
                                  activity.user?.fullname.isNotEmpty == true
                                      ? activity.user!.fullname[0].toUpperCase()
                                      : '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryLight,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            final auth = context.read<AuthBloc>();
                            final self = activity.userId == auth.state.user?.id;
                            if (self) {
                              context.read<BottomNavCubit>().setIndex(4);
                            } else if (activity.user != null) {
                              AppRouter.push(
                                RouteNames().viewProfile,
                                context,
                                queryParams: {'id': activity.user!.id},
                              );
                            }
                          },
                          child: Text(
                            activity.user?.fullname ?? '',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                ),
                          ),
                        ),
                      ),
                      Text(
                        timesAgo(activity.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${activity.type.name.toUpperCase()} • ${(activity.distance / 1000).toStringAsFixed(2)} km',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.onBg,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            //show route on flutter map
            Container(
              height: 240,
              color: cs.primaryContainer,
              child: Center(
                child: FlutterMap(
                  mapController: mapController,

                  options: MapOptions(
                    initialZoom: calculateMapZoomLevel(
                      activity.route
                          .map((e) => LatLng(e.latitude, e.longitude))
                          .toList(),
                    ),
                    interactionOptions: InteractionOptions(
                      flags: InteractiveFlag.none,
                    ),
                    initialCenter: activity.route.isNotEmpty
                        ? LatLng(
                            activity.route[0].latitude,
                            activity.route[0].longitude,
                          )
                        : LatLng(0, 0),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.pacemate.pacemate',
                    ),
                    if (activity.route.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: activity.route
                                .map((e) => LatLng(e.latitude, e.longitude))
                                .toList(),
                            strokeWidth: 4,
                            color: AppTheme.primary,
                          ),
                        ],
                      ),
                    if (activity.route.isNotEmpty)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(
                              activity.route.first.latitude,
                              activity.route.first.longitude,
                            ),
                            width: 30,
                            height: 30,
                            child: Icon(
                              Icons.circle,
                              color: cs.primary,
                              size: 16,
                            ),
                          ),
                          Marker(
                            point: LatLng(
                              activity.route.last.latitude,
                              activity.route.last.longitude,
                            ),
                            width: 30,
                            height: 30,
                            child: Icon(
                              Icons.location_on,
                              color: cs.error,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.thumb_up_alt_outlined, size: 24),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Duration',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.muted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatDuration(activity.duration),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Pace',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.muted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${activity.averagePace.toString()} min/km',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Calories',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.muted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${activity.calories} kcal',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(color: cs.outline, thickness: 1),
          ],
        ),
      ),
    );
  }
}
