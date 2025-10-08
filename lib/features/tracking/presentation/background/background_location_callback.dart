// Background callbacks for background_locator_2
// These run on a background isolate; keep them top-level.

import 'dart:io';
import 'dart:isolate';
import 'dart:ui' show IsolateNameServer;

// no direct import needed here for background locator types
import 'package:background_locator_2/location_dto.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// keep background_locator_2 out here to avoid unused imports

// Key used to indicate that user tapped the sticky notification and wants to open tracking screen.
const String kNotifTapFlagKey = 'pacemate_notification_tap_tracking';

// Called once when background isolate is created. Register plugins here.
@pragma('vm:entry-point')
void initCallback(Map<String, dynamic> params) {
  // Ensure plugins (like path_provider, shared_preferences) are available in background isolate
  WidgetsFlutterBinding.ensureInitialized();
  // For Flutter >= 3, this registers plugins in background isolate
  // No-op: most plugins used here support background without explicit registrant
  // Debug marker: write INIT line to log
  () async {
    try {
      // ignore: avoid_print
      print('[BG CALLBACK] initCallback');
      final f = await _getRunLogFile();
      await f.writeAsString(
        '[INIT] ${DateTime.now().toIso8601String()}\n',
        mode: FileMode.append,
        flush: true,
      );
    } catch (_) {}
  }();
}

// Called on every location update in the background.
@pragma('vm:entry-point')
Future<void> callback(LocationDto dto) async {
  try {
    // ignore: avoid_print
    print(
      '[BG CALLBACK] point ${dto.latitude},${dto.longitude} alt=${dto.altitude}',
    );
    final file = await _getRunLogFile();
    final line = _toJsonLine(dto);
    await file.writeAsString('$line\n', mode: FileMode.append, flush: true);
    // Also try to notify foreground isolate if it's listening
    final SendPort? port = IsolateNameServer.lookupPortByName(
      'pacemate_location_port',
    );
    port?.send({
      'lat': dto.latitude,
      'lng': dto.longitude,
      'alt': dto.altitude,
      'ts': DateTime.now().millisecondsSinceEpoch,
    });
  } catch (_) {
    // Swallow background IO errors to avoid isolate crashes
  }
}

// Called when background tracking is disposed.
@pragma('vm:entry-point')
void disposeCallback() {
  // Debug marker: write DISPOSE line
  () async {
    try {
      final f = await _getRunLogFile();
      await f.writeAsString(
        '[DISPOSE] ${DateTime.now().toIso8601String()}\n',
        mode: FileMode.append,
        flush: true,
      );
    } catch (_) {}
  }();
}

// Invoked when user taps the persistent notification. This runs in background isolate.
// We can't navigate directly here; instead set a flag that the main isolate reads on resume/start.
@pragma('vm:entry-point')
Future<void> onNotificationTap() async {
  try {
    // ignore: avoid_print
    print('[BG CALLBACK] notification tap');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kNotifTapFlagKey, true);
    // BackgroundLocator will also bring app to foreground by launching main activity.
    // Debug marker: write TAP line
    final f = await _getRunLogFile();
    await f.writeAsString(
      '[TAP] ${DateTime.now().toIso8601String()}\n',
      mode: FileMode.append,
      flush: true,
    );
  } catch (_) {}
}

// Helpers
Future<File> _getRunLogFile() async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/run_log.txt');
  if (!await file.exists()) {
    await file.create(recursive: true);
  }
  return file;
}

String _toJsonLine(LocationDto dto) {
  // Store as a compact JSON line per point
  final map = {
    'lat': dto.latitude,
    'lng': dto.longitude,
    'alt': dto.altitude,
    'ts': DateTime.now().millisecondsSinceEpoch,
  };
  return _jsonEncode(map);
}

// Lightweight JSON encoder without importing dart:convert to minimize background isolate deps
String _jsonEncode(Map<String, Object?> map) {
  String esc(String s) => s.replaceAll('\\', r'\\').replaceAll('"', '\\"');
  final entries = map.entries
      .map((e) {
        final k = '"${esc(e.key)}"';
        final v = e.value;
        if (v == null) return '$k:null';
        if (v is num || v is bool) return '$k:$v';
        return '$k:"${esc(v.toString())}"';
      })
      .join(',');
  return '{$entries}';
}
