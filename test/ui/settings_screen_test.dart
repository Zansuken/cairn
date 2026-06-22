import 'package:cairn/core/theme/cairn_theme.dart';
import 'package:cairn/data/db/database.dart';
import 'package:cairn/providers/providers.dart';
import 'package:cairn/ui/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  void useRoomySurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(1600, 3200);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  AppSettingsRow rowWith({bool guard = false}) => AppSettingsRow(
        id: 0,
        dayResetHour: 4,
        notificationsEnabled: true,
        dailySummaryMinutes: 540,
        milestonesEnabled: true,
        analyticsOptIn: false,
        onboardingComplete: true,
        speedBumpEnabled: guard,
      );

  final row = rowWith();

  testWidgets('settings shows the day/notifications/privacy controls', (tester) async {
    useRoomySurface(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [settingsProvider.overrideWith((ref) => Stream.value(row))],
        child: MaterialApp(theme: CairnTheme.dark(), home: const SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Day resets at'), findsOneWidget);
    expect(find.text('4:00 AM'), findsOneWidget);
    expect(find.text('Daily summary'), findsOneWidget);
    expect(find.text('9:00 AM'), findsOneWidget); // 540 minutes

    await tester.scrollUntilVisible(find.text('About & open source'), 200,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('About & open source'), findsOneWidget);
    // The inert analytics toggle was removed for v1 (on-device, nothing to opt into).
    expect(find.text('Anonymous analytics'), findsNothing);
  });

  testWidgets('streak-guard reliability rows appear when the guard is on (aggressive OEM)',
      (tester) async {
    useRoomySurface(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsProvider.overrideWith((ref) => Stream.value(rowWith(guard: true))),
          batteryExemptProvider.overrideWith((ref) async => false),
          deviceManufacturerProvider.overrideWith((ref) async => 'honor'),
        ],
        child: MaterialApp(theme: CairnTheme.dark(), home: const SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Battery optimization'), 200,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('Battery optimization'), findsOneWidget);
    expect(find.text('Restricted'), findsOneWidget); // not exempt
    expect(find.text('Keep running in background'), findsOneWidget); // aggressive OEM
  });

  testWidgets('reliability rows hide the OEM hint on stock Android and read Allowed when exempt',
      (tester) async {
    useRoomySurface(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsProvider.overrideWith((ref) => Stream.value(rowWith(guard: true))),
          batteryExemptProvider.overrideWith((ref) async => true),
          deviceManufacturerProvider.overrideWith((ref) async => 'google'),
        ],
        child: MaterialApp(theme: CairnTheme.dark(), home: const SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Battery optimization'), 200,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('Allowed'), findsOneWidget); // exempt
    expect(find.text('Keep running in background'), findsNothing); // stock Android
  });

  testWidgets('no reliability rows when the guard is off', (tester) async {
    useRoomySurface(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [settingsProvider.overrideWith((ref) => Stream.value(rowWith()))],
        child: MaterialApp(theme: CairnTheme.dark(), home: const SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Battery optimization'), findsNothing);
    expect(find.text('Keep running in background'), findsNothing);
  });
}
