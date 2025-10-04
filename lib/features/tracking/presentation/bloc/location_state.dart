part of 'location_cubit.dart';

class LocationState extends Equatable {
  final bool ready;
  final bool serviceEnabled;
  final geo.LocationPermission? permission;
  final geo.Position? lastPosition;

  const LocationState({
    required this.ready,
    required this.serviceEnabled,
    required this.permission,
    required this.lastPosition,
  });

  const LocationState.initial()
    : ready = false,
      serviceEnabled = false,
      permission = null,
      lastPosition = null;

  LocationState copyWith({
    bool? ready,
    bool? serviceEnabled,
    geo.LocationPermission? permission,
    geo.Position? lastPosition,
  }) {
    return LocationState(
      ready: ready ?? this.ready,
      serviceEnabled: serviceEnabled ?? this.serviceEnabled,
      permission: permission ?? this.permission,
      lastPosition: lastPosition ?? this.lastPosition,
    );
  }

  @override
  List<Object?> get props => [ready, serviceEnabled, permission, lastPosition];
}
