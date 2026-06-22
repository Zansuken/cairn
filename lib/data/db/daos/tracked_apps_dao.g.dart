// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracked_apps_dao.dart';

// ignore_for_file: type=lint
mixin _$TrackedAppsDaoMixin on DatabaseAccessor<CairnDatabase> {
  $TrackedAppsTable get trackedApps => attachedDatabase.trackedApps;
  TrackedAppsDaoManager get managers => TrackedAppsDaoManager(this);
}

class TrackedAppsDaoManager {
  final _$TrackedAppsDaoMixin _db;
  TrackedAppsDaoManager(this._db);
  $$TrackedAppsTableTableManager get trackedApps =>
      $$TrackedAppsTableTableManager(_db.attachedDatabase, _db.trackedApps);
}
