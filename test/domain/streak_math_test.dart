import 'package:cairn/domain/streak_math.dart';
import 'package:flutter_test/flutter_test.dart';

/// A day mark at the 04:00 boundary of the given calendar date.
DayMark mark(int y, int m, int d, {required bool good}) =>
    DayMark(DateTime(y, m, d, 4), good: good);

void main() {
  group('StreakMath.compute', () {
    test('empty history yields all-zero stats with no last date', () {
      final s = StreakMath.compute([]);
      expect(s.current, 0);
      expect(s.best, 0);
      expect(s.lifetime, 0);
      expect(s.lastDate, isNull);
    });

    test('a run of consecutive clean days counts for current, best and lifetime', () {
      final s = StreakMath.compute([
        mark(2026, 1, 1, good: true),
        mark(2026, 1, 2, good: true),
        mark(2026, 1, 3, good: true),
      ]);
      expect(s.current, 3);
      expect(s.best, 3);
      expect(s.lifetime, 3);
    });

    test('a slip resets the current run to 0 but preserves best and lifetime', () {
      final s = StreakMath.compute([
        mark(2026, 1, 1, good: true),
        mark(2026, 1, 2, good: true),
        mark(2026, 1, 3, good: true),
        mark(2026, 1, 4, good: false),
      ]);
      expect(s.current, 0);
      expect(s.best, 3);
      expect(s.lifetime, 3);
    });

    test('current counts only the trailing clean run after a slip', () {
      final s = StreakMath.compute([
        mark(2026, 1, 1, good: true),
        mark(2026, 1, 2, good: true),
        mark(2026, 1, 3, good: true),
        mark(2026, 1, 4, good: false),
        mark(2026, 1, 5, good: true),
        mark(2026, 1, 6, good: true),
      ]);
      expect(s.current, 2);
      expect(s.best, 3);
      expect(s.lifetime, 5);
    });

    test('an unverified day breaks the chain and is never counted clean', () {
      // day 3 is unverified (good:false) — never clean, breaks the run honestly
      final s = StreakMath.compute([
        mark(2026, 1, 1, good: true),
        mark(2026, 1, 2, good: true),
        mark(2026, 1, 3, good: false),
        mark(2026, 1, 4, good: true),
      ]);
      expect(s.current, 1);
      expect(s.best, 2);
      expect(s.lifetime, 3);
    });

    test('a missing calendar day breaks the run even when both sides are clean', () {
      // Jan 3 absent → gap → not consecutive
      final s = StreakMath.compute([
        mark(2026, 1, 1, good: true),
        mark(2026, 1, 2, good: true),
        mark(2026, 1, 4, good: true),
      ]);
      expect(s.current, 1);
      expect(s.best, 2);
      expect(s.lifetime, 3);
    });

    test('best picks the longest of several runs', () {
      final s = StreakMath.compute([
        mark(2026, 1, 1, good: true),
        mark(2026, 1, 2, good: true),
        mark(2026, 1, 3, good: false),
        mark(2026, 1, 4, good: true),
        mark(2026, 1, 5, good: true),
        mark(2026, 1, 6, good: true),
        mark(2026, 1, 7, good: true),
        mark(2026, 1, 8, good: false),
      ]);
      expect(s.best, 4);
      expect(s.current, 0);
      expect(s.lifetime, 6);
    });

    test('current is 0 when the most recent finalized day is not clean', () {
      final s = StreakMath.compute([
        mark(2026, 1, 1, good: true),
        mark(2026, 1, 2, good: false),
      ]);
      expect(s.current, 0);
    });

    test('runs spanning a month/year boundary are consecutive', () {
      final s = StreakMath.compute([
        mark(2025, 12, 30, good: true),
        mark(2025, 12, 31, good: true),
        mark(2026, 1, 1, good: true),
      ]);
      expect(s.current, 3);
      expect(s.best, 3);
      expect(s.lifetime, 3);
    });

    test('unordered input is sorted by date before computing', () {
      final s = StreakMath.compute([
        mark(2026, 1, 3, good: true),
        mark(2026, 1, 1, good: true),
        mark(2026, 1, 2, good: true),
      ]);
      expect(s.current, 3);
      expect(s.best, 3);
      expect(s.lastDate, DateTime(2026, 1, 3));
    });
  });

  group('StreakMath.compute deduplicates same-day marks (non-clean wins)', () {
    test('duplicate clean marks for one day count once toward lifetime', () {
      final s = StreakMath.compute([
        mark(2026, 1, 1, good: true),
        mark(2026, 1, 1, good: true),
        mark(2026, 1, 2, good: true),
      ]);
      expect(s.lifetime, 2);
      expect(s.current, 2);
      expect(s.best, 2);
    });

    test('a duplicate in the middle does not break the run', () {
      final s = StreakMath.compute([
        mark(2026, 1, 1, good: true),
        mark(2026, 1, 2, good: true),
        mark(2026, 1, 2, good: true),
        mark(2026, 1, 3, good: true),
      ]);
      expect(s.current, 3);
      expect(s.best, 3);
      expect(s.lifetime, 3);
    });

    test('conflicting same-day verdicts resolve to not-good regardless of order', () {
      final a = StreakMath.compute([mark(2026, 1, 2, good: false), mark(2026, 1, 2, good: true)]);
      final b = StreakMath.compute([mark(2026, 1, 2, good: true), mark(2026, 1, 2, good: false)]);
      for (final s in [a, b]) {
        expect(s.lifetime, 0);
        expect(s.current, 0);
        expect(s.best, 0);
      }
    });
  });

  group('StreakStats.reconciledWith (monotonic invariants)', () {
    test('best never decreases and lifetime never resets below the cached values', () {
      // Recompute over a pruned history (only 2 clean days survive)…
      final fresh = StreakMath.compute([mark(2026, 2, 1, good: true), mark(2026, 2, 2, good: true)]);
      // …against a cache that remembers a longer past.
      const cached = StreakStats(current: 0, best: 10, lifetime: 20, lastDate: null);
      final r = fresh.reconciledWith(cached);
      expect(r.best, 10); // not 2
      expect(r.lifetime, 20); // not 2
      expect(r.current, fresh.current); // current comes from the fresh compute
      expect(r.lastDate, fresh.lastDate);
    });

    test('a larger fresh computation wins over a smaller cache', () {
      final fresh = StreakMath.compute([
        for (var d = 1; d <= 5; d++) mark(2026, 1, d, good: true),
      ]);
      const cached = StreakStats(current: 0, best: 3, lifetime: 4, lastDate: null);
      final r = fresh.reconciledWith(cached);
      expect(r.best, 5);
      expect(r.lifetime, 5);
    });
  });
}
