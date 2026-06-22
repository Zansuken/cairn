import 'package:drift/drift.dart';

import '../../../domain/model/interception_event.dart';
import '../database.dart';
import '../mappers.dart';
import '../tables.dart';

part 'interception_dao.g.dart';

/// Reads/writes the speed-bump interception log. Rows arrive only via the Dart
/// journal drain (the native overlay appends to a JSONL file; Dart drains it into
/// here), so Drift stays the single SQLite writer.
@DriftAccessor(tables: [InterceptionEvents])
class InterceptionDao extends DatabaseAccessor<CairnDatabase> with _$InterceptionDaoMixin {
  InterceptionDao(super.db);

  /// Idempotent upsert of drained rows (PK = packageId + foregroundAtMillis), so
  /// re-draining a not-yet-truncated line never double-counts.
  Future<void> upsertAll(List<InterceptionEventsCompanion> rows) =>
      batch((b) => b.insertAllOnConflictUpdate(interceptionEvents, rows));

  /// Interceptions for one app on one reset-hour day, oldest first.
  Future<List<InterceptionEvent>> interceptionsForDay(String packageId, int dayStartMillis) async {
    final rows = await (select(interceptionEvents)
          ..where((t) => t.packageId.equals(packageId) & t.dayStartMillis.equals(dayStartMillis))
          ..orderBy([(t) => OrderingTerm(expression: t.foregroundAtMillis)]))
        .get();
    return rows.map((r) => r.toDomain()).toList();
  }

  /// Distinct reset-hour day starts that have interception rows for one app —
  /// drives the reconcile's extended finalize loop (finalize any day with bump
  /// data, regardless of age).
  Future<List<int>> daysWithInterceptions(String packageId) async {
    final q = selectOnly(interceptionEvents, distinct: true)
      ..addColumns([interceptionEvents.dayStartMillis])
      ..where(interceptionEvents.packageId.equals(packageId));
    final rows = await q.get();
    return rows.map((r) => r.read(interceptionEvents.dayStartMillis)!).toList();
  }

  /// Drop rows for days strictly older than [dayStartMillis] (already finalized).
  Future<void> pruneBefore(int dayStartMillis) =>
      (delete(interceptionEvents)..where((t) => t.dayStartMillis.isSmallerThanValue(dayStartMillis))).go();
}
