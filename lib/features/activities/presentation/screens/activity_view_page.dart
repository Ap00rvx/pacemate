import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:pacemate/features/activities/presentation/bloc/activity_bloc.dart';

class ActivityViewPage extends StatefulWidget {
  const ActivityViewPage({super.key, required this.activityId});
  final String activityId;

  @override
  State<ActivityViewPage> createState() => _ActivityViewPageState();
}

class _ActivityViewPageState extends State<ActivityViewPage> {
  final _mapController = MapController();

  @override
  void initState() {
    super.initState();
    context.read<ActivityBloc>().add(
      FetchActivityByIdEvent(widget.activityId, isPublic: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activity')),
      body: BlocBuilder<ActivityBloc, ActivityState>(
        builder: (context, state) {
          if (state.detailStatus == ActivityStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          final a = state.activity;
          if (a == null) return const Center(child: Text('Not found'));
          final poly = Polyline(
            points: a.route,
            strokeWidth: 4,
            color: Theme.of(context).colorScheme.primary,
          );
          final center = a.route.isNotEmpty
              ? a.route.first
              : const LatLng(40.7128, -74.0060);
          return ListView(
            children: [
              SizedBox(
                height: 260,
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(initialCenter: center, initialZoom: 17),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.pacemate.app',
                    ),
                    if (poly.points.isNotEmpty)
                      PolylineLayer(polylines: [poly]),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.type.name.toUpperCase(),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 16,
                      runSpacing: 12,
                      children: [
                        _kv(
                          context,
                          'Distance',
                          '${(a.distance / 1000).toStringAsFixed(2)} km',
                        ),
                        _kv(context, 'Duration', _fmtDuration(a.duration)),
                        _kv(context, 'Calories', '${a.calories} kcal'),
                        if (a.averagePace != null)
                          _kv(
                            context,
                            'Pace',
                            '${a.averagePace!.toStringAsFixed(2)} min/km',
                          ),
                        if (a.elevation != null)
                          _kv(
                            context,
                            'Elevation',
                            '${a.elevation!.toStringAsFixed(0)} m',
                          ),
                        if (a.feeling != null)
                          _kv(context, 'Feeling', a.feeling!),
                        if (a.weather != null)
                          _kv(context, 'Weather', a.weather!),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (a.image != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(a.image!, fit: BoxFit.cover),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _kv(BuildContext context, String k, String v) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(k, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 4),
        Text(v, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }

  String _fmtDuration(int s) {
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    final sec = s % 60;
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m ${sec}s';
    return '${sec}s';
  }
}
