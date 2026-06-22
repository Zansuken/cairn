import 'package:drift/drift.dart';

import '../../domain/model/day_state.dart';
import '../../domain/model/interception_outcome.dart';
import '../../domain/model/tracked_app.dart';

/// Drift schema for Cairn (PRD §5). Generated row classes are suffixed `Row` to
/// avoid clashing with the pure-Dart domain models (TrackedApp, DayRecord).

@DataClassName('TrackedAppRow')
class TrackedApps extends Table {
  TextColumn get packageId => text()();
  TextColumn get displayName => text()();
  DateTimeColumn get addedAt => dateTime()();
  IntColumn get status => intEnum<AppStatus>()();
  DateTimeColumn get freedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {packageId};
}

@DataClassName('DayRecordRow')
class DayRecords extends Table {
  TextColumn get packageId => text()();

  /// Epoch millis of the local reset-hour boundary that opens the day window.
  IntColumn get dayStartMillis => integer()();
  IntColumn get state => intEnum<DayState>()();
  DateTimeColumn get finalizedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {packageId, dayStartMillis};
}

/// Derived but cached; recomputable from [DayRecords] (PRD §5).
@DataClassName('AppStreakStateRow')
class AppStreakStates extends Table {
  TextColumn get packageId => text()();
  IntColumn get currentStreak => integer().withDefault(const Constant(0))();
  IntColumn get bestStreak => integer().withDefault(const Constant(0))();
  IntColumn get lifetimeCleanDays => integer().withDefault(const Constant(0))();
  IntColumn get lastFinalizedDayMillis => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {packageId};
}

/// Singleton row (id = 0).
@DataClassName('MetaStateRow')
class MetaStates extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();
  IntColumn get currentMetaStreak => integer().withDefault(const Constant(0))();
  IntColumn get bestMetaStreak => integer().withDefault(const Constant(0))();
  IntColumn get lifetimePerfectDays => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Singleton row (id = 0). Default daily summary at 09:00 (540 minutes).
@DataClassName('AppSettingsRow')
class AppSettings extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();
  IntColumn get dayResetHour => integer().withDefault(const Constant(4))();
  BoolColumn get notificationsEnabled => boolean().withDefault(const Constant(true))();
  IntColumn get dailySummaryMinutes => integer().withDefault(const Constant(540))();
  BoolColumn get milestonesEnabled => boolean().withDefault(const Constant(true))();
  BoolColumn get analyticsOptIn => boolean().withDefault(const Constant(false))();

  /// True once the first-run flow (welcome → permission → pick → all set) is done.
  BoolColumn get onboardingComplete => boolean().withDefault(const Constant(false))();

  /// True when the (post-v1) intervention speed bump is on. Default off: it is an
  /// explicit opt-in that also needs the overlay permission.
  BoolColumn get speedBumpEnabled => boolean().withDefault(const Constant(false))();

  /// Epoch millis of the first-ever speed-bump enable, set once and never cleared.
  /// Days whose window ends before this stay on the legacy verdict path; days at or
  /// after it use the interception-aware path. Null until first enabled.
  IntColumn get speedBumpEnabledAtMillis => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// One speed-bump interception for a tracked app (PRD roadmap: intervention speed
/// bump). The native overlay drains its append-only journal into this table via
/// Dart, so Drift stays the only SQLite writer. [foregroundAtMillis] is the OS
/// MOVE_TO_FOREGROUND event time (the match key against the usage log, kept in
/// millis for precision); [dayStartMillis] is the reset-hour window start computed
/// in Dart at drain time (never trusted from native).
@DataClassName('InterceptionEventRow')
class InterceptionEvents extends Table {
  TextColumn get packageId => text()();
  IntColumn get foregroundAtMillis => integer()();
  IntColumn get dayStartMillis => integer()();
  IntColumn get outcome => intEnum<InterceptionOutcome>()();
  IntColumn get recordedAtMillis => integer()();

  @override
  Set<Column<Object>> get primaryKey => {packageId, foregroundAtMillis};
}
