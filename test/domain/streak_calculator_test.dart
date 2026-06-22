import 'package:cairn/domain/model/day_record.dart';
import 'package:cairn/domain/model/day_state.dart';
import 'package:cairn/domain/streak_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

DayRecord rec(int d, DayState s, {String pkg = 'app'}) =>
    DayRecord(packageId: pkg, dayStart: DateTime(2026, 1, d, 4), state: s);

DateTime day(int d) => DateTime(2026, 1, d);

MetaAppInput metaApp(List<DayRecord> h, {int from = 1, int? until}) => MetaAppInput(
      history: h,
      activeFrom: day(from),
      activeUntil: until == null ? null : day(until),
    );

void main() {
  group('StreakCalculator.appStats', () {
    test('clean days build the streak; a slip resets current, keeps best/lifetime', () {
      final s = StreakCalculator.appStats([
        rec(1, DayState.clean),
        rec(2, DayState.clean),
        rec(3, DayState.slipped),
      ]);
      expect(s.current, 0);
      expect(s.best, 2);
      expect(s.lifetime, 2);
    });

    test('unverified days are never counted clean and break the chain', () {
      final s = StreakCalculator.appStats([
        rec(1, DayState.clean),
        rec(2, DayState.unverified),
        rec(3, DayState.clean),
      ]);
      expect(s.current, 1);
      expect(s.best, 1);
      expect(s.lifetime, 2);
    });

    test('a trailing unverified day after a long run zeroes current (never falsely clean)', () {
      final s = StreakCalculator.appStats([
        rec(1, DayState.clean),
        rec(2, DayState.clean),
        rec(3, DayState.clean),
        rec(4, DayState.unverified),
      ]);
      expect(s.current, 0);
      expect(s.best, 3);
      expect(s.lifetime, 3);
    });

    test('a single clean day', () {
      final s = StreakCalculator.appStats([rec(1, DayState.clean)]);
      expect(s.current, 1);
      expect(s.best, 1);
      expect(s.lifetime, 1);
    });

    test('a single slipped day', () {
      final s = StreakCalculator.appStats([rec(1, DayState.slipped)]);
      expect(s.current, 0);
      expect(s.best, 0);
      expect(s.lifetime, 0);
    });

    test('lastDate is the most recent finalized day', () {
      final s = StreakCalculator.appStats([rec(1, DayState.clean), rec(5, DayState.clean)]);
      expect(s.lastDate, day(5));
    });
  });

  group('StreakCalculator.metaStats', () {
    test('a day is perfect only when every active app is clean', () {
      final meta = StreakCalculator.metaStats([
        metaApp([rec(1, DayState.clean), rec(2, DayState.clean), rec(3, DayState.clean)]),
        metaApp([rec(1, DayState.clean), rec(2, DayState.slipped), rec(3, DayState.clean)]),
      ]);
      expect(meta.lifetime, 2); // day1 + day3
      expect(meta.current, 1); // day3
      expect(meta.best, 1);
    });

    test('all apps clean every day → meta equals the day count', () {
      final meta = StreakCalculator.metaStats([
        metaApp([rec(1, DayState.clean), rec(2, DayState.clean)]),
        metaApp([rec(1, DayState.clean), rec(2, DayState.clean)]),
      ]);
      expect(meta.current, 2);
      expect(meta.best, 2);
      expect(meta.lifetime, 2);
    });

    test('an unverified app-day is never perfect (brand-critical)', () {
      final meta = StreakCalculator.metaStats([
        metaApp([rec(1, DayState.clean), rec(2, DayState.clean)]),
        metaApp([rec(1, DayState.clean), rec(2, DayState.unverified)]),
      ]);
      expect(meta.lifetime, 1); // only day1
      expect(meta.current, 0);
      expect(meta.best, 1);
    });

    test('an active app missing a record makes that day imperfect', () {
      final meta = StreakCalculator.metaStats([
        metaApp([rec(1, DayState.clean), rec(2, DayState.clean)]),
        metaApp([rec(1, DayState.clean)]), // still active, missing day 2 → genuine gap
      ]);
      expect(meta.lifetime, 1);
      expect(meta.current, 0);
    });

    test('a Freed app is excluded from days after it was freed', () {
      final meta = StreakCalculator.metaStats([
        metaApp([rec(1, DayState.clean), rec(2, DayState.clean), rec(3, DayState.clean), rec(4, DayState.clean)]),
        metaApp([rec(1, DayState.clean), rec(2, DayState.clean)], until: 2), // freed after day 2
      ]);
      expect(meta.current, 4); // days 3,4 perfect on the remaining active app
      expect(meta.best, 4);
      expect(meta.lifetime, 4);
    });

    test('an app added partway does not spoil earlier days', () {
      final meta = StreakCalculator.metaStats([
        metaApp([rec(1, DayState.clean), rec(2, DayState.clean), rec(3, DayState.clean), rec(4, DayState.clean)]),
        metaApp([rec(3, DayState.clean), rec(4, DayState.clean)], from: 3), // added day 3
      ]);
      expect(meta.current, 4);
      expect(meta.best, 4);
      expect(meta.lifetime, 4);
    });

    test('an asymmetric trailing gap (still-active app lacks recent records) zeroes current', () {
      final meta = StreakCalculator.metaStats([
        metaApp([
          rec(1, DayState.clean),
          rec(2, DayState.clean),
          rec(3, DayState.clean),
          rec(4, DayState.clean),
          rec(5, DayState.clean),
        ]),
        metaApp([rec(1, DayState.clean), rec(2, DayState.clean), rec(3, DayState.clean)]), // missing 4,5
      ]);
      expect(meta.lifetime, 3);
      expect(meta.current, 0);
      expect(meta.best, 3);
      expect(meta.lastDate, day(5));
    });

    test('an active app with no records yet → no perfect days', () {
      final meta = StreakCalculator.metaStats([
        metaApp([rec(1, DayState.clean), rec(2, DayState.clean)]),
        metaApp([]),
      ]);
      expect(meta.current, 0);
      expect(meta.lifetime, 0);
    });

    test('no tracked apps → zero', () {
      final meta = StreakCalculator.metaStats([]);
      expect(meta.lifetime, 0);
      expect(meta.current, 0);
    });
  });
}
