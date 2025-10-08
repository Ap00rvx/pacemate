import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:iconsax/iconsax.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:pacemate/core/theme/app_theme.dart';
import 'package:pacemate/core/widgets/app_loader.dart';
import 'package:pacemate/core/widgets/logo_place.dart';
import 'package:pacemate/core/router/app_router.dart';
import 'package:pacemate/core/router/route_names.dart';
import 'package:pacemate/features/activities/presentation/bloc/activity_bloc.dart';
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
  bool _shrinking = false;

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
      child: MultiBlocListener(
        listeners: [
          BlocListener<LocationCubit, LocationState>(
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
                      elevation: pos.altitude.toInt(),
                    ),
                  );
                  _lastConsumed = here;
                }
              }
            },
          ),
          BlocListener<ActivityBloc, ActivityState>(
            listenWhen: (prev, curr) => prev.mutateStatus != curr.mutateStatus,
            listener: (context, actState) {
              if (actState.mutateStatus == ActivityStatus.success &&
                  actState.lastMutated != null) {
                final id = actState.lastMutated!.id;
                final routes = RouteNames();
                AppRouter.push(
                  routes.activityDetail,
                  context,
                  queryParams: {'id': id},
                );
              }
            },
          ),
        ],
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
                centerTitle: false,
                title: AppLogo(),
                actions: const [],
              ),
              body: Column(
                children: [
                  Visibility(
                    visible: state.isTracking || state.points.isNotEmpty,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
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
                        if (kDebugMode)
                          Positioned(
                            left: 12,
                            top: 12,
                            child: _DebugOverlay(location: _location),
                          ),
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 20,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Visibility(
                                visible: !state.isTracking,
                                child: _TypeSelector(
                                  selected: state.activityType,
                                  onSelected: (t) {
                                    context.read<TrackingCubit>().setType(t);
                                  },
                                ),
                              ),
                              const SizedBox(height: 10),
                              _ControlsBar(
                                shrinking: _shrinking,
                                isTracking: state.isTracking,
                                isPaused: state.isPaused,
                                onStart: () async {
                                  if (!locState.ready) {
                                    _location.ensureReady();
                                    return;
                                  }
                                  setState(() => _shrinking = true);
                                  await Future.delayed(
                                    const Duration(milliseconds: 200),
                                  );
                                  cubit.start(
                                    state.activityType ?? ActivityType.running,
                                  );
                                  // Start background tracking service
                                  await _location.startBackgroundTracking();
                                  // If plugin didn't start, offer guidance
                                  try {
                                    final running = await _location
                                        .isBackgroundServiceRunning();
                                    if (!running && mounted) {
                                      await _showBgHelpDialog(context);
                                    }
                                  } catch (_) {}
                                  final pos = locState.lastPosition;
                                  if (pos != null) {
                                    cubit.addPoint(
                                      TrackingPoint(
                                        latitude: pos.latitude,
                                        longitude: pos.longitude,
                                        timestamp: DateTime.now(),
                                        distanceFromLast: 0,
                                        elevation: pos.altitude.toInt(),
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
                                  // expand back after starting
                                  await Future.delayed(
                                    const Duration(milliseconds: 150),
                                  );
                                  if (mounted)
                                    setState(() => _shrinking = false);
                                },
                                onPause: () => cubit.pause(),
                                onResume: () => cubit.resume(),
                                onStop: () async {
                                  // Persist activity via API and then stop locally
                                  final actBloc = context.read<ActivityBloc>();

                                  final s = cubit.state;
                                  if (s.activityType != null &&
                                      s.durationSeconds > 0 &&
                                      s.distanceMeters > 0) {
                                    actBloc.add(
                                      CreateActivityEvent(
                                        type: s.activityType!,
                                        duration: s.durationSeconds,
                                        distance: s.distanceMeters,
                                        calories: s.calories,
                                        route: [
                                          for (final p in s.points)
                                            (p.latitude, p.longitude),
                                        ],
                                        elevation:
                                            s.elevation?.toDouble() ?? 0.0,
                                      ),
                                    );
                                  }
                                  cubit.stop();
                                  // Stop background service
                                  await _location.stopBackgroundTracking();
                                },
                              ),
                            ],
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

  Future<void> _showBgHelpDialog(BuildContext context) async {
    // Gather current permission snapshot
    final snap = await _location.permissionSnapshot();
    if (!mounted) return;
    final cs = Theme.of(context).colorScheme;
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Enable reliable background tracking'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('To keep tracking with the screen locked, please:'),
              const SizedBox(height: 8),
              const Text('• Allow notifications'),
              const Text('• Allow location “All the time”'),
              const Text(
                '• Optionally disable battery optimization for Pacemate',
              ),
              const SizedBox(height: 12),
              Text(
                'Current permissions (Android):',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                'Notification: ${snap['notif'] ?? '-'}',
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                'Location:     ${snap['loc'] ?? '-'}',
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                'LocationAlways: ${snap['locAlways'] ?? '-'}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Open general app settings
                try {
                  await ph.openAppSettings();
                } catch (_) {}
              },
              child: const Text('App settings'),
            ),
            TextButton(
              onPressed: () async {
                // Open OS location settings
                try {
                  await geo.Geolocator.openLocationSettings();
                } catch (_) {}
              },
              child: const Text('Location settings'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                // Retry background start after user possibly changed settings
                await _location.startBackgroundTracking();
              },
              child: const Text('Retry'),
            ),
          ],
        );
      },
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

class _DebugOverlay extends StatefulWidget {
  const _DebugOverlay({required this.location});
  final LocationCubit location;

  @override
  State<_DebugOverlay> createState() => _DebugOverlayState();
}

class _DebugOverlayState extends State<_DebugOverlay> {
  bool _bgPlugin = false; // BackgroundLocator.isServiceRunning()
  bool _bgFlag = false; // LocationCubit.isBgActive
  String? _logPath;
  int _logSize = 0;
  Map<String, dynamic>? _permSnap;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    try {
      final bgPlugin = await widget.location.isBackgroundServiceRunning();
      final bgFlag = widget.location.isBgActive;
      final path = await widget.location.getRunLogPath();
      final snap = await widget.location.permissionSnapshot();
      int size = 0;
      if (path != null) {
        final f = File(path);
        if (await f.exists()) {
          size = await f.length();
        }
      }
      if (mounted) {
        setState(() {
          _bgPlugin = bgPlugin;
          _bgFlag = bgFlag;
          _logPath = path;
          _logSize = size;
          _permSnap = snap;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocationCubit>().state.lastPosition;
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: _refresh,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: DefaultTextStyle(
            style: const TextStyle(fontSize: 11, color: Colors.white),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('DBG: Tap to refresh'),
                Text('BG (plugin): ${_bgPlugin ? 'yes' : 'no'}'),
                Text('BG (flag):   ${_bgFlag ? 'yes' : 'no'}'),
                Text(
                  'Last pos: ${loc != null ? '${loc.latitude.toStringAsFixed(6)}, ${loc.longitude.toStringAsFixed(6)} (alt ${loc.altitude.toStringAsFixed(1)})' : 'null'}',
                ),
                Text('Log: ${_logPath ?? '-'}'),
                Text('Log size: ${_logSize} bytes'),
                if (_permSnap != null) ...[
                  const SizedBox(height: 4),
                  Text('Perm notif: ${_permSnap!['notif'] ?? '-'}'),
                  Text('Perm loc:   ${_permSnap!['loc'] ?? '-'}'),
                  Text('Perm always:${_permSnap!['locAlways'] ?? '-'}'),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeSelector extends StatelessWidget {
  const _TypeSelector({required this.selected, required this.onSelected});
  final ActivityType? selected;
  final ValueChanged<ActivityType> onSelected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final s = selected;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _TypeChip(
          label: 'Running',
          icon: Icons.directions_run,
          selected: s == ActivityType.running,
          onTap: () => onSelected(ActivityType.running),
          color: cs.primary,
        ),
        const SizedBox(width: 8),
        _TypeChip(
          label: 'Walking',
          icon: Icons.directions_walk,
          selected: s == ActivityType.walking,
          onTap: () => onSelected(ActivityType.walking),
          color: cs.tertiary,
        ),
        const SizedBox(width: 8),
        _TypeChip(
          label: 'Cycling',
          icon: Icons.directions_bike,
          selected: s == ActivityType.cycling,
          onTap: () => onSelected(ActivityType.cycling),
          color: cs.secondary,
        ),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.color,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = selected ? color.withOpacity(0.15) : cs.surface;
    final border = selected ? color : cs.outline.withOpacity(0.4);
    final fg = selected ? color : cs.onSurface;
    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.all(Radius.circular(24)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.all(Radius.circular(24)),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: fg,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlsBar extends StatelessWidget {
  const _ControlsBar({
    required this.shrinking,
    required this.isTracking,
    required this.isPaused,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onStop,
  });

  final bool shrinking;
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
          child: BlocBuilder<ActivityBloc, ActivityState>(
            builder: (context, state) {
              if (state.mutateStatus == ActivityStatus.loading) {
                return SizedBox(
                  height: 30,
                  width: 30,
                  child: Center(child: AppLoader()),
                );
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (!isTracking)
                    AnimatedScale(
                      scale: shrinking ? 0.88 : 1.0,
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeInOut,
                      child: _ControlButton(
                        icon: Iconsax.play,
                        label: 'Start Tracking',
                        color: cs.primary,
                        onTap: onStart,
                      ),
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
              );
            },
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
