import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart' as geo;

part 'location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  // Singleton setup
  static final LocationCubit _instance = LocationCubit._internal();
  factory LocationCubit() => _instance;
  LocationCubit._internal() : super(const LocationState.initial());

  StreamSubscription<geo.Position>? _sub;

  Future<void> ensureReady() async {
    // Check and request permissions
    var permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
    }

    final service = await geo.Geolocator.isLocationServiceEnabled();
    final ready =
        service &&
        (permission == geo.LocationPermission.always ||
            permission == geo.LocationPermission.whileInUse);

    emit(
      state.copyWith(
        permission: permission,
        serviceEnabled: service,
        ready: ready,
      ),
    );

    if (ready) {
      _startStream();
    } else {
      await _stopStream();
    }
  }

  /// Fetch current location once without starting the stream.
  /// Returns the position if available, else null. Emits state with the
  /// latest permission/service flags and lastPosition if fetched.
  Future<geo.Position?> getCurrentPosition() async {
    var permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
    }

    final service = await geo.Geolocator.isLocationServiceEnabled();
    final ready =
        service &&
        (permission == geo.LocationPermission.always ||
            permission == geo.LocationPermission.whileInUse);

    geo.Position? pos;
    if (ready) {
      try {
        pos = await geo.Geolocator.getCurrentPosition(
          desiredAccuracy: geo.LocationAccuracy.best,
        );
      } catch (_) {}
    }

    emit(
      state.copyWith(
        permission: permission,
        serviceEnabled: service,
        ready: ready,
        lastPosition: pos ?? state.lastPosition,
      ),
    );

    return pos;
  }

  void _startStream() {
    _sub?.cancel();
    _sub =
        geo.Geolocator.getPositionStream(
          locationSettings: const geo.LocationSettings(
            accuracy: geo.LocationAccuracy.best,
            distanceFilter: 2,
            // meters
          ),
        ).listen((pos) {
          print('Position: ${pos.toJson()}');
          double gain = state.elevationGain;
          double maxEl = state.maxElevation;
          final prev = state.lastPosition;
          if (prev != null) {
            final delta = pos.altitude - prev.altitude;
            if (delta > 0) gain += delta;
          }
          if (pos.altitude > maxEl) maxEl = pos.altitude;
          emit(
            state.copyWith(
              lastPosition: pos,
              elevationGain: gain,
              maxElevation: maxEl,
            ),
          );
        });
  }

  Future<void> _stopStream() async {
    await _sub?.cancel();
    _sub = null;
  }

  @override
  Future<void> close() async {
    await _stopStream();
    return super.close();
  }

  /// Reset elevation statistics (e.g., when starting a new tracking session)
  void resetElevation() {
    emit(state.copyWith(elevationGain: 0.0, maxElevation: 0.0));
  }
}
