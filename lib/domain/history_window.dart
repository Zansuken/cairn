import 'day_window.dart';
import 'model/day_record.dart';
import 'model/day_state.dart';

/// Builds the last [days] day-verdicts for one app, oldest first, today last —
/// the dot grid on App detail (PRD §6). Days with no finalized record show as
/// `unverified` (never silently clean). The final slot is the in-progress day:
/// [todayOverride] (the live "still clean / opened" status) wins, otherwise it
/// falls back to a finalized record for today, otherwise `unverified`.
List<DayState> lastNDaysStates({
  required List<DayRecord> records,
  required DateTime now,
  required int resetHour,
  int days = 30,
  DayState? todayOverride,
}) {
  // Index records by calendar date of their day-start so a DST hour shift can't
  // cause a miss.
  final byDate = <int, DayState>{
    for (final r in records) _dateKey(r.dayStart): r.state,
  };

  final today = DayWindow.startOfDay(now, resetHour: resetHour);
  final out = List<DayState>.filled(days, DayState.unverified);
  var day = today;
  for (var i = days - 1; i >= 0; i--) {
    final isToday = i == days - 1;
    if (isToday && todayOverride != null) {
      out[i] = todayOverride;
    } else {
      out[i] = byDate[_dateKey(day)] ?? DayState.unverified;
    }
    day = DateTime(day.year, day.month, day.day - 1, day.hour, day.minute);
  }
  return out;
}

int _dateKey(DateTime d) => d.year * 10000 + d.month * 100 + d.day;
