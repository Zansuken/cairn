import 'model/day_state.dart';

/// Detects the "moments" worth surfacing (PRD §7) by diffing the cached streak
/// state from before a recompute against after. Pure and synchronous: the data
/// layer snapshots the caches around a reconcile and hands both maps here.
///
/// Comparing before↔after of a single recompute makes detection naturally
/// once-only — a second recompute sees before == after and emits nothing — so no
/// "already shown" bookkeeping is needed.
enum MomentKind { slip, milestone, freed }

class MomentEvent {
  const MomentEvent({
    required this.kind,
    required this.packageId,
    required this.name,
    required this.value,
    this.extra = 0,
  });

  final MomentKind kind;
  final String packageId;
  final String name;

  /// slip → lifetime clean (the trail); milestone → the threshold reached;
  /// freed → the final run.
  final int value;

  /// slip → best run preserved; freed → lifetime clean. Unused otherwise.
  final int extra;
}

/// A snapshot of one app's cached streak numbers at a point in time.
class AppSnapshot {
  const AppSnapshot({
    required this.packageId,
    required this.name,
    required this.currentStreak,
    required this.bestStreak,
    required this.lifetimeClean,
    required this.isFreed,
    this.lastDayState,
  });

  final String packageId;
  final String name;
  final int currentStreak;
  final int bestStreak;
  final int lifetimeClean;
  final bool isFreed;

  /// The most recent finalized day's verdict. Used to tell a real slip (an open)
  /// apart from an unverified break: a run can fall to 0 because the user opened
  /// the app *or* because a day couldn't be verified (permission revoked). Only
  /// the former is a slip — claiming "you opened it" for an unverified day would
  /// break Cairn's honesty promise (PRD §4.5). Null when unknown.
  final DayState? lastDayState;
}

List<MomentEvent> detectMoments({
  required Map<String, AppSnapshot> before,
  required Map<String, AppSnapshot> after,
  List<int> milestones = const [7, 30, 100],
}) {
  final events = <MomentEvent>[];

  for (final entry in after.entries) {
    final now = entry.value;
    final was = before[entry.key];

    // A freshly tracked app (no "before") has no transition to celebrate yet.
    if (was == null) continue;

    // Freed wins and suppresses slip/milestone for the same app.
    if (now.isFreed && !was.isFreed) {
      events.add(MomentEvent(
        kind: MomentKind.freed,
        packageId: now.packageId,
        name: now.name,
        value: now.currentStreak,
        extra: now.lifetimeClean,
      ));
      continue;
    }
    if (now.isFreed) continue; // already freed before → nothing further

    // Slip: an active run collapsed to zero *because of a real open*. A run that
    // fell to 0 on an unverified day (or with no known verdict) breaks honestly
    // but fires no modal — Cairn never claims an open it can't confirm.
    if (was.currentStreak > 0 && now.currentStreak == 0) {
      if (now.lastDayState != DayState.slipped) continue;
      events.add(MomentEvent(
        kind: MomentKind.slip,
        packageId: now.packageId,
        name: now.name,
        value: now.lifetimeClean,
        extra: now.bestStreak,
      ));
      continue;
    }

    // Milestone: highest threshold crossed by this recompute.
    int? crossed;
    for (final t in milestones) {
      if (was.currentStreak < t && now.currentStreak >= t) {
        if (crossed == null || t > crossed) crossed = t;
      }
    }
    if (crossed != null) {
      events.add(MomentEvent(
        kind: MomentKind.milestone,
        packageId: now.packageId,
        name: now.name,
        value: crossed,
      ));
    }
  }

  return events;
}
