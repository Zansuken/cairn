import 'interception_outcome.dart';

/// One speed-bump interception for a tracked app. [foregroundAt] is the OS
/// MOVE_TO_FOREGROUND event time the native service captured — it is the match
/// key against the usage log, NOT the time the bump was shown. [recordedAt] is
/// when the native overlay wrote the line to the journal.
class InterceptionEvent {
  const InterceptionEvent({
    required this.packageId,
    required this.foregroundAt,
    required this.outcome,
    required this.recordedAt,
  });

  final String packageId;
  final DateTime foregroundAt;
  final InterceptionOutcome outcome;
  final DateTime recordedAt;
}
