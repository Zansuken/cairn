import 'package:cairn/app.dart';
import 'package:cairn/data/db/database.dart';
import 'package:cairn/domain/model/tracked_app.dart';
import 'package:cairn/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  AppSettingsRow settings({required bool onboardingComplete}) => AppSettingsRow(
        id: 0,
        dayResetHour: 4,
        notificationsEnabled: true,
        dailySummaryMinutes: 540,
        milestonesEnabled: true,
        analyticsOptIn: false,
        onboardingComplete: onboardingComplete,
        speedBumpEnabled: false,
      );

  Future<void> pumpApp(
    WidgetTester tester, {
    required bool granted,
    required bool onboardingComplete,
    List<TrackedApp> tracked = const [],
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsProvider.overrideWith((ref) => Stream.value(settings(onboardingComplete: onboardingComplete))),
          trackedAppsProvider.overrideWith((ref) => Stream.value(tracked)),
          permissionStatusProvider.overrideWith((ref) async => granted),
        ],
        child: const CairnApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('completed onboarding + no access boots into the permission primer', (tester) async {
    await pumpApp(tester, granted: false, onboardingComplete: true);

    expect(find.text('Grant access'), findsOneWidget);
    final ctx = tester.element(find.text('Grant access'));
    expect(Theme.of(ctx).brightness, Brightness.dark);
  });

  testWidgets('first run (no apps, onboarding incomplete) shows the onboarding pitch', (tester) async {
    await pumpApp(tester, granted: false, onboardingComplete: false);

    expect(find.text('CAIRN'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.textContaining('A streak for the days you'), findsOneWidget);
  });
}
