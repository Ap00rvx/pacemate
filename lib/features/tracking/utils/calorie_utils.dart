import '../domain/enums/activity_type.dart';

/// Estimate calories burned using a MET formula derived from pace (speed).
/// weightKg: user weight in kilograms (fallback to 70 kg if unknown)
/// distanceKm: total distance in kilometers
/// durationSeconds: total duration of activity
int estimateCalories({
  required ActivityType type,
  double weightKg = 70,
  required double distanceKm,
  required int durationSeconds,
}) {
  if (durationSeconds <= 0 || distanceKm <= 0) return 0;

  final hours = durationSeconds / 3600.0;
  final speedKmh = distanceKm / hours; // km/h
  final met = _metFromSpeed(type: type, speedKmh: speedKmh);
  final kcal = met * weightKg * hours;
  return kcal.round();
}

// Rough MET lookup based on ACSM/Compendium approximations.
double _metFromSpeed({required ActivityType type, required double speedKmh}) {
  if (speedKmh.isNaN || !speedKmh.isFinite || speedKmh <= 0) {
    return switch (type) {
      ActivityType.running => 6.0,
      ActivityType.walking => 2.5,
      ActivityType.cycling => 4.0,
    };
  }

  switch (type) {
    case ActivityType.walking:
      if (speedKmh < 3.0) return 2.0; // very slow stroll
      if (speedKmh < 4.0) return 2.8; // easy walk
      if (speedKmh < 5.5) return 3.3; // moderate
      if (speedKmh < 6.5) return 3.8; // brisk
      return 4.3; // very brisk
    case ActivityType.running:
      if (speedKmh < 7.0) return 6.0; // jog ~6 km/h
      if (speedKmh < 8.4) return 8.3; // ~8 km/h
      if (speedKmh < 10.0) return 9.8; // ~9.7 km/h
      if (speedKmh < 11.5) return 10.5; // ~10.8 km/h
      if (speedKmh < 12.9) return 11.5; // ~12.1 km/h
      if (speedKmh < 14.9) return 12.5; // ~13.8 km/h
      return 13.5; // >= 14.9 km/h
    case ActivityType.cycling:
      if (speedKmh < 16) return 4.0; // leisure, <10 mph
      if (speedKmh < 19) return 6.0; // moderate, 10-11.9 mph
      if (speedKmh < 22) return 8.0; // vigorous, 12-13.9 mph
      if (speedKmh < 25) return 10.0; // very vigorous, 14-15.9 mph
      return 12.0; // racing, >=16 mph
  }
}
