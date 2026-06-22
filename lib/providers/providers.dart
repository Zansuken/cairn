import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../data/db/connection.dart';
import '../data/db/database.dart';
import '../data/interception_journal.dart';
import '../data/reconciliation_service.dart';
import '../data/repository/tracking_repository.dart';
import '../domain/daily_recap.dart';
import '../domain/day_window.dart';
import '../domain/history_window.dart';
import '../domain/model/day_record.dart';
import '../domain/model/day_state.dart';
import '../domain/model/tracked_app.dart';
import '../platform/notification_service.dart';
import '../platform/usage_service.dart';
import '../ui/app_detail/app_detail_state.dart';
import '../ui/home/home_state.dart';

// ── Foundations ─────────────────────────────────────────────────────────────
final databaseProvider = Provider<CairnDatabase>((ref) {
  final db = CairnDatabase();
  ref.onDispose(db.close);
  return db;
});

final usageServiceProvider = Provider<UsageService>((ref) => const UsageService());

final notificationServiceProvider =
    Provider<NotificationService>((ref) => const NotificationService());

final reconciliationServiceProvider = Provider<ReconciliationService>(
  (ref) => ReconciliationService(
    db: ref.watch(databaseProvider),
    gateway: ref.watch(usageServiceProvider),
    // Drain the native overlay's interception journal on each reconcile.
    journal: InterceptionJournal.lazy(interceptionJournalFile),
  ),
);

final trackingRepositoryProvider = Provider<TrackingRepository>(
  (ref) => TrackingRepository(
    db: ref.watch(databaseProvider),
    worker: ref.watch(usageServiceProvider),
    reconciliation: ref.watch(reconciliationServiceProvider),
  ),
);

// ── Reactive reads ──────────────────────────────────────────────────────────
final permissionStatusProvider =
    FutureProvider<bool>((ref) => ref.watch(usageServiceProvider).isUsageAccessGranted());

/// Whether Cairn is exempt from battery optimization. Refreshed on foreground
/// (RootGate) so the Settings status updates after the user grants it.
final batteryExemptProvider = FutureProvider<bool>(
  (ref) => ref.watch(usageServiceProvider).isIgnoringBatteryOptimizations());

/// Device manufacturer (lowercased), loaded once — used to show the OEM
/// "protected apps" hint only on phones that aggressively kill background work.
final deviceManufacturerProvider = FutureProvider<String>(
  (ref) => ref.watch(usageServiceProvider).deviceManufacturer());

/// The app's version name (e.g. "1.0.0"), so the Settings footer never goes
/// stale when the pubspec version is bumped.
final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return info.version;
});

final trackedAppsProvider =
    StreamProvider<List<TrackedApp>>((ref) => ref.watch(databaseProvider).trackedAppsDao.watchAll());

/// Launchable installed apps (with icons) for the picker.
final installedAppsProvider = FutureProvider<List<InstalledApp>>(
  (ref) => ref.watch(usageServiceProvider).installedApps(withIcons: true),
);

final settingsProvider =
    StreamProvider((ref) => ref.watch(databaseProvider).settingsDao.watch());

/// Live Home view-model. Rebuilds when the tracked-app set changes; invalidate
/// it after a reconcile or on resume to refresh the live "today" status.
final homeStateProvider = FutureProvider<HomeState>((ref) async {
  ref.watch(trackedAppsProvider); // refresh on add/remove
  final db = ref.watch(databaseProvider);
  final recon = ref.watch(reconciliationServiceProvider);
  final now = DateTime.now();

  final settings = await db.settingsDao.get();
  final resetHour = settings.dayResetHour;

  final apps = (await db.trackedAppsDao.getAll()).where((a) => !a.isFreed).toList();

  final rows = <HomeAppVm>[];
  var allCleanToday = apps.isNotEmpty;
  for (final app in apps) {
    final cache = await db.streakCacheDao.appState(app.packageId);
    final today = await recon.todayStatus(app.packageId, now: now, resetHour: resetHour);
    if (today != DayState.clean) allCleanToday = false;
    rows.add(HomeAppVm(
      packageId: app.packageId,
      name: app.displayName,
      monogram: _monogram(app.displayName),
      currentStreak: cache?.currentStreak ?? 0,
      today: today == DayState.clean ? TodayStatus.stillClean : TodayStatus.slippedToday,
    ));
  }
  rows.sort((a, b) => b.currentStreak.compareTo(a.currentStreak));

  final meta = await db.streakCacheDao.meta();
  final completed = meta.currentMetaStreak;
  final window = DayWindow.forNow(now, resetHour: resetHour);
  final rolloverHours =
      ((window.end.millisecondsSinceEpoch - now.millisecondsSinceEpoch) / 3600000).ceil();

  return HomeState(
    meta: HomeMeta(
      metaStreak: completed + (allCleanToday ? 1 : 0),
      dayNumber: completed + (allCleanToday ? 1 : 0),
      allCleanToday: allCleanToday,
      rolloverInHours: rolloverHours < 1 ? 1 : rolloverHours,
      bestRun: meta.bestMetaStreak,
      lifetimeClean: meta.lifetimePerfectDays,
    ),
    apps: rows,
  );
});

// ── App detail ───────────────────────────────────────────────────────────────
/// Finalized day records for one app, live. Drives the 30-day dot history.
final dayRecordsProvider = StreamProvider.family<List<DayRecord>, String>(
  (ref, packageId) => ref.watch(databaseProvider).dayRecordsDao.watchFor(packageId),
);

/// Live view-model for the App detail screen. Returns null if the app is no
/// longer tracked (e.g. removed while the screen was open) so the screen can pop.
final appDetailProvider = FutureProvider.family<AppDetailVm?, String>((ref, packageId) async {
  final db = ref.watch(databaseProvider);
  final recon = ref.watch(reconciliationServiceProvider);
  final apps = ref.watch(trackedAppsProvider).value ?? await db.trackedAppsDao.getAll();
  final records = ref.watch(dayRecordsProvider(packageId)).value ??
      await db.dayRecordsDao.historyFor(packageId);
  final now = DateTime.now();

  TrackedApp? app;
  for (final a in apps) {
    if (a.packageId == packageId) {
      app = a;
      break;
    }
  }
  if (app == null) return null;

  final settings = await db.settingsDao.get();
  final resetHour = settings.dayResetHour;
  final cache = await db.streakCacheDao.appState(packageId);

  DayState today = DayState.unverified;
  DayState? todayOverride;
  if (!app.isFreed) {
    today = await recon.todayStatus(packageId, now: now, resetHour: resetHour);
    todayOverride = today;
  }

  final history = lastNDaysStates(
    records: records,
    now: now,
    resetHour: resetHour,
    days: 30,
    todayOverride: todayOverride,
  );

  return AppDetailVm(
    packageId: packageId,
    name: app.displayName,
    monogram: _monogram(app.displayName),
    isFreed: app.isFreed,
    currentStreak: cache?.currentStreak ?? 0,
    bestStreak: cache?.bestStreak ?? 0,
    lifetimeClean: cache?.lifetimeCleanDays ?? 0,
    today: today,
    history: history,
    freedAt: app.freedAt,
  );
});

// ── Daily recap ──────────────────────────────────────────────────────────────
/// The morning recap (screen-prompts §15): how each active cairn fared
/// *yesterday* (the just-closed day), plus the lifetime + perfect-run strip.
final dailyRecapProvider = FutureProvider<DailyRecap>((ref) async {
  ref.watch(trackedAppsProvider); // refresh when the tracked set changes
  final db = ref.watch(databaseProvider);
  final now = DateTime.now();
  final settings = await db.settingsDao.get();
  final resetHour = settings.dayResetHour;

  final todayStart = DayWindow.startOfDay(now, resetHour: resetHour);
  final yesterdayStart = DateTime(todayStart.year, todayStart.month, todayStart.day - 1, todayStart.hour);

  final apps = (await db.trackedAppsDao.getAll()).where((a) => !a.isFreed).toList();
  final inputs = <RecapInput>[];
  for (final app in apps) {
    final record = await db.dayRecordsDao.recordFor(app.packageId, yesterdayStart.millisecondsSinceEpoch);
    final state = switch (record?.state) {
      DayState.clean => RecapState.clean,
      DayState.slipped => RecapState.slipped,
      _ => RecapState.unverified,
    };
    final cache = await db.streakCacheDao.appState(app.packageId);
    inputs.add(RecapInput(
      packageId: app.packageId,
      name: app.displayName,
      monogram: _monogram(app.displayName),
      state: state,
      currentStreak: cache?.currentStreak ?? 0,
    ));
  }

  final meta = await db.streakCacheDao.meta();
  return buildDailyRecap(
    apps: inputs,
    lifetimeClean: meta.lifetimePerfectDays,
    perfectRun: meta.currentMetaStreak,
  );
});

String _monogram(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return '?';
  return trimmed[0].toUpperCase();
}
