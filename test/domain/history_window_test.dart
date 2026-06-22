import 'package:cairn/domain/day_window.dart';
import 'package:cairn/domain/history_window.dart';
import 'package:cairn/domain/model/day_record.dart';
import 'package:cairn/domain/model/day_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const pkg = 'com.example.app';
  const resetHour = 4;

  // A fixed "now" well clear of the reset boundary so the day is unambiguous.
  final now = DateTime(2026, 6, 20, 12);

  DayRecord rec(DateTime now, int daysAgo, DayState state) {
    var d = DayWindow.startOfDay(now, resetHour: resetHour);
    for (var i = 0; i < daysAgo; i++) {
      d = DateTime(d.year, d.month, d.day - 1, d.hour, d.minute);
    }
    return DayRecord(packageId: pkg, dayStart: d, state: state);
  }

  test('returns exactly N states, oldest first, today last', () {
    final states = lastNDaysStates(records: const [], now: now, resetHour: resetHour, days: 30);
    expect(states, hasLength(30));
  });

  test('days with no record are unverified', () {
    final states = lastNDaysStates(records: const [], now: now, resetHour: resetHour, days: 7);
    expect(states, everyElement(DayState.unverified));
  });

  test('a finalized clean/slipped record lands at its day offset from the end', () {
    final records = [
      rec(now, 1, DayState.clean), // yesterday → second-to-last
      rec(now, 3, DayState.slipped), // 3 days ago
    ];
    final states = lastNDaysStates(records: records, now: now, resetHour: resetHour, days: 7);
    // index 6 = today, 5 = yesterday, 3 = three days ago
    expect(states[5], DayState.clean);
    expect(states[3], DayState.slipped);
    expect(states[4], DayState.unverified);
  });

  test('todayOverride sets the final (in-progress) slot', () {
    final states = lastNDaysStates(
      records: const [],
      now: now,
      resetHour: resetHour,
      days: 5,
      todayOverride: DayState.clean,
    );
    expect(states.last, DayState.clean);
    expect(states.take(4), everyElement(DayState.unverified));
  });

  test('without an override, today falls back to its record then to unverified', () {
    final withRecord = lastNDaysStates(
      records: [rec(now, 0, DayState.slipped)],
      now: now,
      resetHour: resetHour,
      days: 3,
    );
    expect(withRecord.last, DayState.slipped);

    final without = lastNDaysStates(records: const [], now: now, resetHour: resetHour, days: 3);
    expect(without.last, DayState.unverified);
  });

  test('records older than the window are ignored', () {
    final states = lastNDaysStates(
      records: [rec(now, 40, DayState.slipped)],
      now: now,
      resetHour: resetHour,
      days: 30,
    );
    expect(states, everyElement(DayState.unverified));
  });
}
