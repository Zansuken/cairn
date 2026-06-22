// Lightweight view-models for the Home screen. These are intentionally simple
// and fed by fake data in build step (b); step (f) swaps the provider for one
// backed by the real domain + Drift, keeping these shapes.

/// Today's in-progress state for a tracked app (or the global meta-day).
enum TodayStatus { stillClean, slippedToday, unverified }

extension TodayStatusLabel on TodayStatus {
  String get label => switch (this) {
        TodayStatus.stillClean => 'still clean',
        TodayStatus.slippedToday => 'opened today',
        TodayStatus.unverified => 'unverified',
      };
}

class HomeAppVm {
  const HomeAppVm({
    required this.packageId,
    required this.name,
    required this.monogram,
    required this.currentStreak,
    required this.today,
  });

  final String packageId;
  final String name;
  final String monogram;
  final int currentStreak;
  final TodayStatus today;
}

class HomeMeta {
  const HomeMeta({
    required this.metaStreak,
    required this.dayNumber,
    required this.allCleanToday,
    required this.rolloverInHours,
    required this.bestRun,
    required this.lifetimeClean,
  });

  /// Consecutive "perfect days" (every tracked app clean).
  final int metaStreak;

  /// The in-progress day number shown live.
  final int dayNumber;
  final bool allCleanToday;
  final int rolloverInHours;
  final int bestRun;
  final int lifetimeClean;
}

class HomeState {
  const HomeState({required this.meta, required this.apps});

  final HomeMeta meta;
  final List<HomeAppVm> apps;

  bool get isEmpty => apps.isEmpty;
}
