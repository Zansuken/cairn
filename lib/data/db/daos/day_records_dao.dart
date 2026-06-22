import 'package:drift/drift.dart';

import '../../../domain/model/day_record.dart';
import '../database.dart';
import '../mappers.dart';
import '../tables.dart';

part 'day_records_dao.g.dart';

@DriftAccessor(tables: [DayRecords])
class DayRecordsDao extends DatabaseAccessor<CairnDatabase> with _$DayRecordsDaoMixin {
  DayRecordsDao(super.db);

  /// Persist a finalized day (idempotent — the worker and a foreground recompute
  /// can both write the same window; PRD §4.4).
  Future<void> upsert(DayRecord record, {required DateTime finalizedAt}) =>
      into(dayRecords).insertOnConflictUpdate(record.toCompanion(finalizedAt: finalizedAt));

  Future<List<DayRecord>> historyFor(String packageId) async {
    final rows = await (select(dayRecords)
          ..where((t) => t.packageId.equals(packageId))
          ..orderBy([(t) => OrderingTerm(expression: t.dayStartMillis)]))
        .get();
    return rows.map((r) => r.toDomain()).toList();
  }

  Stream<List<DayRecord>> watchFor(String packageId) =>
      (select(dayRecords)
            ..where((t) => t.packageId.equals(packageId))
            ..orderBy([(t) => OrderingTerm(expression: t.dayStartMillis)]))
          .watch()
          .map((rows) => rows.map((r) => r.toDomain()).toList());

  Future<DayRecord?> recordFor(String packageId, int dayStartMillis) async {
    final row = await (select(dayRecords)
          ..where((t) => t.packageId.equals(packageId) & t.dayStartMillis.equals(dayStartMillis)))
        .getSingleOrNull();
    return row?.toDomain();
  }

  /// All records, for building the meta-streak across apps.
  Future<List<DayRecord>> allRecords() async =>
      (await select(dayRecords).get()).map((r) => r.toDomain()).toList();

  Stream<List<DayRecord>> watchAll() =>
      select(dayRecords).watch().map((rows) => rows.map((r) => r.toDomain()).toList());
}
