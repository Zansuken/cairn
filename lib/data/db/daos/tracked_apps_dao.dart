import 'package:drift/drift.dart';

import '../../../domain/model/tracked_app.dart';
import '../database.dart';
import '../mappers.dart';
import '../tables.dart';

part 'tracked_apps_dao.g.dart';

@DriftAccessor(tables: [TrackedApps])
class TrackedAppsDao extends DatabaseAccessor<CairnDatabase> with _$TrackedAppsDaoMixin {
  TrackedAppsDao(super.db);

  Stream<List<TrackedApp>> watchAll() =>
      select(trackedApps).watch().map((rows) => rows.map((r) => r.toDomain()).toList());

  Future<List<TrackedApp>> getAll() async =>
      (await select(trackedApps).get()).map((r) => r.toDomain()).toList();

  Future<TrackedApp?> find(String packageId) async {
    final row = await (select(trackedApps)..where((t) => t.packageId.equals(packageId)))
        .getSingleOrNull();
    return row?.toDomain();
  }

  Future<void> upsert(TrackedApp app) => into(trackedApps).insertOnConflictUpdate(app.toCompanion());

  /// Rename only — the user's chosen display name. Status, addedAt, and the
  /// streak cache (keyed by packageId) are all left untouched.
  Future<void> rename(String packageId, String displayName) =>
      (update(trackedApps)..where((t) => t.packageId.equals(packageId)))
          .write(TrackedAppsCompanion(displayName: Value(displayName)));

  /// Convert to the permanent "Freed" trophy on uninstall (PRD §2).
  Future<void> markFreed(String packageId, DateTime freedAt) =>
      (update(trackedApps)..where((t) => t.packageId.equals(packageId))).write(
        TrackedAppsCompanion(status: const Value(AppStatus.freed), freedAt: Value(freedAt)),
      );

  Future<void> remove(String packageId) =>
      (delete(trackedApps)..where((t) => t.packageId.equals(packageId))).go();
}
