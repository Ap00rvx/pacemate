import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:iconsax/iconsax.dart';
import 'package:latlong2/latlong.dart';
import 'package:pacemate/core/theme/app_theme.dart';
import 'package:pacemate/core/widgets/logo_place.dart';

import '../../../../tracking/domain/entities/tracking_point.dart';
import '../../../../tracking/domain/enums/activity_type.dart';
import '../../../../tracking/presentation/bloc/location_cubit.dart';
import '../../../../tracking/presentation/bloc/tracking_cubit.dart';
import '../../../../tracking/utils/geo_utils.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _mapController = MapController();
  final _location = LocationCubit(); // singleton
  LatLng? _lastConsumed;
  bool _mapReady = false;
  LatLng? _pendingTarget;
  double? _pendingZoom;

  @override
  void initState() {
    super.initState();
    _location.ensureReady();
  }

  double _currentZoomOrDefault() {
    try {
      return _mapReady ? _mapController.camera.zoom : 19.0;
    } catch (_) {
      return 19.0;
    }
  }

  void _safeMove(LatLng target, [double? zoom]) {
    if (_mapReady) {
      final z = zoom ?? _currentZoomOrDefault();
      _mapController.move(target, z);
    } else {
      _pendingTarget = target;
      _pendingZoom = zoom;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TrackingCubit>(create: (_) => TrackingCubit()),
        BlocProvider<LocationCubit>.value(value: _location),
      ],
      child: BlocListener<LocationCubit, LocationState>(
        listenWhen: (prev, curr) => curr.lastPosition != prev.lastPosition,
        listener: (context, locState) {
          final pos = locState.lastPosition;
          if (pos == null) return;

          final here = LatLng(pos.latitude, pos.longitude);
          final currentZoom = _currentZoomOrDefault();
          final z = currentZoom <= 2 ? 19.0 : currentZoom;
          _safeMove(here, z);

          final tracking = context.read<TrackingCubit>();
          if (tracking.state.isTracking && !tracking.state.isPaused) {
            final last = tracking.state.points.isNotEmpty
                ? tracking.state.points.last
                : null;
            final dist = last == null
                ? 0.0
                : haversineDistanceMeters(
                    lat1: last.latitude,
                    lon1: last.longitude,
                    lat2: here.latitude,
                    lon2: here.longitude,
                  );
            if (_lastConsumed == null || _lastConsumed != here) {
              tracking.addPoint(
                TrackingPoint(
                  latitude: here.latitude,
                  longitude: here.longitude,
                  timestamp: DateTime.now(),
                  distanceFromLast: dist,
                ),
              );
              _lastConsumed = here;
            }
          }
        },
        child: BlocBuilder<TrackingCubit, TrackingState>(
          builder: (context, state) {
            final cubit = context.read<TrackingCubit>();
            final locState = context.watch<LocationCubit>().state;

            final polyline = Polyline(
              points: [
                for (final p in state.points) LatLng(p.latitude, p.longitude),
              ],
              color: Theme.of(context).colorScheme.primary,
              strokeWidth: 4,
            );

            final start = state.points.isNotEmpty ? state.points.first : null;
            final end = state.points.isNotEmpty ? state.points.last : null;

            final initialCenter = locState.lastPosition != null
                ? LatLng(
                    locState.lastPosition!.latitude,
                    locState.lastPosition!.longitude,
                  )
                : end != null
                ? LatLng(end.latitude, end.longitude)
                : const LatLng(40.7128, -74.0060);

            if (locState.lastPosition != null && state.points.isEmpty) {
              final currentZoom = _currentZoomOrDefault();
              final z = currentZoom <= 2 ? 19.0 : currentZoom;
              _safeMove(
                LatLng(
                  locState.lastPosition!.latitude,
                  locState.lastPosition!.longitude,
                ),
                z,
              );
            }

            return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: AppLogo(),
                actions: [
                  PopupMenuButton<ActivityType>(
                    icon: const Icon(Iconsax.category),
                    onSelected: (t) {
                      if (!state.isTracking) {
                        cubit.start(t);
                        final pos = locState.lastPosition;
                        if (pos != null) {
                          cubit.addPoint(
                            TrackingPoint(
                              latitude: pos.latitude,
                              longitude: pos.longitude,
                              timestamp: DateTime.now(),
                              distanceFromLast: 0,
                            ),
                          );
                          _safeMove(LatLng(pos.latitude, pos.longitude), 19);
                          _lastConsumed = LatLng(pos.latitude, pos.longitude);
                        }
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: ActivityType.running,
                        child: Text('Running'),
                      ),
                      PopupMenuItem(
                        value: ActivityType.walking,
                        child: Text('Walking'),
                      ),
                    ],
                  ),
                ],
              ),
              body: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _StatItem(
                          label: 'Distance',
                          value:
                              '${(state.distanceMeters / 1000).toStringAsFixed(2)} km',
                        ),
                        _StatItem(
                          label: 'Duration',
                          value: _formatDuration(state.durationSeconds),
                        ),
                        _StatItem(
                          label: 'Pace',
                          value: _formatPace(
                            distanceMeters: state.distanceMeters,
                            durationSeconds: state.durationSeconds,
                          ),
                        ),
                        _StatItem(
                          label: 'Calories',
                          value: '${state.calories} kcal',
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        FlutterMap(
                          mapController: _mapController,

                          options: MapOptions(
                            onMapReady: () {
                              setState(() {
                                _mapReady = true;
                              });
                              if (_pendingTarget != null) {
                                final z =
                                    _pendingZoom ?? _mapController.camera.zoom;
                                _mapController.move(_pendingTarget!, z);
                                _pendingTarget = null;
                                _pendingZoom = null;
                              }
                            },
                            interactionOptions: InteractionOptions(
                              flags: InteractiveFlag.none,
                            ),
                            backgroundColor: AppTheme.bg,
                            initialCenter: initialCenter,
                            initialZoom: 19,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.pacemate.app',
                            ),
                            if (polyline.points.isNotEmpty)
                              PolylineLayer(polylines: [polyline]),
                            MarkerLayer(
                              markers: [
                                if (start != null)
                                  Marker(
                                    point: LatLng(
                                      start.latitude,
                                      start.longitude,
                                    ),
                                    width: 36,
                                    height: 36,
                                    child: const Icon(
                                      Icons.flag,
                                      color: Colors.green,
                                    ),
                                  ),
                                if (end != null)
                                  Marker(
                                    point: LatLng(end.latitude, end.longitude),
                                    width: 36,
                                    height: 36,
                                    child: const Icon(
                                      Icons.directions_run,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                if (locState.lastPosition != null &&
                                    !state.isTracking)
                                  Marker(
                                    point: LatLng(
                                      locState.lastPosition!.latitude,
                                      locState.lastPosition!.longitude,
                                    ),
                                    width: 36,
                                    height: 36,
                                    child: const Icon(
                                      Icons.my_location,
                                      color: Colors.blue,
                                    ),
                                  ),
                              ],
                            ),
                            if (!locState.ready)
                              const Align(
                                alignment: Alignment.topCenter,
                                child: Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      child: Text(
                                        'Location permission required to start tracking',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 20,
                          child: _ControlsBar(
                            isTracking: state.isTracking,
                            isPaused: state.isPaused,
                            onStart: () {
                              if (!locState.ready) {
                                _location.ensureReady();
                                return;
                              }
                              cubit.start(
                                state.activityType ?? ActivityType.running,
                              );
                              final pos = locState.lastPosition;
                              if (pos != null) {
                                cubit.addPoint(
                                  TrackingPoint(
                                    latitude: pos.latitude,
                                    longitude: pos.longitude,
                                    timestamp: DateTime.now(),
                                    distanceFromLast: 0,
                                  ),
                                );
                                _safeMove(
                                  LatLng(pos.latitude, pos.longitude),
                                  19,
                                );
                                _lastConsumed = LatLng(
                                  pos.latitude,
                                  pos.longitude,
                                );
                              }
                            },
                            onPause: () => cubit.pause(),
                            onResume: () => cubit.resume(),
                            onStop: () => cubit.stop(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatDuration(int sec) {
    final h = (sec ~/ 3600).toString().padLeft(2, '0');
    final m = ((sec % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String _formatPace({
    required double distanceMeters,
    required int durationSeconds,
  }) {
    if (distanceMeters <= 0 || durationSeconds <= 0) return '--:-- /km';
    final km = distanceMeters / 1000.0;
    final paceSecPerKm = durationSeconds / km;
    final m = (paceSecPerKm ~/ 60).toString().padLeft(2, '0');
    final s = (paceSecPerKm % 60).round().toString().padLeft(2, '0');
    return '$m:$s/km';
  }
}

class _ControlsBar extends StatelessWidget {
  const _ControlsBar({
    required this.isTracking,
    required this.isPaused,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onStop,
  });

  final bool isTracking;
  final bool isPaused;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cs.surface.withOpacity(0.95),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (!isTracking)
                _ControlButton(
                  icon: Iconsax.play,
                  label: 'Start Tracking',
                  color: cs.primary,
                  onTap: onStart,
                )
              else ...[
                if (!isPaused)
                  _ControlButton(
                    icon: Iconsax.pause,
                    label: 'Pause',
                    color: cs.tertiary,
                    onTap: onPause,
                  )
                else
                  _ControlButton(
                    icon: Iconsax.play,
                    label: 'Resume',
                    color: cs.primary,
                    onTap: onResume,
                  ),
                _ControlButton(
                  icon: Iconsax.stop,
                  label: 'Stop',
                  color: cs.error,
                  onTap: onStop,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final txt = Theme.of(context).textTheme.labelLarge;
    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: txt?.copyWith(color: color, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: theme.textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
