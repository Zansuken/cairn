import 'package:cairn/core/theme/cairn_theme.dart';
import 'package:cairn/data/db/database.dart';
import 'package:cairn/providers/providers.dart';
import 'package:cairn/ui/home/home_state.dart';
import 'package:cairn/ui/main_shell.dart';
import 'package:cairn/ui/widgets/cairn_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  void useRoomySurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(1400, 3200);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  const home = HomeState(
    meta: HomeMeta(
      metaStreak: 0,
      dayNumber: 0,
      allCleanToday: true,
      rolloverInHours: 5,
      bestRun: 0,
      lifetimeClean: 0,
    ),
    apps: [],
  );

  const settings = AppSettingsRow(
    id: 0,
    dayResetHour: 4,
    notificationsEnabled: true,
    dailySummaryMinutes: 540,
    milestonesEnabled: true,
    analyticsOptIn: false,
    onboardingComplete: true,
    speedBumpEnabled: false,
  );

  testWidgets('the bottom bar is persistent and tabs swap via IndexedStack',
      (tester) async {
    useRoomySurface(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeStateProvider.overrideWith((ref) => home),
          settingsProvider.overrideWith((ref) => Stream.value(settings)),
          trackedAppsProvider.overrideWith((ref) => Stream.value(const [])),
        ],
        child: MaterialApp(theme: CairnTheme.dark(), home: const MainShell()),
      ),
    );
    await tester.pumpAndSettle();

    IndexedStack stack() => tester.widget<IndexedStack>(find.byType(IndexedStack));

    // Exactly one bar, shared across every tab (not one per screen), and it
    // never slides: tapping a tab only moves the IndexedStack index.
    expect(find.byType(CairnBottomNav), findsOneWidget);
    expect(stack().index, 0);

    await tester.tap(find.text('APPS'));
    await tester.pumpAndSettle();
    expect(stack().index, 1);
    expect(find.byType(CairnBottomNav), findsOneWidget);

    await tester.tap(find.text('SETTINGS'));
    await tester.pumpAndSettle();
    expect(stack().index, 2);
    expect(find.byType(CairnBottomNav), findsOneWidget);

    await tester.tap(find.text('HOME'));
    await tester.pumpAndSettle();
    expect(stack().index, 0);
  });
}
