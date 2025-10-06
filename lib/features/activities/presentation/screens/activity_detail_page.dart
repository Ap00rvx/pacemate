import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:pacemate/features/activities/presentation/bloc/activity_bloc.dart';
import 'package:pacemate/features/auth/presentation/bloc/auth_bloc.dart';

class ActivityDetailPage extends StatefulWidget {
  const ActivityDetailPage({super.key, required this.activityId});
  final String? activityId;

  @override
  State<ActivityDetailPage> createState() => _ActivityDetailPageState();
}

class _ActivityDetailPageState extends State<ActivityDetailPage> {
  final _mapController = MapController();

  @override
  void initState() {
    super.initState();
    final id = widget.activityId;
    if (id != null && id.isNotEmpty) {
      context.read<ActivityBloc>().add(FetchActivityByIdEvent(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Detail'),
        leading: IconButton(
          onPressed: () {
            context.pop();
            context.read<AuthBloc>().add(GetProfileEvent());
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: BlocBuilder<ActivityBloc, ActivityState>(
        builder: (context, state) {
          if (state.detailStatus == ActivityStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          final a = state.activity;
          if (a == null) {
            return const Center(child: Text('Activity not found'));
          }
          final polyline = Polyline(
            points: a.route.isNotEmpty ? a.route : <LatLng>[],
            color: Theme.of(context).colorScheme.primary,
            strokeWidth: 4,
          );
          final initialCenter = a.route.isNotEmpty
              ? a.route.first
              : const LatLng(40.7128, -74.0060);

          return ListView(
            children: [
              SizedBox(
                height: 260,
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: initialCenter,
                    initialZoom: 18,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.pacemate.app',
                    ),
                    if (polyline.points.isNotEmpty)
                      PolylineLayer(polylines: [polyline]),
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
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 450;
                        final cols = isWide ? 3 : 2;
                        final stats = <(String, String)>[
                          (
                            'Distance',
                            '${(a.distance / 1000).toStringAsFixed(2)} km',
                          ),
                          ('Duration', _fmtDuration(a.duration)),
                          ('Calories', '${a.calories} kcal'),
                          if (a.averagePace != null)
                            ('Pace', _fmtPace(a.averagePace!)),
                          if (a.elevation != null)
                            (
                              'Elevation',
                              '${a.elevation!.toStringAsFixed(0)} m',
                            ),
                        ];
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: stats.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: cols,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                                childAspectRatio: 2.0,
                              ),
                          itemBuilder: (context, i) {
                            final (label, value) = stats[i];
                            return _StatCard(label: label, value: value);
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    if (a.feeling != null) Text('Feeling: ${a.feeling}'),
                    if (a.weather != null) Text('Weather: ${a.weather}'),
                    const SizedBox(height: 8),
                    Text(
                      'Started at: ${a.createdAt.toLocal().hour}${a.createdAt.toLocal().minute} hours',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              // TODO: Implement share (e.g., share_plus)
                              final snack = SnackBar(
                                content: Text('Share coming soon'),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(snack);
                            },
                            child: const Text('Share'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              context.read<AuthBloc>().add(GetProfileEvent());
                            },
                            child: const Text('Continue'),
                          ),
                        ),
                      ],
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

  String _fmtDuration(int sec) {
    final h = (sec ~/ 3600).toString().padLeft(2, '0');
    final m = ((sec % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String _fmtPace(double minPerKm) {
    final m = minPerKm.floor();
    final s = ((minPerKm - m) * 60).round().toString().padLeft(2, '0');
    return '$m:$s/km';
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.outlineVariant),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 26,
            ),
          ),
        ],
      ),
    );
  }
}
