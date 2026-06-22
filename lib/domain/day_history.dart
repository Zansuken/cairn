import 'model/day_record.dart';
import 'model/day_state.dart';

/// History-preparation helpers used by the data layer before streak math runs.
abstract final class DayHistory {
  DayHistory._();

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Materialises missing calendar days as `unverified` records, from the first
  /// record's day through [throughDay] (inclusive).
  ///
  /// This enforces PRD §4.5: a span with no detection data must read as
  /// unverified (never silently clean, never a stale streak), rather than being
  /// absent. The data layer calls this with [throughDay] = the most recent
  /// completed day before invoking [StreakCalculator.appStats].
  static List<DayRecord> fillUnverifiedGaps(
    List<DayRecord> history, {
    required String packageId,
    required DateTime throughDay,
    int resetHour = 4,
  }) {
    if (history.isEmpty) return history;

    final present = {for (final r in history) _dateOnly(r.dayStart)};
    var first = present.first;
    for (final d in present) {
      if (d.isBefore(first)) first = d;
    }
    final last = _dateOnly(throughDay);

    final out = [...history];
    var d = first;
    while (!d.isAfter(last)) {
      if (!present.contains(d)) {
        out.add(DayRecord(
          packageId: packageId,
          dayStart: DateTime(d.year, d.month, d.day, resetHour),
          state: DayState.unverified,
        ));
      }
      d = DateTime(d.year, d.month, d.day + 1);
    }
    return out;
  }
}
