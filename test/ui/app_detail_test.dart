import 'dart:io';

import 'package:cairn/core/theme/cairn_theme.dart';
import 'package:cairn/data/db/database.dart';
import 'package:cairn/data/interception_journal.dart';
import 'package:cairn/data/reconciliation_service.dart';
import 'package:cairn/data/repository/tracking_repository.dart';
import 'package:cairn/domain/model/day_state.dart';
import 'package:cairn/platform/sharer.dart';
import 'package:cairn/platform/usage_service.dart';
import 'package:cairn/providers/providers.dart';
import 'package:cairn/ui/app_detail/app_detail_screen.dart';
import 'package:cairn/ui/app_detail/app_detail_state.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records renameApp calls without touching the native worker or path_provider.
class _RecordingRepo extends TrackingRepository {
  _RecordingRepo(CairnDatabase db)
      : super(
          db: db,
          worker: _NoopWorker(),
          reconciliation: ReconciliationService(
            db: db,
            gateway: _NoopGateway(),
            journal: InterceptionJournal(File('build/unused_journal.jsonl')),
          ),
        );

  final List<(String, String)> renamed = [];

  @override
  Future<void> renameApp(String packageId, String displayName) async {
    renamed.add((packageId, displayName));
  }
}

class _NoopWorker implements WorkerController {
  @override
  Future<void> updateWorkerConfig({required packages, required resetHour, required dbPath}) async {}
  @override
  Future<void> saveSpeedBumpSnapshot(Map<String, int> s, Map<String, String> l) async {}
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
  Future<Set<String>> openedPackages(List<String> p, int s, int e) async => {};
  @override
  Future<List<int>> openTimestamps(String p, int s, int e) async => [];
  @override
  Future<List<InstalledApp>> installedApps({bool withIcons = false}) async => [];
}

class _FakeSharer implements Sharer {
  final shared = <String>[];

  @override
  Future<void> share(String text) async => shared.add(text);
}

void main() {
  Widget host(AppDetailVm vm, {TrackingRepository? repo, Sharer? sharer}) => ProviderScope(
        overrides: [
          appDetailProvider(vm.packageId).overrideWith((ref) => vm),
          if (repo != null) trackingRepositoryProvider.overrideWithValue(repo),
          if (sharer != null) sharerProvider.overrideWithValue(sharer),
        ],
        child: MaterialApp(
          theme: CairnTheme.dark(),
          home: AppDetailScreen(packageId: vm.packageId),
        ),
      );

  void usePhoneSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  AppDetailVm active() => AppDetailVm(
        packageId: 'com.tiktok',
        name: 'TikTok',
        monogram: 'T',
        isFreed: false,
        currentStreak: 19,
        bestStreak: 31,
        lifetimeClean: 88,
        today: DayState.clean,
        history: List<DayState>.filled(30, DayState.clean),
      );

  testWidgets('active layout shows the current run and the 30-day grid', (tester) async {
    usePhoneSurface(tester);
    await tester.pumpWidget(host(active()));
    await tester.pump();

    expect(find.text('CURRENT RUN'), findsOneWidget);
    expect(find.text('19'), findsOneWidget);
    expect(find.text('Still clean today'), findsOneWidget);
    expect(find.text('LAST 30 DAYS'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Stop tracking TikTok'), 240,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('Stop tracking TikTok'), findsOneWidget);
  });

  testWidgets('freed layout shows the summit trophy', (tester) async {
    final vm = AppDetailVm(
      packageId: 'com.tiktok',
      name: 'TikTok',
      monogram: 'T',
      isFreed: true,
      currentStreak: 63,
      bestStreak: 63,
      lifetimeClean: 121,
      today: DayState.unverified,
      history: const [],
      freedAt: DateTime(2026, 4, 2),
    );
    usePhoneSurface(tester);
    await tester.pumpWidget(host(vm));
    await tester.pump();

    expect(find.text("You're free."), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Share your summit'), 240,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('Freed on Apr 2, 2026'), findsOneWidget);
    expect(find.text('Share your summit'), findsOneWidget);
  });

  testWidgets('Rename opens a prefilled dialog and saves the new name', (tester) async {
    usePhoneSurface(tester);
    final db = CairnDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = _RecordingRepo(db);

    await tester.pumpWidget(host(active(), repo: repo));
    await tester.pump();

    // Scroll past 'Rename' to the last item so the button is fully in view (not
    // clipped at the bottom edge, which would make the tap miss).
    await tester.scrollUntilVisible(find.text('Stop tracking TikTok'), 240,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Rename'));
    await tester.pumpAndSettle();

    // The dialog opens prefilled with the current name.
    expect(
      find.descendant(of: find.byType(AlertDialog), matching: find.text('TikTok')),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextField), 'Twitter');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(repo.renamed, [('com.tiktok', 'Twitter')]);
  });

  testWidgets('sharing the summit hands a recap to the share sheet', (tester) async {
    usePhoneSurface(tester);
    final sharer = _FakeSharer();
    final vm = AppDetailVm(
      packageId: 'com.tiktok',
      name: 'TikTok',
      monogram: 'T',
      isFreed: true,
      currentStreak: 63,
      bestStreak: 63,
      lifetimeClean: 121,
      today: DayState.unverified,
      history: const [],
      freedAt: DateTime(2026, 4, 2),
    );

    await tester.pumpWidget(host(vm, sharer: sharer));
    await tester.pump();

    await tester.scrollUntilVisible(find.text('Share your summit'), 240,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Share your summit'));
    await tester.pump();

    expect(sharer.shared, hasLength(1));
    expect(sharer.shared.single, contains('TikTok'));
    expect(sharer.shared.single, contains('Cairn'));
    expect(sharer.shared.single, contains('121'));
    expect(sharer.shared.single, contains('63'));
  });
}
