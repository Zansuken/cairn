import 'package:cairn/domain/day_history.dart';
import 'package:cairn/domain/model/day_record.dart';
import 'package:cairn/domain/model/day_state.dart';
import 'package:cairn/domain/streak_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

DayRecord rec(int d, DayState s) =>
    DayRecord(packageId: 'app', dayStart: DateTime(2026, 1, d, 4), state: s);

DayState? stateOn(List<DayRecord> h, int d) {
  for (final r in h) {
    if (r.dayStart == DateTime(2026, 1, d, 4)) return r.state;
  }
  return null;
}

void main() {
  group('DayHistory.fillUnverifiedGaps', () {
    test('fills missing calendar days between the first record and throughDay as unverified', () {
      final filled = DayHistory.fillUnverifiedGaps(
        [rec(1, DayState.clean), rec(3, DayState.clean)],
        packageId: 'app',
        throughDay: DateTime(2026, 1, 4),
      );
      expect(stateOn(filled, 1), DayState.clean);
      expect(stateOn(filled, 2), DayState.unverified);
      expect(stateOn(filled, 3), DayState.clean);
      expect(stateOn(filled, 4), DayState.unverified); // throughDay is inclusive
      expect(filled.length, 4);
    });

    test('leaves an already-contiguous history untouched', () {
      final input = [rec(1, DayState.clean), rec(2, DayState.clean)];
      final filled = DayHistory.fillUnverifiedGaps(
        input,
        packageId: 'app',
        throughDay: DateTime(2026, 1, 2),
      );
      expect(filled.length, 2);
      expect(stateOn(filled, 1), DayState.clean);
      expect(stateOn(filled, 2), DayState.clean);
    });

    test('a stale streak with an unfilled tail gap reads as broken once filled', () {
      // Last finalized day is Jan 3 (clean run), but "today" is Jan 6 → Jan 4,5
      // are missing. After filling through Jan 5, current must be 0.
      final history = [rec(1, DayState.clean), rec(2, DayState.clean), rec(3, DayState.clean)];
      final filled = DayHistory.fillUnverifiedGaps(
        history,
        packageId: 'app',
        throughDay: DateTime(2026, 1, 5),
      );
      final stats = StreakCalculator.appStats(filled);
      expect(stats.current, 0); // chain broken by the unverified gap
      expect(stats.best, 3);
      expect(stats.lifetime, 3);
    });

    test('empty history stays empty (nothing to anchor from)', () {
      final filled = DayHistory.fillUnverifiedGaps(
        const [],
        packageId: 'app',
        throughDay: DateTime(2026, 1, 5),
      );
      expect(filled, isEmpty);
    });
  });
}
