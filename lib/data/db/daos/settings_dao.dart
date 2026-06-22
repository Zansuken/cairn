import 'package:drift/drift.dart';

import '../database.dart';
import '../tables.dart';

part 'settings_dao.g.dart';

/// Reads/writes the singleton settings row (id = 0), seeded with defaults on
/// database creation (PRD §5).
@DriftAccessor(tables: [AppSettings])
class SettingsDao extends DatabaseAccessor<CairnDatabase> with _$SettingsDaoMixin {
  SettingsDao(super.db);

  Future<AppSettingsRow> get() =>
      (select(appSettings)..where((t) => t.id.equals(0))).getSingle();

  Stream<AppSettingsRow> watch() =>
      (select(appSettings)..where((t) => t.id.equals(0))).watchSingle();

  Future<void> save(AppSettingsCompanion changes) =>
      into(appSettings).insertOnConflictUpdate(changes.copyWith(id: const Value(0)));
}
