// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streak_cache_dao.dart';

// ignore_for_file: type=lint
mixin _$StreakCacheDaoMixin on DatabaseAccessor<CairnDatabase> {
  $AppStreakStatesTable get appStreakStates => attachedDatabase.appStreakStates;
  $MetaStatesTable get metaStates => attachedDatabase.metaStates;
  StreakCacheDaoManager get managers => StreakCacheDaoManager(this);
}

class StreakCacheDaoManager {
  final _$StreakCacheDaoMixin _db;
  StreakCacheDaoManager(this._db);
  $$AppStreakStatesTableTableManager get appStreakStates =>
      $$AppStreakStatesTableTableManager(
        _db.attachedDatabase,
        _db.appStreakStates,
      );
  $$MetaStatesTableTableManager get metaStates =>
      $$MetaStatesTableTableManager(_db.attachedDatabase, _db.metaStates);
}
