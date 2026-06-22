import '../../domain/day_window.dart';
import '../../domain/model/tracked_app.dart';
import '../../domain/moment_detector.dart';
import '../../platform/usage_service.dart';
import '../db/connection.dart';
import '../db/database.dart';
import '../reconciliation_service.dart';

/// Command-side orchestration: add/remove apps, run the foreground reconcile,
/// and keep the native worker's config in sync. Queries for the UI are built in
/// the providers from the DAOs + [ReconciliationService].
class TrackingRepository {
  TrackingRepository({
    required this.db,
    required this.worker,
    required this.reconciliation,
  });

  final CairnDatabase db;
  final WorkerController worker;
  final ReconciliationService reconciliation;

  Future<void> addApp({
    required String packageId,
    required String displayName,
    required DateTime now,
  }) async {
    await db.trackedAppsDao.upsert(
      TrackedApp(packageId: packageId, displayName: displayName, addedAt: now),
    );
    await syncWorkerConfig();
  }

  Future<void> removeApp(String packageId) async {
    await db.trackedAppsDao.remove(packageId);
    await db.streakCacheDao.removeAppState(packageId);
    await syncWorkerConfig();
  }

  Future<void> recompute({required DateTime now}) => reconciliation.reconcile(now: now);

  /// Recompute, then report the "moments" the recompute revealed (slip / cleared
  /// milestone / Freed) by diffing the per-app cache before and after. The before
  /// vs after comparison makes this naturally once-only (PRD §7).
  Future<List<MomentEvent>> recomputeAndDetectMoments({required DateTime now}) async {
    final before = await _snapshotApps(now);
    await reconciliation.reconcile(now: now);
    final after = await _snapshotApps(now);
    return detectMoments(before: before, after: after);
  }

  Future<Map<String, AppSnapshot>> _snapshotApps(DateTime now) async {
    final settings = await db.settingsDao.get();
    final todayStart = DayWindow.startOfDay(now, resetHour: settings.dayResetHour);
    final yesterdayStart =
        DateTime(todayStart.year, todayStart.month, todayStart.day - 1, todayStart.hour, todayStart.minute);

    final apps = await db.trackedAppsDao.getAll();
    final out = <String, AppSnapshot>{};
    for (final a in apps) {
      final c = await db.streakCacheDao.appState(a.packageId);
      // The just-closed day's verdict lets the detector tell a real open apart
      // from an unverified break before claiming a slip.
      final yesterday =
          await db.dayRecordsDao.recordFor(a.packageId, yesterdayStart.millisecondsSinceEpoch);
      out[a.packageId] = AppSnapshot(
        packageId: a.packageId,
        name: a.displayName,
        currentStreak: c?.currentStreak ?? 0,
        bestStreak: c?.bestStreak ?? 0,
        lifetimeClean: c?.lifetimeCleanDays ?? 0,
        isFreed: a.isFreed,
        lastDayState: yesterday?.state,
      );
    }
    return out;
  }

  /// Push the active set + reset hour + DB path to the native worker and ensure
  /// the daily job is scheduled.
  Future<void> syncWorkerConfig() async {
    final apps = await db.trackedAppsDao.getAll();
    final active = apps.where((a) => !a.isFreed).toList();
    final settings = await db.settingsDao.get();
    await worker.updateWorkerConfig(
      packages: active.map((a) => a.packageId).toList(),
      resetHour: settings.dayResetHour,
      dbPath: await databaseFilePath(),
    );
    // Refresh the speed-bump overlay snapshot (current streak + display name per
    // active app) so it can render its copy without touching SQLite.
    final streaks = <String, int>{};
    final labels = <String, String>{};
    for (final a in active) {
      final cache = await db.streakCacheDao.appState(a.packageId);
      streaks[a.packageId] = cache?.currentStreak ?? 0;
      labels[a.packageId] = a.displayName;
    }
    await worker.saveSpeedBumpSnapshot(streaks, labels);
    await worker.scheduleDailyReconciliation();
  }
}
