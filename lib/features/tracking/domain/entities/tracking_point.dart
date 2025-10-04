class TrackingPoint {
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double distanceFromLast; // meters

  const TrackingPoint({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.distanceFromLast,
  });
}
