import 'package:cairn/data/db/database.dart';
import 'package:cairn/domain/model/day_record.dart';
import 'package:cairn/domain/model/day_state.dart';
import 'package:cairn/domain/model/tracked_app.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CairnDatabase db;

  setUp(() => db = CairnDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  group('singletons seeded on create', () {
    test('settings row exists with PRD defaults', () async {
      final s = await db.settingsDao.get();
      expect(s.dayResetHour, 4);
      expect(s.notificationsEnabled, true);
      expect(s.milestonesEnabled, true);
      expect(s.analyticsOptIn, false);
    });

    test('meta row exists at zero', () async {
      final m = await db.streakCacheDao.meta();
      expect(m.currentMetaStreak, 0);
      expect(m.bestMetaStreak, 0);
      expect(m.lifetimePerfectDays, 0);
    });
  });

  group('TrackedAppsDao', () {
    test('upsert then read round-trips through the domain model', () async {
      final app = TrackedApp(
        packageId: 'com.tiktok',
        displayName: 'TikTok',
        addedAt: DateTime(2026, 1, 1),
      );
      await db.trackedAppsDao.upsert(app);

      final loaded = await db.trackedAppsDao.find('com.tiktok');
      expect(loaded, isNotNull);
      expect(loaded!.displayName, 'TikTok');
      expect(loaded.status, AppStatus.active);
      expect(loaded.freedAt, isNull);
    });

    test('markFreed converts the app to the freed trophy', () async {
      await db.trackedAppsDao.upsert(
        TrackedApp(packageId: 'com.x', displayName: 'X', addedAt: DateTime(2026, 1, 1)),
      );
      await db.trackedAppsDao.markFreed('com.x', DateTime(2026, 2, 1));

      final loaded = await db.trackedAppsDao.find('com.x');
      expect(loaded!.status, AppStatus.freed);
      expect(loaded.isFreed, true);
      expect(loaded.freedAt, DateTime(2026, 2, 1));
    });

    test('rename changes the display name and leaves the rest untouched', () async {
      await db.trackedAppsDao.upsert(
        TrackedApp(packageId: 'com.x', displayName: 'X', addedAt: DateTime(2026, 1, 1)),
      );
      await db.trackedAppsDao.rename('com.x', 'Twitter');

      final loaded = await db.trackedAppsDao.find('com.x');
      expect(loaded!.displayName, 'Twitter');
      expect(loaded.status, AppStatus.active);
      expect(loaded.addedAt, DateTime(2026, 1, 1));
    });

    test('watchAll emits the current set', () async {
      final emissions = <int>[];
      final sub = db.trackedAppsDao.watchAll().listen((apps) => emissions.add(apps.length));
      await db.trackedAppsDao.upsert(
        TrackedApp(packageId: 'a', displayName: 'A', addedAt: DateTime(2026, 1, 1)),
      );
      await pumpEventQueue();
      await sub.cancel();
      expect(emissions.last, 1);
    });
  });

  group('DayRecordsDao', () {
    DayRecord rec(int d, DayState s) =>
        DayRecord(packageId: 'app', dayStart: DateTime(2026, 1, d, 4), state: s);

    test('upsert is idempotent on the composite key and the last write wins', () async {
      await db.dayRecordsDao.upsert(rec(1, DayState.clean), finalizedAt: DateTime(2026, 1, 1));
      await db.dayRecordsDao.upsert(rec(1, DayState.slipped), finalizedAt: DateTime(2026, 1, 1, 5));

      final history = await db.dayRecordsDao.historyFor('app');
      expect(history.length, 1);
      expect(history.single.state, DayState.slipped);
    });

    test('historyFor returns records ordered by day', () async {
      await db.dayRecordsDao.upsert(rec(3, DayState.clean), finalizedAt: DateTime(2026, 1, 3));
      await db.dayRecordsDao.upsert(rec(1, DayState.clean), finalizedAt: DateTime(2026, 1, 1));
      await db.dayRecordsDao.upsert(rec(2, DayState.unverified), finalizedAt: DateTime(2026, 1, 2));

      final history = await db.dayRecordsDao.historyFor('app');
      expect(history.map((r) => r.dayStart.day), [1, 2, 3]);
      expect(history[1].state, DayState.unverified);
    });
  });

  group('StreakCacheDao', () {
    test('upsert app state then read back', () async {
      await db.streakCacheDao.upsertAppState(const AppStreakStatesCompanion(
        packageId: Value('app'),
        currentStreak: Value(12),
        bestStreak: Value(28),
        lifetimeCleanDays: Value(132),
      ));
      final s = await db.streakCacheDao.appState('app');
      expect(s!.currentStreak, 12);
      expect(s.bestStreak, 28);
      expect(s.lifetimeCleanDays, 132);
    });

    test('upsertMeta keeps the singleton id and updates values', () async {
      await db.streakCacheDao.upsertMeta(const MetaStatesCompanion(
        currentMetaStreak: Value(7),
        bestMetaStreak: Value(10),
        lifetimePerfectDays: Value(40),
      ));
      final m = await db.streakCacheDao.meta();
      expect(m.id, 0);
      expect(m.currentMetaStreak, 7);
      expect(m.bestMetaStreak, 10);
      expect(m.lifetimePerfectDays, 40);
    });
  });

  group('SettingsDao', () {
    test('save updates the singleton without creating a second row', () async {
      await db.settingsDao.save(const AppSettingsCompanion(dayResetHour: Value(6)));
      final s = await db.settingsDao.get();
      expect(s.id, 0);
      expect(s.dayResetHour, 6);
      // unchanged fields keep their seeded defaults
      expect(s.notificationsEnabled, true);
    });
  });
}
