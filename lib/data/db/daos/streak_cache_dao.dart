import 'package:drift/drift.dart';

import '../database.dart';
import '../tables.dart';

part 'streak_cache_dao.g.dart';

/// Reads/writes the cached streak numbers (PRD §5). The cache is authoritative
/// for display and always recomputable from [DayRecords].
@DriftAccessor(tables: [AppStreakStates, MetaStates])
class StreakCacheDao extends DatabaseAccessor<CairnDatabase> with _$StreakCacheDaoMixin {
  StreakCacheDao(super.db);

  // ── Per-app ──────────────────────────────────────────────────────────────
  Future<void> upsertAppState(AppStreakStatesCompanion state) =>
      into(appStreakStates).insertOnConflictUpdate(state);

  Future<AppStreakStateRow?> appState(String packageId) =>
      (select(appStreakStates)..where((t) => t.packageId.equals(packageId))).getSingleOrNull();

  Stream<AppStreakStateRow?> watchAppState(String packageId) =>
      (select(appStreakStates)..where((t) => t.packageId.equals(packageId))).watchSingleOrNull();

  Future<void> removeAppState(String packageId) =>
      (delete(appStreakStates)..where((t) => t.packageId.equals(packageId))).go();

  // ── Meta (singleton id = 0) ──────────────────────────────────────────────
  Future<MetaStateRow> meta() =>
      (select(metaStates)..where((t) => t.id.equals(0))).getSingle();

  Stream<MetaStateRow> watchMeta() =>
      (select(metaStates)..where((t) => t.id.equals(0))).watchSingle();

  Future<void> upsertMeta(MetaStatesCompanion meta) =>
      into(metaStates).insertOnConflictUpdate(meta.copyWith(id: const Value(0)));
}
