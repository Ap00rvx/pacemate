part of 'location_cubit.dart';

class LocationState extends Equatable {
  final bool ready;
  final bool serviceEnabled;
  final geo.LocationPermission? permission;
  final geo.Position? lastPosition;
  final double elevationGain; // cumulative positive altitude gain in meters
  final double maxElevation; // highest altitude observed (meters)

  const LocationState({
    required this.ready,
    required this.serviceEnabled,
    required this.permission,
    required this.lastPosition,
    required this.elevationGain,
    required this.maxElevation,
  });

  const LocationState.initial()
    : ready = false,
      serviceEnabled = false,
      permission = null,
      lastPosition = null,
      elevationGain = 0.0,
      maxElevation = 0.0;

  LocationState copyWith({
    bool? ready,
    bool? serviceEnabled,
    geo.LocationPermission? permission,
    geo.Position? lastPosition,
    double? elevationGain,
    double? maxElevation,
  }) {
    return LocationState(
      ready: ready ?? this.ready,
      serviceEnabled: serviceEnabled ?? this.serviceEnabled,
      permission: permission ?? this.permission,
      lastPosition: lastPosition ?? this.lastPosition,
      elevationGain: elevationGain ?? this.elevationGain,
      maxElevation: maxElevation ?? this.maxElevation,
    );
  }

  @override
  List<Object?> get props => [
    ready,
    serviceEnabled,
    permission,
    lastPosition,
    elevationGain,
    maxElevation,
  ];
}
