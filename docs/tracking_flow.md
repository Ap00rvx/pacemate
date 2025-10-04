# Tracking Feature Flow

This document outlines the architecture and runtime flow for the running/walking tracking feature.

## Layers (Clean Architecture)
- Domain
  - Entities: `TrackingPoint`
  - Enums: `ActivityType`
  - (Later) Use cases: start/stop tracking, save activity, fetch history
- Data
  - (Later) Repositories/gateways for location stream and persistence (e.g., local DB)
- Presentation
  - State: `TrackingCubit` + `TrackingState`
  - UI: `MapScreen` (Flutter Map), stats panel, controls
  - Widgets: markers, polyline, summary

## Calculations
- Distance: Haversine between consecutive GPS points (see `geo_utils.dart`)
- Calories: MET formula based on activity type and duration (`calorie_utils.dart`)
- Duration: timer maintained by `TrackingCubit`

## Runtime Flow
1. User opens Map screen.
2. User taps Play to start (defaults to running); or selects activity from menu.
3. `TrackingCubit.start()` sets state and starts 1s timer for duration.
4. Location provider reports position updates (stubbed in demo via Simulate button).
5. On each point, compute distance from the last point (Haversine) and dispatch `addPoint()`.
6. `TrackingCubit` updates: points, cumulative distance, recalculated calories.
7. UI updates:
   - Map centers to last position.
   - Polyline draws the path.
   - Markers show start and current positions.
   - Bottom panel shows distance, duration, and calories.
8. User taps Pause → `TrackingCubit.stop()`; state freezes for summary/save (future work).

## Future Enhancements
- Replace simulated points with `geolocator` live stream and permissions flow.
- Persist tracks locally (Isar/SQLite) and sync to backend.
- Elevation gain, pace splits, heart rate integration.
- Background tracking and pause/resume.
- Route export (GPX/TCX) and analysis dashboards.

## Notes
- The feature is self-contained under `features/tracking` and is UI-composed into Home.
- Theme/branding is inherited from `AppTheme` for consistency.