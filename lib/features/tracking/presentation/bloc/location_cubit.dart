import 'dart:async';
import 'dart:isolate';
import 'dart:io';
import 'dart:ui' show IsolateNameServer;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:background_locator_2/background_locator.dart' as bl;
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart' as ph;

import '../../domain/entities/tracking_point.dart';
import '../../utils/geo_utils.dart';
import '../background/background_location_callback.dart' as bg;
import 'tracking_cubit.dart';

part 'location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  // Singleton setup
  static final LocationCubit _instance = LocationCubit._internal();
  factory LocationCubit() => _instance;
  LocationCubit._internal() : super(const LocationState.initial());

  StreamSubscription<geo.Position>? _sub; // legacy (foreground one-shot)
  ReceivePort? _receivePort;
  StreamSubscription? _receiveSub;
  bool _bgActive = false;
  bool get isBgActive => _bgActive;

  // Start a lightweight foreground stream to keep UI updated when not tracking in background
  void _startForegroundStream() {
    // ignore: avoid_print
    print('[LocationCubit] _startForegroundStream');
    _sub?.cancel();
    _sub =
        geo.Geolocator.getPositionStream(
          locationSettings: const geo.LocationSettings(
            accuracy: geo.LocationAccuracy.best,
            distanceFilter: 2,
          ),
        ).listen((pos) {
          // ignore: avoid_print
          print(
            '[LocationCubit] FG update ${pos.latitude},${pos.longitude} alt=${pos.altitude}',
          );
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

  Future<void> _stopForegroundStream() async {
    // ignore: avoid_print
    print('[LocationCubit] _stopForegroundStream');
    await _sub?.cancel();
    _sub = null;
  }

  Future<void> ensureReady() async {
    // ignore: avoid_print
    print('[LocationCubit] ensureReady()');
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

    // Set up foreground receive port to get background updates when app is open.
    _ensureReceivePort();

    // Keep UI updated while app is foregrounded and background tracking isn't active
    if (ready && !_bgActive) {
      _startForegroundStream();
      // Also try a one-shot to seed position quickly
      try {
        final pos = await geo.Geolocator.getCurrentPosition(
          desiredAccuracy: geo.LocationAccuracy.best,
        );
        // ignore: avoid_print
        print(
          '[LocationCubit] One-shot position ${pos.latitude},${pos.longitude}',
        );
        emit(state.copyWith(lastPosition: pos));
      } catch (_) {}
    } else {
      await _stopForegroundStream();
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

  void _ensureReceivePort() {
    const name = 'pacemate_location_port';
    if (_receivePort == null) {
      // ignore: avoid_print
      print('[LocationCubit] Creating ReceivePort and registering: $name');
      _receivePort = ReceivePort();
      // Register name for background isolate to find
      IsolateNameServer.removePortNameMapping(name);
      IsolateNameServer.registerPortWithName(_receivePort!.sendPort, name);
      _receiveSub = _receivePort!.listen((dynamic data) {
        if (data is Map) {
          final lat = (data['lat'] as num?)?.toDouble();
          final lng = (data['lng'] as num?)?.toDouble();
          final alt = (data['alt'] as num?)?.toDouble() ?? 0.0;
          if (lat != null && lng != null) {
            // ignore: avoid_print
            print('[LocationCubit] BG update $lat,$lng alt=$alt');
            if (!_bgActive) {
              // If we are receiving BG updates, consider service active
              _bgActive = true;
              // ignore: avoid_print
              print('[LocationCubit] BG updates received; flag set active');
            }
            final pos = geo.Position(
              latitude: lat,
              longitude: lng,
              timestamp: DateTime.fromMillisecondsSinceEpoch(
                (data['ts'] as int?) ?? DateTime.now().millisecondsSinceEpoch,
              ),
              accuracy: 0,
              altitude: alt,
              heading: 0,
              headingAccuracy: 0,
              altitudeAccuracy: 0,
              speed: 0,
              speedAccuracy: 0,
              floor: null,
              isMocked: false,
            );
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
          }
        }
      });
    } else {
      // Ensure mapping exists; if another mapping holds the name, replace it with our port
      final existing = IsolateNameServer.lookupPortByName(name);
      if (existing != _receivePort!.sendPort) {
        // ignore: avoid_print
        print('[LocationCubit] Re-registering ReceivePort name: $name');
        IsolateNameServer.removePortNameMapping(name);
        IsolateNameServer.registerPortWithName(_receivePort!.sendPort, name);
      }
    }
  }

  Future<void> startBackgroundTracking() async {
    if (_bgActive) return;
    // ignore: avoid_print
    print('[LocationCubit] startBackgroundTracking()');
    await ensureReady();
    final ok = state.ready;
    if (!ok) return;

    // Android: request runtime permissions needed for foreground notification and background location
    if (Platform.isAndroid) {
      try {
        // Android 13+ notifications permission
        final notifStatus = await ph.Permission.notification.status;
        if (!notifStatus.isGranted) {
          // ignore: avoid_print
          print('[LocationCubit] Requesting notifications permission');
          await ph.Permission.notification.request();
        }
      } catch (_) {}
      try {
        // Background location permission (Android 10+)
        // Request when-in-use first, then always
        final whenInUse = await ph.Permission.location.status;
        if (!whenInUse.isGranted) {
          // ignore: avoid_print
          print('[LocationCubit] Requesting location (when in use)');
          await ph.Permission.location.request();
        }
        final bgLocStatus = await ph.Permission.locationAlways.status;
        if (!bgLocStatus.isGranted) {
          // ignore: avoid_print
          print('[LocationCubit] Requesting location (always)');
          await ph.Permission.locationAlways.request();
        }
      } catch (_) {}
    }

    // Initialize background locator once
    // Ensure initialized
    await bl.BackgroundLocator.initialize();

    _ensureReceivePort();

    // Stop foreground stream to avoid duplicate updates
    await _stopForegroundStream();

    bool registered = false;
    try {
      await bl.BackgroundLocator.registerLocationUpdate(
        bg.callback,
        initCallback: bg.initCallback,
        disposeCallback: bg.disposeCallback,
        autoStop: false,
        iosSettings: const IOSSettings(
          accuracy: LocationAccuracy.HIGH,
          distanceFilter: 2,
          showsBackgroundLocationIndicator: true,
        ),
        androidSettings: AndroidSettings(
          accuracy: LocationAccuracy.HIGH,
          interval: 2,
          distanceFilter: 2,
          androidNotificationSettings: AndroidNotificationSettings(
            notificationChannelName: 'Run Tracking',
            notificationTitle: 'Tracking Active',
            notificationMsg: 'Your run is being recorded',
            notificationBigMsg: 'Background tracking in progress…',
            notificationIcon: 'ic_stat_pacemate',
            notificationTapCallback: bg.onNotificationTap,
          ),
        ),
      );
      registered = true;
      // ignore: avoid_print
      print('[LocationCubit] registerLocationUpdate success');
    } catch (e) {
      // If registration throws, keep UI stream active and surface in debug
      assert(() {
        // ignore: avoid_print
        print('BackgroundLocator.register failed: $e');
        return true;
      }());
      registered = false;
    }
    if (!registered) {
      // ignore: avoid_print
      print('[LocationCubit] Registration failed, keeping foreground stream');
      _bgActive = false;
      // Keep UI foreground updates
      if (state.ready) _startForegroundStream();
      return;
    }

    // Optimistically mark active, then verify with retries
    _bgActive = true;
    bool running = false;
    for (var i = 0; i < 10; i++) {
      await Future<void>.delayed(const Duration(seconds: 1));
      try {
        running = await bl.BackgroundLocator.isServiceRunning();
      } catch (_) {
        running = false;
      }
      // ignore: avoid_print
      print('[LocationCubit] isServiceRunning check #${i + 1}: $running');
      if (running) break;
    }
    _bgActive = running;
    if (!running) {
      // ignore: avoid_print
      print(
        '[LocationCubit] BG service not running after retries; reverting to FG',
      );
      if (state.ready) _startForegroundStream();
      // One-time fallback: try to re-register after a clean unRegister + re-initialize
      try {
        // ignore: avoid_print
        print('[LocationCubit] Attempting one-time re-register fallback');
        await bl.BackgroundLocator.unRegisterLocationUpdate();
      } catch (_) {}
      await Future<void>.delayed(const Duration(milliseconds: 400));
      try {
        await bl.BackgroundLocator.initialize();
      } catch (_) {}
      try {
        await bl.BackgroundLocator.registerLocationUpdate(
          bg.callback,
          initCallback: bg.initCallback,
          disposeCallback: bg.disposeCallback,
          autoStop: false,
          iosSettings: const IOSSettings(
            accuracy: LocationAccuracy.HIGH ,
            distanceFilter: 2,
            showsBackgroundLocationIndicator: true,
          ),
          androidSettings: AndroidSettings(
            accuracy: LocationAccuracy.HIGH,
            interval: 2,
            distanceFilter: 2,
            androidNotificationSettings: AndroidNotificationSettings(
              notificationChannelName: 'Run Tracking',
              notificationTitle: 'Tracking Active',
              notificationMsg: 'Your run is being recorded',
              notificationBigMsg: 'Background tracking in progress…',
              notificationIcon: 'ic_launcher',
              notificationTapCallback: bg.onNotificationTap,
            ),
          ),
        );
        // ignore: avoid_print
        print('[LocationCubit] Re-register success');
      } catch (e) {
        // ignore: avoid_print
        print('[LocationCubit] Re-register failed: $e');
        return;
      }
      // Verify again briefly
      await Future<void>.delayed(const Duration(seconds: 2));
      bool running2 = false;
      try {
        running2 = await bl.BackgroundLocator.isServiceRunning();
      } catch (_) {}
      _bgActive = running2;
      // ignore: avoid_print
      print('[LocationCubit] isServiceRunning after fallback: $running2');
      if (!running2 && state.ready) {
        _startForegroundStream();
      }
    }
  }

  Future<void> stopBackgroundTracking() async {
    if (!_bgActive) return;
    // ignore: avoid_print
    print('[LocationCubit] stopBackgroundTracking()');
    try {
      await bl.BackgroundLocator.unRegisterLocationUpdate();
    } catch (_) {}
    _bgActive = false;
    // Resume foreground stream for UI if app still open and permissions ok
    if (state.ready) {
      _startForegroundStream();
    }
  }

  @override
  Future<void> close() async {
    try {
      await _sub?.cancel();
    } catch (_) {}
    _sub = null;
    if (_bgActive) {
      try {
        await bl.BackgroundLocator.unRegisterLocationUpdate();
      } catch (_) {}
      _bgActive = false;
    }
    try {
      final name = 'pacemate_location_port';
      IsolateNameServer.removePortNameMapping(name);
      await _receiveSub?.cancel();
      _receiveSub = null;
      _receivePort?.close();
      _receivePort = null;
    } catch (_) {}
    return super.close();
  }

  // Diagnostics for debug overlay or logs
  Future<Map<String, dynamic>> permissionSnapshot() async {
    final res = <String, dynamic>{};
    try {
      if (Platform.isAndroid) {
        res['notif'] = (await ph.Permission.notification.status).toString();
        res['loc'] = (await ph.Permission.location.status).toString();
        res['locAlways'] = (await ph.Permission.locationAlways.status)
            .toString();
      }
    } catch (_) {}
    return res;
  }

  /// Reset elevation statistics (e.g., when starting a new tracking session)
  void resetElevation() {
    emit(state.copyWith(elevationGain: 0.0, maxElevation: 0.0));
  }

  /// Read saved background points from run_log.txt, convert to TrackingPoint,
  /// send to TrackingCubit via addPoint, and clear the file.
  Future<void> syncOfflinePoints(TrackingCubit trackingCubit) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/run_log.txt');
      if (!await file.exists()) return;
      final content = await file.readAsLines();
      if (content.isEmpty) return;
      // Parse JSON lines into points
      final List<({double lat, double lng, double alt, DateTime ts})> pts = [];
      for (final line in content) {
        if (line.trim().isEmpty) continue;
        try {
          final Map<String, dynamic> m = json.decode(line);
          final lat = (m['lat'] as num).toDouble();
          final lng = (m['lng'] as num).toDouble();
          final alt = (m['alt'] as num?)?.toDouble() ?? 0.0;
          final ts = DateTime.fromMillisecondsSinceEpoch(
            (m['ts'] as num).toInt(),
          );
          pts.add((lat: lat, lng: lng, alt: alt, ts: ts));
        } catch (_) {}
      }
      if (pts.isEmpty) return;

      // Push into TrackingCubit with distance computed incrementally
      double? prevLat;
      double? prevLng;
      for (final p in pts) {
        double dist = 0.0;
        if (prevLat != null && prevLng != null) {
          dist = haversineDistanceMeters(
            lat1: prevLat,
            lon1: prevLng,
            lat2: p.lat,
            lon2: p.lng,
          );
        }
        prevLat = p.lat;
        prevLng = p.lng;
        try {
          // dynamic to avoid importing TrackingCubit class here
          trackingCubit.addPoint(
            TrackingPoint(
              latitude: p.lat,
              longitude: p.lng,
              timestamp: p.ts,
              distanceFromLast: dist,
              elevation: p.alt.toInt(),
            ),
          );
        } catch (_) {
          // If cubit not ready yet, stop early.
          break;
        }
      }

      // Clear file
      await file.writeAsString('', flush: true);
    } catch (_) {}
  }

  // Debug helpers
  Future<bool> isBackgroundServiceRunning() async {
    try {
      return await bl.BackgroundLocator.isServiceRunning();
    } catch (_) {
      return false;
    }
  }

  Future<String?> getRunLogPath() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      return '${dir.path}/run_log.txt';
    } catch (_) {
      return null;
    }
  }
}
