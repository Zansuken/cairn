import '../../domain/model/day_state.dart';

/// View-model for the App detail screen — one tracked app up close. Carries both
/// the active shape (current run + 30-day history) and the Freed/summit shape;
/// [isFreed] selects which layout the screen renders.
class AppDetailVm {
  const AppDetailVm({
    required this.packageId,
    required this.name,
    required this.monogram,
    required this.isFreed,
    required this.currentStreak,
    required this.bestStreak,
    required this.lifetimeClean,
    required this.today,
    required this.history,
    this.freedAt,
  });

  final String packageId;
  final String name;
  final String monogram;
  final bool isFreed;

  /// Active: the current run. Freed: the final run at the moment of freeing.
  final int currentStreak;
  final int bestStreak;
  final int lifetimeClean;

  /// Live status of the in-progress day (active only).
  final DayState today;

  /// Last 30 day verdicts, oldest first, today last.
  final List<DayState> history;

  /// When the app was uninstalled (Freed only).
  final DateTime? freedAt;
}
