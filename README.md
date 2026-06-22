# Cairn

A streak for the days you don't open the app you can't quit.

Cairn adds a stone to a small cairn for every day you stay away from an app you've
decided to use less. It does not block anything. It just keeps count of the clean
days.

Everything stays on the phone. No accounts, no servers, no analytics.

## Principles

- On-device only. Cairn has no backend, so nothing about you leaves the phone.
- No blocking. Cairn notices the days you stay away; it never locks you out.
- Honest counting. A day counts as clean only when it can be verified. If
  detection has a gap, that day is shown as "unverified" instead of a wrong
  "you opened it".
- Calm. No red, no alarms, no reminders to come back. Sage is the only accent
  colour.

## Features

- A streak per app, plus a combined streak across everything you track.
- Streak guard: an optional pause shown when you open a tracked app, offering
  "Stay strong" or "Open anyway". It never blocks; you decide.
- A morning recap and milestone markers at 7, 30, and 100 clean days.
- A summit trophy for an app once you uninstall it for good.

## Tech

- Flutter (Dart) for the UI, with a thin Kotlin layer for the Android pieces.
- Riverpod for state, Drift (SQLite) for on-device storage.
- Detection uses Android's UsageStatsManager. Streak guard adds an overlay plus a
  usage-access polling foreground service.
- The domain layer (streak math, reconciliation) is pure Dart and covered by
  tests.

Platforms: Android for now (minSdk 26). iOS is a separate future track; its
constraints are written up in [docs/cairn-ios-feasibility.md](docs/cairn-ios-feasibility.md).

## Build and run

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
flutter test
```

Release builds:

```bash
flutter build apk --release
flutter build appbundle --release
```

Release signing reads `android/key.properties` (gitignored). Copy
[android/key.properties.example](android/key.properties.example) to set it up.
Without it, release builds fall back to debug signing.

## Project layout

- `lib/domain/`: pure Dart logic (streak math, reconciliation, recap).
- `lib/data/`: Drift schema, DAOs, repositories.
- `lib/platform/`: native bridges (usage access, notifications).
- `lib/ui/`: screens and widgets.
- `android/app/src/main/kotlin/dev/cairn/`: the Kotlin layer.
- `docs/`: design notes, the QA plan, and the iOS feasibility study.

## License

[GPL-3.0](LICENSE). Forks and redistributions stay open source.
