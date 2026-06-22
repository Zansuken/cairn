import 'model/day_state.dart';
import 'model/interception_event.dart';
import 'model/interception_outcome.dart';

/// Reclassifies a completed day for one tracked app by reconciling the OS usage
/// log against the speed-bump interception records (PRD roadmap: Intervention
/// speed bump). Pure and synchronous.
///
/// The honesty rules — a day is:
/// - **slipped** if the user chose "Open anyway" at all that day (an [allowed]
///   interception). A real, chosen open dominates everything else.
/// - **clean** if every OS-logged open is excused by a matching "Stay strong"
///   ([resisted]) interception within [matchToleranceMillis]. Resisting a bump
///   must never break the run.
/// - **unverified** if any OS-logged open has no matching resisted interception
///   (our service could not vouch for it). Never silently clean, and never a
///   false "you opened it".
///
/// Matching is on the real OS event timestamp ([InterceptionEvent.foregroundAt]
/// vs the `osOpens` event millis); the tolerance is only a safety net for the OS
/// reporting the same event with a slightly different stamp across two queries.
abstract final class InterceptionReconciler {
  InterceptionReconciler._();

  static DayState classifyDay({
    required List<int> osOpens,
    required List<InterceptionEvent> interceptions,
    int matchToleranceMillis = 2000,
  }) {
    // A chosen "Open anyway" anywhere in the day is a real open — it dominates,
    // even with no corresponding OS event (the event may have rolled off).
    final hasAllowed = interceptions.any((e) => e.outcome == InterceptionOutcome.allowed);
    if (hasAllowed) return DayState.slipped;

    final resistedAt = [
      for (final e in interceptions)
        if (e.outcome == InterceptionOutcome.resisted) e.foregroundAt.millisecondsSinceEpoch,
    ];
    for (final open in osOpens) {
      final excused = resistedAt.any((r) => (r - open).abs() <= matchToleranceMillis);
      if (!excused) return DayState.unverified;
    }
    return DayState.clean;
  }
}
