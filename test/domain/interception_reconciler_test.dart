import 'package:cairn/domain/interception_reconciler.dart';
import 'package:cairn/domain/model/day_state.dart';
import 'package:cairn/domain/model/interception_event.dart';
import 'package:cairn/domain/model/interception_outcome.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // An interception captured at OS-event time [fgMillis], with [outcome].
  InterceptionEvent ev(int fgMillis, InterceptionOutcome outcome) => InterceptionEvent(
        packageId: 'com.app',
        foregroundAt: DateTime.fromMillisecondsSinceEpoch(fgMillis),
        outcome: outcome,
        recordedAt: DateTime.fromMillisecondsSinceEpoch(fgMillis + 100),
      );

  DayState classify(List<int> osOpens, List<InterceptionEvent> interceptions) =>
      InterceptionReconciler.classifyDay(osOpens: osOpens, interceptions: interceptions);

  // Base instant for the day's opens (arbitrary epoch millis).
  const t = 1750000000000;

  test('no OS opens and no interceptions returns clean', () {
    expect(classify(const [], const []), DayState.clean);
  });

  test('OS open exactly matched by a resisted interception returns clean', () {
    expect(classify([t], [ev(t, InterceptionOutcome.resisted)]), DayState.clean);
  });

  test('OS open exactly matched by an allowed interception returns slipped', () {
    expect(classify([t], [ev(t, InterceptionOutcome.allowed)]), DayState.slipped);
  });

  test('two OS opens both matched by resisted returns clean', () {
    expect(
      classify([t, t + 60000], [
        ev(t, InterceptionOutcome.resisted),
        ev(t + 60000, InterceptionOutcome.resisted),
      ]),
      DayState.clean,
    );
  });

  test('two OS opens one resisted one allowed returns slipped', () {
    expect(
      classify([t, t + 60000], [
        ev(t, InterceptionOutcome.resisted),
        ev(t + 60000, InterceptionOutcome.allowed),
      ]),
      DayState.slipped,
    );
  });

  test('OS open with no interception at all returns unverified', () {
    expect(classify([t], const []), DayState.unverified);
  });

  test('OS open matched only by a shown interception returns unverified', () {
    // "shown" with no resisted/allowed outcome does not excuse the open.
    expect(classify([t], [ev(t, InterceptionOutcome.shown)]), DayState.unverified);
  });

  test('interception 5000ms away does not match and returns unverified', () {
    expect(classify([t], [ev(t + 5000, InterceptionOutcome.resisted)]), DayState.unverified);
  });

  test('interception 1500ms away (within tolerance) matches a resisted and returns clean', () {
    expect(classify([t], [ev(t + 1500, InterceptionOutcome.resisted)]), DayState.clean);
  });

  test('one resisted-matched open plus one unmatched open returns unverified', () {
    expect(
      classify([t, t + 60000], [ev(t, InterceptionOutcome.resisted)]),
      DayState.unverified,
    );
  });

  test('allowed anywhere in the day dominates: slipped even with a resisted open present', () {
    // Explicit drop of "nearest wins": an allowed is never masked by a resisted.
    expect(
      classify([t, t + 60000], [
        ev(t, InterceptionOutcome.resisted),
        ev(t + 60000, InterceptionOutcome.allowed),
      ]),
      DayState.slipped,
    );
  });

  test('an allowed interception with no corresponding OS open still returns slipped', () {
    // User chose Open anyway; the OS event may have rolled off, but they opened it.
    expect(classify(const [], [ev(t, InterceptionOutcome.allowed)]), DayState.slipped);
  });
}
