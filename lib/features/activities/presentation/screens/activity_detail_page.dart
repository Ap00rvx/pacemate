import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:pacemate/core/theme/app_theme.dart';
import 'package:pacemate/features/activities/presentation/bloc/activity_bloc.dart';
import 'package:pacemate/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pacemate/features/activities/domain/enums/feeling.dart';
import 'package:pacemate/features/activities/domain/enums/weather_condition.dart';
import 'package:pacemate/features/home/presentation/bloc/bottom_nav_cubit.dart';

class ActivityDetailPage extends StatefulWidget {
  const ActivityDetailPage({super.key, required this.activityId});
  final String? activityId;

  @override
  State<ActivityDetailPage> createState() => _ActivityDetailPageState();
}

class _ActivityDetailPageState extends State<ActivityDetailPage> {
  final _mapController = MapController();
  String? _imagePath;
  Feeling? _feeling;
  WeatherCondition? _weather;

  // show open camera or gallery to pick image bottom sheet
  void _showImagePickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.of(context).pop();
                final image = await ImagePicker().pickImage(
                  source: ImageSource.camera,
                );
                if (image != null) {
                  setState(() {
                    _imagePath = image.path;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Gallery'),
              onTap: () async {
                Navigator.of(context).pop();
                final image = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                );
                if (image != null) {
                  setState(() {
                    _imagePath = image.path;
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

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
            context.read<BottomNavCubit>().setIndex(0);
            context.read<AuthBloc>().add(GetProfileEvent());
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        actions: [
          BlocBuilder<ActivityBloc, ActivityState>(
            builder: (context, s) {
              final a = s.activity;
              final isLoading = s.mutateStatus == ActivityStatus.loading;
              return TextButton.icon(
                onPressed: (a == null || isLoading)
                    ? null
                    : () async {
                        final update = <String, dynamic>{};
                        if (_feeling != null) update['feeling'] = _feeling!.api;
                        if (_weather != null) update['weather'] = _weather!.api;
                        if (_imagePath != null) {
                          update['imageFilePath'] = _imagePath!;
                        }
                        if (update.isEmpty) return;
                        context.read<ActivityBloc>().add(
                          UpdateActivityEvent(a.id, update),
                        );
                      },
                icon: isLoading
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_alt),
                label: const Text('Save'),
              );
            },
          ),
        ],
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
                    _EditBar(
                      initialFeeling: a.feeling,
                      initialWeather: a.weather,
                      selectedFeeling: _feeling,
                      selectedWeather: _weather,
                      onPickImage: _showImagePickerBottomSheet,
                      onSelectFeeling: (f) => setState(() => _feeling = f),
                      onSelectWeather: (w) => setState(() => _weather = w),
                      imagePath: _imagePath,
                    ),
                    const SizedBox(height: 8),
                    if (a.feeling != null) Text('Feeling: ${a.feeling}'),
                    if (a.weather != null) Text('Weather: ${a.weather}'),
                    const SizedBox(height: 8),
                    Text(
                      'Started at: ${a.createdAt.toLocal().toString().split(".")[0]}',
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
                          child: BlocBuilder<ActivityBloc, ActivityState>(
                            builder: (context, state) {
                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      state.mutateStatus ==
                                          ActivityStatus.loading
                                      ? AppTheme.muted
                                      : Theme.of(context).colorScheme.primary,
                                ),
                                onPressed: () {
                                  if (state.mutateStatus ==
                                      ActivityStatus.loading)
                                    return;
                                  context.read<ActivityBloc>().add(
                                    UpdateActivityEvent(a.id, {
                                      'feeling': _feeling?.api,
                                      'weather': _weather?.api,
                                      if (_imagePath != null)
                                        'imageFilePath': _imagePath!,
                                    }),
                                  );
                                  context.pop();
                                  context.read<BottomNavCubit>().setIndex(0);
                                  context.read<AuthBloc>().add(
                                    GetProfileEvent(),
                                  );
                                  context.read<ActivityBloc>().add(
                                    FetchFeedEvent(),
                                  );
                                },
                                child:
                                    state.mutateStatus == ActivityStatus.loading
                                    ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Save'),
                              );
                            },
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

class _EditBar extends StatelessWidget {
  const _EditBar({
    required this.initialFeeling,
    required this.initialWeather,
    required this.selectedFeeling,
    required this.selectedWeather,
    required this.onPickImage,
    required this.onSelectFeeling,
    required this.onSelectWeather,
    required this.imagePath,
  });
  final String? initialFeeling;
  final String? initialWeather;
  final Feeling? selectedFeeling;
  final WeatherCondition? selectedWeather;
  final VoidCallback onPickImage;
  final ValueChanged<Feeling> onSelectFeeling;
  final ValueChanged<WeatherCondition> onSelectWeather;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final currFeeling = selectedFeeling?.name ?? initialFeeling;
    final currWeather = selectedWeather?.name ?? initialWeather;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _SelectorRow<Feeling>(
                title: 'Feeling',
                values: Feeling.values,
                isSelected: (f) => f.name == currFeeling,
                iconFor: (f) => switch (f) {
                  Feeling.excellent => Icons.emoji_events,
                  Feeling.good => Icons.sentiment_satisfied_alt,
                  Feeling.okay => Icons.sentiment_neutral,
                  Feeling.tired => Icons.bedtime,
                  Feeling.exhausted => Icons.battery_alert,
                  Feeling.injured => Icons.medical_services_outlined,
                  Feeling.motivated => Icons.emoji_emotions,
                  Feeling.relaxed => Icons.self_improvement,
                },
                color: cs.primary,
                onTap: onSelectFeeling,
                labelFor: (f) => f.label,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _SelectorRow<WeatherCondition>(
                title: 'Weather',
                values: WeatherCondition.values,
                isSelected: (w) => w.name == currWeather,
                iconFor: (w) => switch (w) {
                  WeatherCondition.sunny => Icons.wb_sunny,
                  WeatherCondition.cloudy => Icons.wb_cloudy,
                  WeatherCondition.rainy => Icons.umbrella,
                  WeatherCondition.windy => Icons.air,
                  WeatherCondition.storm => Icons.thunderstorm,
                  WeatherCondition.snow => Icons.ac_unit,
                },
                color: cs.secondary,
                onTap: onSelectWeather,
                labelFor: (w) => w.label,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: onPickImage,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: cs.outlineVariant),
              borderRadius: BorderRadius.circular(8),
            ),
            height: 200,
            width: double.infinity,
            child: imagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(File(imagePath!), fit: BoxFit.cover),
                  )
                : Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          color: cs.onSurfaceVariant,
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add Photo',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _SelectorRow<T> extends StatelessWidget {
  const _SelectorRow({
    required this.title,
    required this.values,
    required this.isSelected,
    required this.iconFor,
    required this.color,
    required this.onTap,
    required this.labelFor,
  });
  final String title;
  final List<T> values;
  final bool Function(T) isSelected;
  final IconData Function(T) iconFor;
  final Color color;
  final ValueChanged<T> onTap;
  final String Function(T) labelFor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final v in values)
              InkWell(
                onTap: () => onTap(v),
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected(v) ? color.withOpacity(0.12) : cs.surface,
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    border: Border.all(
                      color: isSelected(v) ? color : cs.outlineVariant,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        iconFor(v),
                        size: 16,
                        color: isSelected(v) ? color : cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        labelFor(v),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: isSelected(v) ? color : cs.onSurfaceVariant,
                          fontWeight: isSelected(v)
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
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
