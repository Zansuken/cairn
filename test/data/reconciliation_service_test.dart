import 'package:cairn/data/db/database.dart';
import 'package:cairn/data/db/mappers.dart';
import 'package:cairn/data/reconciliation_service.dart';
import 'package:cairn/domain/day_window.dart';
import 'package:cairn/domain/model/day_record.dart';
import 'package:cairn/domain/model/day_state.dart';
import 'package:cairn/domain/model/interception_event.dart';
import 'package:cairn/domain/model/interception_outcome.dart';
import 'package:cairn/domain/model/tracked_app.dart';
import 'package:cairn/platform/usage_service.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Configurable fake of the native bridge.
class FakeUsageGateway implements UsageGateway {
  FakeUsageGateway({
    this.installed,
    Map<String, Set<int>>? openedWindows,
    Map<String, List<int>>? events,
  })  : opened = openedWindows ?? {},
        openEvents = events ?? {};

  final Set<String>? installed; // null/empty → query "failed" (returns none)
  final Map<String, Set<int>> opened; // packageId → window start millis that were opened
  final Map<String, List<int>> openEvents; // packageId → per-open event millis

  @override
  Future<bool> isUsageAccessGranted() async => true;

  @override
  Future<void> openUsageAccessSettings() async {}

  @override
  Future<Set<String>> openedPackages(List<String> packages, int startMillis, int endMillis) async {
    return {
      for (final p in packages)
        if ((opened[p]?.contains(startMillis) ?? false) ||
            (openEvents[p]?.any((t) => t >= startMillis && t < endMillis) ?? false))
          p,
    };
  }

  @override
  Future<List<int>> openTimestamps(String packageId, int startMillis, int endMillis) async =>
      (openEvents[packageId] ?? const <int>[]).where((t) => t >= startMillis && t < endMillis).toList();

  @override
  Future<List<InstalledApp>> installedApps({bool withIcons = false}) async =>
      (installed ?? const <String>{}).map((p) => InstalledApp(packageId: p, label: p)).toList();
}

int winStart(int y, int m, int d, {int hour = 4}) => DateTime(y, m, d, hour).millisecondsSinceEpoch;

void main() {
  late CairnDatabase db;

  setUp(() => db = CairnDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> track(String pkg, DateTime addedAt) =>
      db.trackedAppsDao.upsert(TrackedApp(packageId: pkg, displayName: pkg, addedAt: addedAt));

  // "now" = Jan 10, 12:00 → today window opens Jan 10 04:00; completed days are
  // Jan 9 and Jan 8 (retentionDays = 2).
  final now = DateTime(2026, 1, 10, 12);

  Future<void> seed(String pkg, DateTime fg, InterceptionOutcome outcome) async {
    final dayStart = DayWindow.startOfDay(fg, resetHour: 4).millisecondsSinceEpoch;
    await db.interceptionDao.upsertAll([
      InterceptionEvent(
        packageId: pkg,
        foregroundAt: fg,
        outcome: outcome,
        recordedAt: fg.add(const Duration(milliseconds: 100)),
      ).toCompanion(dayStartMillis: dayStart),
    ]);
  }

  Future<void> enableSpeedBump(DateTime at) => db.settingsDao.save(AppSettingsCompanion(
        speedBumpEnabled: const Value(true),
        speedBumpEnabledAtMillis: Value(at.millisecondsSinceEpoch),
      ));

  test('finalizes the last completed days as clean when the app was not opened', () async {
    await track('com.x', DateTime(2026, 1, 1));
    final svc = ReconciliationService(db: db, gateway: FakeUsageGateway(installed: {'com.x'}));

    await svc.reconcile(now: now);

    final history = await db.dayRecordsDao.historyFor('com.x');
    expect(history.map((r) => r.dayStart.day), [8, 9]);
    expect(history.every((r) => r.state == DayState.clean), true);

    final cache = await db.streakCacheDao.appState('com.x');
    expect(cache!.currentStreak, 2);
    expect(cache.bestStreak, 2);
    expect(cache.lifetimeCleanDays, 2);
  });

  test('a foreground open in a completed window finalizes that day as slipped', () async {
    await track('com.x', DateTime(2026, 1, 1));
    final svc = ReconciliationService(
      db: db,
      gateway: FakeUsageGateway(
        installed: {'com.x'},
        openedWindows: {
          'com.x': {winStart(2026, 1, 9)},
        },
      ),
    );

    await svc.reconcile(now: now);

    final history = await db.dayRecordsDao.historyFor('com.x');
    expect(history.firstWhere((r) => r.dayStart.day == 9).state, DayState.slipped);
    expect(history.firstWhere((r) => r.dayStart.day == 8).state, DayState.clean);

    final cache = await db.streakCacheDao.appState('com.x');
    expect(cache!.currentStreak, 0); // trailing day slipped
    expect(cache.bestStreak, 1);
    expect(cache.lifetimeCleanDays, 1);
  });

  test('older missing days (beyond retention) are materialised as unverified', () async {
    await track('com.x', DateTime(2026, 1, 1));
    // Seed a clean day far back so the fill range spans a gap.
    await db.dayRecordsDao.upsert(
      DayRecord(packageId: 'com.x', dayStart: DateTime(2026, 1, 5, 4), state: DayState.clean),
      finalizedAt: now,
    );
    final svc = ReconciliationService(db: db, gateway: FakeUsageGateway(installed: {'com.x'}));

    await svc.reconcile(now: now);

    final history = await db.dayRecordsDao.historyFor('com.x');
    final byDay = {for (final r in history) r.dayStart.day: r.state};
    expect(byDay[5], DayState.clean);
    expect(byDay[6], DayState.unverified);
    expect(byDay[7], DayState.unverified);
    expect(byDay[8], DayState.clean);
    expect(byDay[9], DayState.clean);

    final cache = await db.streakCacheDao.appState('com.x');
    expect(cache!.currentStreak, 2); // Jan 8 + Jan 9; the unverified gap breaks earlier
    expect(cache.lifetimeCleanDays, 3); // Jan 5, 8, 9
  });

  test('meta-streak reflects all active apps clean', () async {
    await track('com.a', DateTime(2026, 1, 1));
    await track('com.b', DateTime(2026, 1, 1));
    final svc = ReconciliationService(db: db, gateway: FakeUsageGateway(installed: {'com.a', 'com.b'}));

    await svc.reconcile(now: now);

    final meta = await db.streakCacheDao.meta();
    expect(meta.currentMetaStreak, 2); // Jan 8 + Jan 9 perfect for both
    expect(meta.lifetimePerfectDays, 2);
  });

  test('an uninstalled tracked app is converted to the Freed trophy', () async {
    await track('com.gone', DateTime(2026, 1, 1));
    // installed set does NOT contain com.gone → detected as uninstalled.
    final svc = ReconciliationService(db: db, gateway: FakeUsageGateway(installed: {'other.app'}));

    await svc.reconcile(now: now);

    final app = await db.trackedAppsDao.find('com.gone');
    expect(app!.isFreed, true);
    expect(app.freedAt, now);
  });

  // ── Speed-bump interception integration ─────────────────────────────────────

  test('a resisted interception keeps the completed day clean', () async {
    await track('com.x', DateTime(2026, 1, 1));
    final fg = DateTime(2026, 1, 9, 10); // an open during Jan 9, resisted
    await seed('com.x', fg, InterceptionOutcome.resisted);
    final svc = ReconciliationService(
      db: db,
      gateway: FakeUsageGateway(installed: {'com.x'}, events: {
        'com.x': [fg.millisecondsSinceEpoch],
      }),
    );

    await svc.reconcile(now: now);

    final history = await db.dayRecordsDao.historyFor('com.x');
    expect(history.firstWhere((r) => r.dayStart.day == 9).state, DayState.clean);
    expect((await db.streakCacheDao.appState('com.x'))!.currentStreak, 2); // Jan 8 + Jan 9
  });

  test('an allowed interception finalizes the day as slipped and breaks the streak', () async {
    await track('com.x', DateTime(2026, 1, 1));
    final fg = DateTime(2026, 1, 9, 10);
    await seed('com.x', fg, InterceptionOutcome.allowed);
    final svc = ReconciliationService(
      db: db,
      gateway: FakeUsageGateway(installed: {'com.x'}, events: {
        'com.x': [fg.millisecondsSinceEpoch],
      }),
    );

    await svc.reconcile(now: now);

    final history = await db.dayRecordsDao.historyFor('com.x');
    expect(history.firstWhere((r) => r.dayStart.day == 9).state, DayState.slipped);
    expect((await db.streakCacheDao.appState('com.x'))!.currentStreak, 0);
  });

  test('an open with no interception, after the feature was enabled, is unverified not slipped', () async {
    await track('com.x', DateTime(2026, 1, 1));
    await enableSpeedBump(DateTime(2026, 1, 1)); // on since before Jan 9
    final fg = DateTime(2026, 1, 9, 10);
    final svc = ReconciliationService(
      db: db,
      gateway: FakeUsageGateway(installed: {'com.x'}, events: {
        'com.x': [fg.millisecondsSinceEpoch],
      }),
    );

    await svc.reconcile(now: now);

    final history = await db.dayRecordsDao.historyFor('com.x');
    expect(history.firstWhere((r) => r.dayStart.day == 9).state, DayState.unverified);
    expect(history.firstWhere((r) => r.dayStart.day == 8).state, DayState.clean); // no open Jan 8
  });

  test('the legacy path keeps an open as slipped for a day before the feature was enabled', () async {
    await track('com.x', DateTime(2026, 1, 1));
    await enableSpeedBump(now); // enabled only "now": Jan 9 ends before this
    final svc = ReconciliationService(
      db: db,
      gateway: FakeUsageGateway(
        installed: {'com.x'},
        openedWindows: {
          'com.x': {winStart(2026, 1, 9)},
        },
      ),
    );

    await svc.reconcile(now: now);

    final history = await db.dayRecordsDao.historyFor('com.x');
    expect(history.firstWhere((r) => r.dayStart.day == 9).state, DayState.slipped);
  });

  test('a resisted interception older than the retention window is still finalized as clean', () async {
    await track('com.x', DateTime(2026, 1, 1));
    final fg = DateTime(2026, 1, 5, 10); // Jan 5, older than the Jan 8/9 retention window
    await seed('com.x', fg, InterceptionOutcome.resisted);
    final svc = ReconciliationService(
      db: db,
      gateway: FakeUsageGateway(installed: {'com.x'}, events: {
        'com.x': [fg.millisecondsSinceEpoch],
      }),
    );

    await svc.reconcile(now: now);

    final byDay = {for (final r in await db.dayRecordsDao.historyFor('com.x')) r.dayStart.day: r.state};
    expect(byDay[5], DayState.clean); // finalized by the extended loop despite its age
    expect(byDay[6], DayState.unverified); // gap fill kicks in after the first record
  });

  test('prune drops interception rows for finalized days but keeps today\'s', () async {
    await track('com.x', DateTime(2026, 1, 1));
    final yesterdayFg = DateTime(2026, 1, 9, 10); // completed day
    final todayFg = DateTime(2026, 1, 10, 10); // today (after the 04:00 reset)
    await seed('com.x', yesterdayFg, InterceptionOutcome.resisted);
    await seed('com.x', todayFg, InterceptionOutcome.shown);
    final svc = ReconciliationService(
      db: db,
      gateway: FakeUsageGateway(installed: {'com.x'}, events: {
        'com.x': [yesterdayFg.millisecondsSinceEpoch, todayFg.millisecondsSinceEpoch],
      }),
    );

    await svc.reconcile(now: now);

    final remaining = await db.interceptionDao.daysWithInterceptions('com.x');
    final todayStart = DayWindow.startOfDay(now, resetHour: 4).millisecondsSinceEpoch;
    expect(remaining, [todayStart]); // Jan 9 pruned (finalized), today kept
  });
}
