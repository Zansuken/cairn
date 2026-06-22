import 'package:drift/drift.dart';

import '../../domain/model/day_state.dart';
import '../../domain/model/interception_outcome.dart';
import '../../domain/model/tracked_app.dart';
import 'connection.dart';
import 'daos/day_records_dao.dart';
import 'daos/interception_dao.dart';
import 'daos/settings_dao.dart';
import 'daos/streak_cache_dao.dart';
import 'daos/tracked_apps_dao.dart';
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [TrackedApps, DayRecords, AppStreakStates, MetaStates, AppSettings, InterceptionEvents],
  daos: [TrackedAppsDao, DayRecordsDao, StreakCacheDao, SettingsDao, InterceptionDao],
)
class CairnDatabase extends _$CairnDatabase {
  CairnDatabase([QueryExecutor? executor]) : super(executor ?? openConnection());

  /// In-memory database for unit tests.
  CairnDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          // Seed the singleton rows so settings/meta are always readable.
          await into(appSettings).insert(const AppSettingsCompanion(id: Value(0)));
          await into(metaStates).insert(const MetaStatesCompanion(id: Value(0)));
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(appSettings, appSettings.onboardingComplete);
          }
          if (from < 3) {
            await m.createTable(interceptionEvents);
            await m.addColumn(appSettings, appSettings.speedBumpEnabled);
            await m.addColumn(appSettings, appSettings.speedBumpEnabledAtMillis);
          }
        },
      );
}
