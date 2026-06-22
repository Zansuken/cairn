import 'package:drift/drift.dart';

import '../domain/day_history.dart';
import '../domain/day_window.dart';
import '../domain/interception_reconciler.dart';
import '../domain/model/day_record.dart';
import '../domain/model/day_state.dart';
import '../domain/model/tracked_app.dart';
import '../domain/streak_calculator.dart';
import '../domain/streak_math.dart';
import '../platform/usage_service.dart';
import 'db/database.dart';
import 'interception_journal.dart';

/// The "recompute on foreground" reconciliation (PRD §4.3/§4.4): finalize the
/// just-closed days from the OS usage log, materialise older gaps as unverified,
/// and refresh the cached streak numbers. Pure orchestration over the platform
/// gateway, the domain calculators and Drift — unit-tested with a fake gateway.
class ReconciliationService {
  ReconciliationService({
    required this.db,
    required this.gateway,
    this.retentionDays = 2,
    this.journal,
  });

  final CairnDatabase db;
  final UsageGateway gateway;

  /// The speed-bump interception journal (native overlay → JSONL). Drained into
  /// Drift at the start of each reconcile. Null when the feature is not wired in
  /// (e.g. unit tests that seed the interception table directly).
  final InterceptionJournal? journal;

  /// How many completed days back we trust the OS event log enough to query a
  /// real verdict. Older missing days become `unverified` (PRD §4.5).
  final int retentionDays;

  Future<void> reconcile({required DateTime now}) async {
    final settings = await db.settingsDao.get();
    final resetHour = settings.dayResetHour;
    final speedBumpEnabled = settings.speedBumpEnabled;
    final speedBumpEnabledAt = settings.speedBumpEnabledAtMillis == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(settings.speedBumpEnabledAtMillis!);

    // Pull the native overlay's append-only journal into Drift first, so this
    // reconcile sees the latest interception verdicts (Drift stays the only writer).
    if (journal != null) await journal!.drainInto(db.interceptionDao, resetHour: resetHour);

    await _markUninstalled(now);

    final apps = await db.trackedAppsDao.getAll();
    for (final app in apps.where((a) => !a.isFreed)) {
      await _reconcileApp(
        app,
        now: now,
        resetHour: resetHour,
        speedBumpEnabled: speedBumpEnabled,
        speedBumpEnabledAt: speedBumpEnabledAt,
      );
    }
    await _reconcileMeta(now: now, resetHour: resetHour);

    // Interception rows for completed days are now baked into day_records; drop
    // them, keeping today's (still accumulating, finalized on the next day).
    final todayStart = DayWindow.startOfDay(now, resetHour: resetHour);
    await db.interceptionDao.pruneBefore(todayStart.millisecondsSinceEpoch);
  }

  /// Live status of the in-progress day for one app ("still clean" vs "opened").
  Future<DayState> todayStatus(String packageId, {required DateTime now, required int resetHour}) async {
    final w = DayWindow.forNow(now, resetHour: resetHour);
    final opened = await gateway.openedPackages([packageId], w.startMillis, now.millisecondsSinceEpoch);
    return opened.contains(packageId) ? DayState.slipped : DayState.clean;
  }

  // ── internals ──────────────────────────────────────────────────────────

  Future<void> _markUninstalled(DateTime now) async {
    final installed = (await gateway.installedApps()).map((a) => a.packageId).toSet();
    if (installed.isEmpty) return; // never mass-free on a failed/empty query
    for (final app in await db.trackedAppsDao.getAll()) {
      if (!app.isFreed && !installed.contains(app.packageId)) {
        await db.trackedAppsDao.markFreed(app.packageId, now);
      }
    }
  }

  Future<void> _reconcileApp(
    TrackedApp app, {
    required DateTime now,
    required int resetHour,
    required bool speedBumpEnabled,
    DateTime? speedBumpEnabledAt,
  }) async {
    final todayStart = DayWindow.startOfDay(now, resetHour: resetHour);
    final yesterdayStart = _prevDay(todayStart);
    final addedStart = DayWindow.startOfDay(app.addedAt, resetHour: resetHour);

    // Days to finalize: the last `retentionDays` completed days, plus every day
    // that carries speed-bump interception rows — so a resisted/allowed verdict is
    // honoured even if its day is older than the retention window.
    final days = <int, DateTime>{};
    var day = yesterdayStart;
    for (var i = 0; i < retentionDays; i++) {
      if (_isBeforeDay(day, addedStart)) break;
      days[day.millisecondsSinceEpoch] = day;
      day = _prevDay(day);
    }
    for (final ms in await db.interceptionDao.daysWithInterceptions(app.packageId)) {
      final d = DateTime.fromMillisecondsSinceEpoch(ms);
      if (!d.isAfter(yesterdayStart) && !_isBeforeDay(d, addedStart)) days[ms] = d;
    }

    for (final entry in days.entries) {
      final d = entry.value;
      final w = DayWindow.fromStart(d);
      final interceptions = await db.interceptionDao.interceptionsForDay(app.packageId, entry.key);
      final DayState state;
      if (interceptions.isNotEmpty) {
        final osOpens = await gateway.openTimestamps(app.packageId, w.startMillis, w.endMillis);
        state = InterceptionReconciler.classifyDay(osOpens: osOpens, interceptions: interceptions);
      } else if (speedBumpEnabled && speedBumpEnabledAt != null && w.end.isAfter(speedBumpEnabledAt)) {
        // Feature on for this day but no interception: an open we did not catch
        // cannot be vouched for, so it is unverified (never a silent slip).
        final osOpens = await gateway.openTimestamps(app.packageId, w.startMillis, w.endMillis);
        state = InterceptionReconciler.classifyDay(osOpens: osOpens, interceptions: const []);
      } else {
        // Legacy retroactive verdict: any open means slipped.
        final opened = await gateway.openedPackages([app.packageId], w.startMillis, w.endMillis);
        state = opened.contains(app.packageId) ? DayState.slipped : DayState.clean;
      }
      await db.dayRecordsDao.upsert(
        DayRecord(packageId: app.packageId, dayStart: d, state: state),
        finalizedAt: now,
      );
    }

    // Materialise older missing days as unverified, then recompute the cache.
    final history = await db.dayRecordsDao.historyFor(app.packageId);
    final existing = {for (final r in history) r.dayStart};
    final filled = DayHistory.fillUnverifiedGaps(
      history,
      packageId: app.packageId,
      throughDay: yesterdayStart,
      resetHour: resetHour,
    );
    for (final r in filled) {
      if (!existing.contains(r.dayStart)) {
        await db.dayRecordsDao.upsert(r, finalizedAt: now);
      }
    }

    final stats = StreakCalculator.appStats(filled);
    final cached = await db.streakCacheDao.appState(app.packageId);
    final reconciled = cached == null
        ? stats
        : stats.reconciledWith(StreakStats(
            current: cached.currentStreak,
            best: cached.bestStreak,
            lifetime: cached.lifetimeCleanDays,
            lastDate: null,
          ));
    await db.streakCacheDao.upsertAppState(AppStreakStatesCompanion(
      packageId: Value(app.packageId),
      currentStreak: Value(reconciled.current),
      bestStreak: Value(reconciled.best),
      lifetimeCleanDays: Value(reconciled.lifetime),
      lastFinalizedDayMillis: Value(reconciled.lastDate?.millisecondsSinceEpoch),
    ));
  }

  Future<void> _reconcileMeta({required DateTime now, required int resetHour}) async {
    final apps = await db.trackedAppsDao.getAll();
    if (apps.isEmpty) return;

    final inputs = <MetaAppInput>[];
    for (final app in apps) {
      inputs.add(MetaAppInput(
        history: await db.dayRecordsDao.historyFor(app.packageId),
        activeFrom: DayWindow.startOfDay(app.addedAt, resetHour: resetHour),
        activeUntil: app.isFreed && app.freedAt != null
            ? DayWindow.startOfDay(app.freedAt!, resetHour: resetHour)
            : null,
      ));
    }

    final stats = StreakCalculator.metaStats(inputs);
    final cached = await db.streakCacheDao.meta();
    final reconciled = stats.reconciledWith(StreakStats(
      current: cached.currentMetaStreak,
      best: cached.bestMetaStreak,
      lifetime: cached.lifetimePerfectDays,
      lastDate: null,
    ));
    await db.streakCacheDao.upsertMeta(MetaStatesCompanion(
      currentMetaStreak: Value(reconciled.current),
      bestMetaStreak: Value(reconciled.best),
      lifetimePerfectDays: Value(reconciled.lifetime),
    ));
  }

  DateTime _prevDay(DateTime d) => DateTime(d.year, d.month, d.day - 1, d.hour, d.minute);

  bool _isBeforeDay(DateTime a, DateTime b) =>
      DateTime(a.year, a.month, a.day).isBefore(DateTime(b.year, b.month, b.day));
}
