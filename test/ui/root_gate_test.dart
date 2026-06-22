import 'dart:async';

import 'package:cairn/app.dart';
import 'package:cairn/data/db/database.dart';
import 'package:cairn/domain/model/tracked_app.dart';
import 'package:cairn/providers/providers.dart';
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

  TrackedApp app(String id) => TrackedApp(
        packageId: id,
        displayName: id,
        addedAt: DateTime(2026, 1, 1),
      );

  testWidgets(
      'adding the first app mid-onboarding keeps the onboarding flow on screen',
      (tester) async {
    final tracked = StreamController<List<TrackedApp>>();
    addTearDown(tracked.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsProvider.overrideWith(
              (ref) => Stream.value(settings(onboardingComplete: false))),
          trackedAppsProvider.overrideWith((ref) => tracked.stream),
          // Even if access is somehow granted, onboarding must own the screen
          // until it finishes — never flip to the permission gate / Home.
          permissionStatusProvider.overrideWith((ref) async => false),
        ],
        child: const CairnApp(),
      ),
    );

    // First run: no tracked apps yet -> the onboarding pitch is shown.
    tracked.add(const []);
    await tester.pumpAndSettle();
    expect(find.text('CAIRN'), findsOneWidget);
    expect(find.text('Grant access'), findsNothing);

    // Onboarding's "pick apps" step writes the first tracked app to the DB.
    // onboardingComplete is still false -> onboarding must stay on screen so the
    // remaining steps (Streak guard, All set) can run.
    tracked.add([app('com.example.one')]);
    await tester.pumpAndSettle();

    expect(find.text('CAIRN'), findsOneWidget);
    expect(find.text('Grant access'), findsNothing);
  });

  testWidgets(
      'pre-flag install that already tracks apps skips onboarding',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsProvider.overrideWith(
              (ref) => Stream.value(settings(onboardingComplete: false))),
          trackedAppsProvider
              .overrideWith((ref) => Stream.value([app('com.example.one')])),
          permissionStatusProvider.overrideWith((ref) async => false),
        ],
        child: const CairnApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Already has apps but never onboarded (upgrade) -> straight to the gate,
    // never the onboarding pitch.
    expect(find.text('CAIRN'), findsNothing);
    expect(find.text('Grant access'), findsOneWidget);
  });
}
