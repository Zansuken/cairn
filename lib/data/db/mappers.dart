import 'package:drift/drift.dart';

import '../../domain/model/day_record.dart';
import '../../domain/model/interception_event.dart';
import '../../domain/model/tracked_app.dart';
import 'database.dart';

/// Mapping between Drift row classes (…Row) and the pure-Dart domain models.

extension TrackedAppRowMapper on TrackedAppRow {
  TrackedApp toDomain() => TrackedApp(
        packageId: packageId,
        displayName: displayName,
        addedAt: addedAt,
        status: status,
        freedAt: freedAt,
      );
}

extension TrackedAppMapper on TrackedApp {
  TrackedAppsCompanion toCompanion() => TrackedAppsCompanion(
        packageId: Value(packageId),
        displayName: Value(displayName),
        addedAt: Value(addedAt),
        status: Value(status),
        freedAt: Value(freedAt),
      );
}

extension DayRecordRowMapper on DayRecordRow {
  DayRecord toDomain() => DayRecord(
        packageId: packageId,
        dayStart: DateTime.fromMillisecondsSinceEpoch(dayStartMillis),
        state: state,
      );
}

extension DayRecordMapper on DayRecord {
  DayRecordsCompanion toCompanion({required DateTime finalizedAt}) => DayRecordsCompanion(
        packageId: Value(packageId),
        dayStartMillis: Value(dayStart.millisecondsSinceEpoch),
        state: Value(state),
        finalizedAt: Value(finalizedAt),
      );
}

extension InterceptionEventRowMapper on InterceptionEventRow {
  InterceptionEvent toDomain() => InterceptionEvent(
        packageId: packageId,
        foregroundAt: DateTime.fromMillisecondsSinceEpoch(foregroundAtMillis),
        outcome: outcome,
        recordedAt: DateTime.fromMillisecondsSinceEpoch(recordedAtMillis),
      );
}

extension InterceptionEventMapper on InterceptionEvent {
  // [dayStartMillis] is computed in Dart at drain time (never trusted from native).
  InterceptionEventsCompanion toCompanion({required int dayStartMillis}) => InterceptionEventsCompanion(
        packageId: Value(packageId),
        foregroundAtMillis: Value(foregroundAt.millisecondsSinceEpoch),
        dayStartMillis: Value(dayStartMillis),
        outcome: Value(outcome),
        recordedAtMillis: Value(recordedAt.millisecondsSinceEpoch),
      );
}
