/// Computes the streak "day" window using a configurable reset hour.
///
/// A day runs `[resetHour:00 local, next day resetHour:00 local)`. Usage before
/// the reset hour counts toward the previous day. Default resetHour = 4 (04:00).
/// Promoted from the validated spike and extended for the domain layer.
class DayWindow {
  const DayWindow(this.start, this.end);

  final DateTime start;
  final DateTime end;

  int get startMillis => start.millisecondsSinceEpoch;
  int get endMillis => end.millisecondsSinceEpoch;

  static DayWindow forNow(DateTime now, {int resetHour = 4}) {
    var start = DateTime(now.year, now.month, now.day, resetHour);
    if (now.isBefore(start)) {
      // Construct via day-1 (not Duration) so month/year rollover and DST are
      // handled by DateTime's own normalization.
      start = DateTime(now.year, now.month, now.day - 1, resetHour);
    }
    final end = DateTime(start.year, start.month, start.day + 1, resetHour);
    return DayWindow(start, end);
  }

  static DateTime startOfDay(DateTime now, {int resetHour = 4}) =>
      forNow(now, resetHour: resetHour).start;

  /// The window opened by a known reset-hour boundary [start]. End is the next
  /// calendar day at the same hour (DST-safe via DateTime normalization).
  static DayWindow fromStart(DateTime start) =>
      DayWindow(start, DateTime(start.year, start.month, start.day + 1, start.hour, start.minute));
}
