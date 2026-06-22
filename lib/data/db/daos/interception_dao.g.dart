// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interception_dao.dart';

// ignore_for_file: type=lint
mixin _$InterceptionDaoMixin on DatabaseAccessor<CairnDatabase> {
  $InterceptionEventsTable get interceptionEvents =>
      attachedDatabase.interceptionEvents;
  InterceptionDaoManager get managers => InterceptionDaoManager(this);
}

class InterceptionDaoManager {
  final _$InterceptionDaoMixin _db;
  InterceptionDaoManager(this._db);
  $$InterceptionEventsTableTableManager get interceptionEvents =>
      $$InterceptionEventsTableTableManager(
        _db.attachedDatabase,
        _db.interceptionEvents,
      );
}
