import 'package:cairn/domain/model/day_state.dart';
import 'package:cairn/domain/moment_detector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  AppSnapshot snap(
    String id, {
    required int current,
    int best = 0,
    int lifetime = 0,
    bool freed = false,
    String? name,
    DayState? lastDay,
  }) =>
      AppSnapshot(
        packageId: id,
        name: name ?? id,
        currentStreak: current,
        bestStreak: best,
        lifetimeClean: lifetime,
        isFreed: freed,
        lastDayState: lastDay,
      );

  Map<String, AppSnapshot> map(List<AppSnapshot> snaps) => {for (final s in snaps) s.packageId: s};

  test('no change yields no events (idempotent recompute)', () {
    final before = map([snap('a', current: 12, best: 20, lifetime: 40)]);
    final events = detectMoments(before: before, after: before);
    expect(events, isEmpty);
  });

  test('current dropping from >0 to 0 on a real open is a slip carrying trail + best', () {
    final before = map([snap('a', current: 19, best: 28, lifetime: 47)]);
    final after = map([snap('a', current: 0, best: 28, lifetime: 47, lastDay: DayState.slipped)]);
    final events = detectMoments(before: before, after: after);
    expect(events, hasLength(1));
    expect(events.single.kind, MomentKind.slip);
    expect(events.single.value, 47); // trail = lifetime clean
    expect(events.single.extra, 28); // best run preserved
  });

  test('a run broken by an UNVERIFIED day fires no slip (never a false accusation)', () {
    // Permission was revoked, so yesterday is unverified — the run honestly
    // breaks to 0, but Cairn must not claim the user opened the app.
    final before = map([snap('a', current: 19, best: 28, lifetime: 47)]);
    final after = map([snap('a', current: 0, best: 28, lifetime: 47, lastDay: DayState.unverified)]);
    expect(detectMoments(before: before, after: after), isEmpty);
  });

  test('a drop to 0 with no known last-day verdict fires no slip', () {
    // If we cannot confirm the break was an open, stay silent rather than guess.
    final before = map([snap('a', current: 5)]);
    final after = map([snap('a', current: 0)]);
    expect(detectMoments(before: before, after: after), isEmpty);
  });

  test('crossing a milestone threshold fires a milestone for the highest crossed', () {
    final before = map([snap('a', current: 6)]);
    final after = map([snap('a', current: 8)]);
    final events = detectMoments(before: before, after: after);
    expect(events.single.kind, MomentKind.milestone);
    expect(events.single.value, 7);
  });

  test('landing exactly on a threshold fires it', () {
    final events = detectMoments(
      before: map([snap('a', current: 29)]),
      after: map([snap('a', current: 30)]),
    );
    expect(events.single.kind, MomentKind.milestone);
    expect(events.single.value, 30);
  });

  test('a jump that clears two thresholds reports only the highest', () {
    final events = detectMoments(
      before: map([snap('a', current: 5)]),
      after: map([snap('a', current: 35)]),
    );
    expect(events.single.kind, MomentKind.milestone);
    expect(events.single.value, 30);
  });

  test('no milestone when staying between thresholds', () {
    final events = detectMoments(
      before: map([snap('a', current: 8)]),
      after: map([snap('a', current: 12)]),
    );
    expect(events, isEmpty);
  });

  test('becoming freed fires a freed event with final run + lifetime, not a slip', () {
    final before = map([snap('a', current: 19, best: 31, lifetime: 88)]);
    final after = map([snap('a', current: 19, best: 31, lifetime: 88, freed: true)]);
    final events = detectMoments(before: before, after: after);
    expect(events.single.kind, MomentKind.freed);
    expect(events.single.value, 19); // final run
    expect(events.single.extra, 88); // lifetime clean
  });

  test('already-freed app fires nothing further', () {
    final before = map([snap('a', current: 19, freed: true)]);
    final after = map([snap('a', current: 19, freed: true)]);
    expect(detectMoments(before: before, after: after), isEmpty);
  });

  test('a newly added app (absent before) fires nothing', () {
    final after = map([snap('b', current: 0)]);
    expect(detectMoments(before: const {}, after: after), isEmpty);
  });

  test('events carry the app name for the modal copy', () {
    final events = detectMoments(
      before: map([snap('a', current: 6, name: 'TikTok')]),
      after: map([snap('a', current: 7, name: 'TikTok')]),
    );
    expect(events.single.name, 'TikTok');
  });
}
