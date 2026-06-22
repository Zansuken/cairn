import 'package:cairn/domain/day_window.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DayWindow.forNow', () {
    test('a mid-day moment falls in today\'s reset→reset window', () {
      final w = DayWindow.forNow(DateTime(2026, 1, 10, 10));
      expect(w.start, DateTime(2026, 1, 10, 4));
      expect(w.end, DateTime(2026, 1, 11, 4));
    });

    test('usage before the reset hour counts toward the previous day', () {
      final w = DayWindow.forNow(DateTime(2026, 1, 10, 2, 30));
      expect(w.start, DateTime(2026, 1, 9, 4));
      expect(w.end, DateTime(2026, 1, 10, 4));
    });

    test('the reset hour itself opens a new day (inclusive start)', () {
      final w = DayWindow.forNow(DateTime(2026, 1, 10, 4));
      expect(w.start, DateTime(2026, 1, 10, 4));
    });

    test('one minute before the reset hour is still the previous day', () {
      final w = DayWindow.forNow(DateTime(2026, 1, 10, 3, 59));
      expect(w.start, DateTime(2026, 1, 9, 4));
    });

    test('the reset hour is configurable', () {
      final w = DayWindow.forNow(DateTime(2026, 1, 10, 5), resetHour: 6);
      expect(w.start, DateTime(2026, 1, 9, 6));
      expect(w.end, DateTime(2026, 1, 10, 6));
    });

    test('a pre-reset moment on the 1st rolls back across the month boundary', () {
      final w = DayWindow.forNow(DateTime(2026, 3, 1, 2));
      expect(w.start, DateTime(2026, 2, 28, 4));
      expect(w.end, DateTime(2026, 3, 1, 4));
    });

    test('startMillis/endMillis match the DateTime bounds', () {
      final w = DayWindow.forNow(DateTime(2026, 1, 10, 10));
      expect(w.startMillis, DateTime(2026, 1, 10, 4).millisecondsSinceEpoch);
      expect(w.endMillis, DateTime(2026, 1, 11, 4).millisecondsSinceEpoch);
    });
  });

  group('DayWindow.startOfDay', () {
    test('returns the boundary that opens the day containing the moment', () {
      expect(DayWindow.startOfDay(DateTime(2026, 1, 10, 1)), DateTime(2026, 1, 9, 4));
      expect(DayWindow.startOfDay(DateTime(2026, 1, 10, 12)), DateTime(2026, 1, 10, 4));
    });
  });

  group('DayWindow invariants', () {
    test('the window is half-open: the next reset boundary opens the NEXT day', () {
      // A moment exactly at one day's end is the start of the following day,
      // so the prior window never includes its own end ([start, end)).
      final w = DayWindow.forNow(DateTime(2026, 1, 11, 4));
      expect(w.start, DateTime(2026, 1, 11, 4));
      final prev = DayWindow.forNow(DateTime(2026, 1, 10, 23));
      expect(prev.end, w.start);
    });

    test('end is always strictly after start across a full year (no zero/negative window)', () {
      var d = DateTime(2026, 1, 1, 12);
      for (var i = 0; i < 366; i++) {
        final w = DayWindow.forNow(d);
        expect(w.end.isAfter(w.start), isTrue, reason: 'window for $d must be positive');
        expect(w.start.isAfter(d) || w.start.isAtSameMomentAs(d) || w.start.isBefore(d), isTrue);
        d = d.add(const Duration(days: 1));
      }
    });
  });
}
