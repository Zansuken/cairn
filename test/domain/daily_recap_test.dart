import 'package:cairn/domain/daily_recap.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  RecapInput app(String name, RecapState state, {int streak = 0}) =>
      RecapInput(packageId: name, name: name, monogram: name[0], state: state, currentStreak: streak);

  DailyRecap build(List<RecapInput> apps, {int lifetime = 0, int perfect = 0}) =>
      buildDailyRecap(apps: apps, lifetimeClean: lifetime, perfectRun: perfect);

  test('counts how many cairns grew (stayed clean) yesterday', () {
    final r = build([
      app('Reddit', RecapState.clean, streak: 47),
      app('YouTube', RecapState.clean, streak: 34),
      app('Instagram', RecapState.clean, streak: 19),
      app('TikTok', RecapState.slipped),
    ]);
    expect(r.grew, 3);
    expect(r.total, 4);
    expect(r.anyReset, isTrue);
    expect(r.headline, '3 of 4 cairns grew yesterday.');
  });

  test('a reset carries the gentle "trail is safe" subtitle', () {
    final r = build([
      app('A', RecapState.clean, streak: 5),
      app('B', RecapState.slipped),
    ]);
    expect(r.subtitle, contains('trail is safe'));
  });

  test('multiple resets pluralize', () {
    final r = build([
      app('A', RecapState.slipped),
      app('B', RecapState.slipped),
    ]);
    expect(r.headline, '0 of 2 cairns grew yesterday.');
    expect(r.subtitle, contains('2 stacks reset'));
  });

  test('a clean sweep reads as celebration, no reset language', () {
    final r = build([
      app('A', RecapState.clean, streak: 3),
      app('B', RecapState.clean, streak: 8),
    ]);
    expect(r.anyReset, isFalse);
    expect(r.headline, 'All 2 cairns grew yesterday.');
    expect(r.subtitle.toLowerCase(), contains('clean sweep'));
  });

  test('a single tracked app uses singular phrasing', () {
    final grew = build([app('A', RecapState.clean, streak: 2)]);
    expect(grew.headline, 'Your cairn grew yesterday.');

    final reset = build([app('A', RecapState.slipped)]);
    expect(reset.headline, 'Your cairn reset yesterday.');
  });

  test('a single unverified app is never reported as a reset', () {
    // Honesty: an unverified day is not a slip, so the headline must not say
    // "reset" — it must say it couldn't be verified.
    final r = build([app('A', RecapState.unverified)]);
    expect(r.headline.toLowerCase(), isNot(contains('reset')));
    expect(r.headline.toLowerCase(), contains('verif'));
  });

  test('unverified days are reported honestly, not as clean', () {
    final r = build([
      app('A', RecapState.clean, streak: 4),
      app('B', RecapState.unverified),
    ]);
    expect(r.grew, 1);
    expect(r.anyReset, isFalse);
    expect(r.subtitle.toLowerCase(), contains('verif'));
  });

  test('carries lifetime + perfect-run through for the strip', () {
    final r = build([app('A', RecapState.clean, streak: 1)], lifetime: 132, perfect: 0);
    expect(r.lifetimeClean, 132);
    expect(r.perfectRun, 0);
  });

  test('rows preserve their input order and state', () {
    final r = build([
      app('Reddit', RecapState.clean, streak: 47),
      app('TikTok', RecapState.slipped),
    ]);
    expect(r.rows.map((e) => e.name), ['Reddit', 'TikTok']);
    expect(r.rows[1].state, RecapState.slipped);
  });
}
