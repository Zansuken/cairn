import 'day_state.dart';

/// A finalized day for one tracked app. [dayStart] is the local reset-hour
/// boundary that opens the day window (see DayWindow).
class DayRecord {
  const DayRecord({
    required this.packageId,
    required this.dayStart,
    required this.state,
  });

  final String packageId;
  final DateTime dayStart;
  final DayState state;
}
