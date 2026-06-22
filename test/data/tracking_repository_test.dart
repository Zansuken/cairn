import 'dart:io';

import 'package:cairn/data/db/database.dart';
import 'package:cairn/data/interception_journal.dart';
import 'package:cairn/data/reconciliation_service.dart';
import 'package:cairn/data/repository/tracking_repository.dart';
import 'package:cairn/domain/model/tracked_app.dart';
import 'package:cairn/platform/usage_service.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records the snapshot the repository pushes to the native worker, so we can
/// assert a rename propagates the new label to the speed-bump overlay.
class _RecordingWorker implements WorkerController {
  Map<String, String> labels = {};
  List<String> packages = [];

  @override
  Future<void> updateWorkerConfig({
    required List<String> packages,
    required int resetHour,
    required String dbPath,
  }) async {
    this.packages = packages;
  }

  @override
  Future<void> saveSpeedBumpSnapshot(Map<String, int> streaks, Map<String, String> labels) async {
    this.labels = labels;
  }

  @override
  Future<void> scheduleDailyReconciliation() async {}

  @override
  Future<void> runReconciliationNow() async {}
}

class _NoopGateway implements UsageGateway {
  @override
  Future<bool> isUsageAccessGranted() async => true;
  @override
  Future<void> openUsageAccessSettings() async {}
  @override
  Future<Set<String>> openedPackages(List<String> packages, int s, int e) async => {};
  @override
  Future<List<int>> openTimestamps(String packageId, int s, int e) async => [];
  @override
  Future<List<InstalledApp>> installedApps({bool withIcons = false}) async => [];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // syncWorkerConfig resolves the DB path via path_provider; stub its channel so
  // the repository can run without a real Android plugin.
  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => Directory.systemTemp.path,
    );
  });

  late CairnDatabase db;
  late _RecordingWorker worker;
  late TrackingRepository repo;

  setUp(() {
    db = CairnDatabase.forTesting(NativeDatabase.memory());
    worker = _RecordingWorker();
    repo = TrackingRepository(
      db: db,
      worker: worker,
      reconciliation: ReconciliationService(
        db: db,
        gateway: _NoopGateway(),
        journal: InterceptionJournal(File('build/unused_journal.jsonl')),
      ),
    );
  });
  tearDown(() => db.close());

  test('renameApp persists the new name and repushes it to the worker label snapshot', () async {
    await db.trackedAppsDao.upsert(
      TrackedApp(packageId: 'com.x', displayName: 'X', addedAt: DateTime(2026, 1, 1)),
    );

    await repo.renameApp('com.x', 'Twitter');

    final loaded = await db.trackedAppsDao.find('com.x');
    expect(loaded!.displayName, 'Twitter');
    expect(worker.labels['com.x'], 'Twitter');
  });
}
