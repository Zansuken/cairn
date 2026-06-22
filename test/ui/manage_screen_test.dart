import 'package:cairn/core/theme/cairn_theme.dart';
import 'package:cairn/domain/model/tracked_app.dart';
import 'package:cairn/providers/providers.dart';
import 'package:cairn/ui/home/home_state.dart';
import 'package:cairn/ui/manage/manage_apps_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  void useRoomySurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(1400, 3000);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  const home = HomeState(
    meta: HomeMeta(
      metaStreak: 3,
      dayNumber: 3,
      allCleanToday: true,
      rolloverInHours: 5,
      bestRun: 9,
      lifetimeClean: 40,
    ),
    apps: [
      HomeAppVm(
        packageId: 'com.reddit',
        name: 'Reddit',
        monogram: 'R',
        currentStreak: 3,
        today: TodayStatus.stillClean,
      ),
    ],
  );

  testWidgets('manage surfaces summited (freed) apps in their own section', (tester) async {
    useRoomySurface(tester);
    final freed = TrackedApp(
      packageId: 'com.instagram',
      displayName: 'Instagram',
      addedAt: DateTime(2026, 1, 1),
      status: AppStatus.freed,
      freedAt: DateTime(2026, 6, 1),
    );
    final active = TrackedApp(
      packageId: 'com.reddit',
      displayName: 'Reddit',
      addedAt: DateTime(2026, 1, 1),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeStateProvider.overrideWith((ref) => home),
          trackedAppsProvider.overrideWith((ref) => Stream.value([active, freed])),
        ],
        child: MaterialApp(theme: CairnTheme.dark(), home: const ManageAppsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // The freed app must be reachable as a permanent trophy.
    expect(find.text('SUMMITED'), findsOneWidget);
    expect(find.text('Instagram'), findsOneWidget);
    // The active list still shows the tracked app.
    expect(find.text('Reddit'), findsOneWidget);
  });
}
