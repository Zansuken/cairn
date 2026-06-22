import 'model/day_record.dart';
import 'model/day_state.dart';
import 'streak_math.dart';

/// One app's contribution to the meta-streak, with the window during which it
/// was actually being tracked. A day only counts against the "perfect day" rule
/// for apps that were active that day: an app added later does not retroactively
/// spoil earlier days, and a Freed (uninstalled) app stops spoiling later ones.
class MetaAppInput {
  const MetaAppInput({
    required this.history,
    required this.activeFrom,
    this.activeUntil,
  });

  final List<DayRecord> history;

  /// First calendar day the app counts (its addedAt day).
  final DateTime activeFrom;

  /// Last calendar day the app counts, inclusive (its freedAt day). Null while
  /// the app is still actively tracked.
  final DateTime? activeUntil;
}

/// Turns finalized [DayRecord] history into the streak numbers shown in the UI.
/// Pure — no Drift, no platform, fully unit-testable.
abstract final class StreakCalculator {
  StreakCalculator._();

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Per-app stats: a day is "good" iff it is clean. Slipped and unverified
  /// both break the chain.
  static StreakStats appStats(List<DayRecord> history) {
    final marks = [
      for (final r in history) DayMark(r.dayStart, good: r.state == DayState.clean),
    ];
    return StreakMath.compute(marks);
  }

  /// Meta ("perfect day") stats: a day is "good" iff *every app that was active
  /// that day* has a clean record. Apps outside their active window are ignored
  /// for that day; a day with no active app is never perfect.
  static StreakStats metaStats(List<MetaAppInput> apps) {
    if (apps.isEmpty) {
      return const StreakStats(current: 0, best: 0, lifetime: 0, lastDate: null);
    }

    // Per app: date → clean? with non-clean winning on duplicates. Plus the
    // app's active window (date-only).
    final cleanByApp = <Map<DateTime, bool>>[];
    final activeFrom = <DateTime>[];
    final activeUntil = <DateTime?>[];
    final allDays = <DateTime>{};
    for (final app in apps) {
      final clean = <DateTime, bool>{};
      for (final r in app.history) {
        final d = _dateOnly(r.dayStart);
        clean[d] = (clean[d] ?? true) && (r.state == DayState.clean);
        allDays.add(d);
      }
      cleanByApp.add(clean);
      activeFrom.add(_dateOnly(app.activeFrom));
      activeUntil.add(app.activeUntil == null ? null : _dateOnly(app.activeUntil!));
    }

    final marks = <DayMark>[];
    for (final day in allDays) {
      var anyActive = false;
      var allClean = true;
      for (var i = 0; i < apps.length; i++) {
        final active = !day.isBefore(activeFrom[i]) &&
            (activeUntil[i] == null || !day.isAfter(activeUntil[i]!));
        if (!active) continue;
        anyActive = true;
        if (cleanByApp[i][day] != true) allClean = false;
      }
      marks.add(DayMark(day, good: anyActive && allClean));
    }
    return StreakMath.compute(marks);
  }
}
