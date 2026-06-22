// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_records_dao.dart';

// ignore_for_file: type=lint
mixin _$DayRecordsDaoMixin on DatabaseAccessor<CairnDatabase> {
  $DayRecordsTable get dayRecords => attachedDatabase.dayRecords;
  DayRecordsDaoManager get managers => DayRecordsDaoManager(this);
}

class DayRecordsDaoManager {
  final _$DayRecordsDaoMixin _db;
  DayRecordsDaoManager(this._db);
  $$DayRecordsTableTableManager get dayRecords =>
      $$DayRecordsTableTableManager(_db.attachedDatabase, _db.dayRecords);
}
