/// One calendar day's verdict for streak purposes: was it "good" (clean for an
/// app, or perfect for the meta-streak)? Slipped *and* unverified days are both
/// `good: false` — the slip/unverified distinction is a label, not a number.
class DayMark {
  const DayMark(this.date, {required this.good});

  final DateTime date;
  final bool good;
}

/// The three numbers that fall out of a day history.
class StreakStats {
  const StreakStats({
    required this.current,
    required this.best,
    required this.lifetime,
    required this.lastDate,
  });

  /// Consecutive good days ending at the most recent finalized day (0 if that
  /// day is not good).
  final int current;

  /// Longest run of consecutive good days ever.
  final int best;

  /// Total good days (monotonic; never decreases).
  final int lifetime;

  /// Calendar date of the most recent finalized day, or null if none.
  final DateTime? lastDate;

  /// Enforces the monotonic invariants (PRD §2): lifetime never resets and best
  /// never decreases. When recomputing from a history that may have been pruned
  /// (OS retention, cache rebuild), reconcile against the persisted [cached]
  /// values so neither regresses. `current` and `lastDate` come from the fresh
  /// computation.
  StreakStats reconciledWith(StreakStats cached) {
    return StreakStats(
      current: current,
      best: best > cached.best ? best : cached.best,
      lifetime: lifetime > cached.lifetime ? lifetime : cached.lifetime,
      lastDate: lastDate,
    );
  }
}

/// Pure streak arithmetic shared by the per-app and meta calculators.
abstract final class StreakMath {
  StreakMath._();

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// True when [b] is the calendar day immediately after [a] (both date-only).
  static bool _isNextDay(DateTime a, DateTime b) =>
      DateTime(a.year, a.month, a.day + 1) == b;

  static StreakStats compute(List<DayMark> marks) {
    if (marks.isEmpty) {
      return const StreakStats(current: 0, best: 0, lifetime: 0, lastDate: null);
    }

    // Collapse marks that fall on the same calendar day. The day is good only
    // if *every* mark for it is good — a slip/unverified can never be erased by
    // a clean record for the same day (honesty bias). This also makes the result
    // independent of input order and robust to duplicate records.
    final goodByDate = <DateTime, bool>{};
    for (final m in marks) {
      final d = _dateOnly(m.date);
      goodByDate[d] = (goodByDate[d] ?? true) && m.good;
    }
    final days = [
      for (final e in goodByDate.entries) DayMark(e.key, good: e.value),
    ]..sort((a, b) => a.date.compareTo(b.date));

    var lifetime = 0;
    var best = 0;
    var run = 0;
    DateTime? prev;
    for (final m in days) {
      if (m.good) {
        run = (prev != null && _isNextDay(prev, m.date)) ? run + 1 : 1;
        lifetime++;
        if (run > best) best = run;
      } else {
        run = 0;
      }
      prev = m.date;
    }

    // Current = the trailing run of good days ending at the most recent day.
    var current = 0;
    DateTime? later;
    for (var i = days.length - 1; i >= 0; i--) {
      final m = days[i];
      if (!m.good) break;
      if (later != null && !_isNextDay(m.date, later)) break;
      current++;
      later = m.date;
    }

    return StreakStats(
      current: current,
      best: best,
      lifetime: lifetime,
      lastDate: days.last.date,
    );
  }
}
