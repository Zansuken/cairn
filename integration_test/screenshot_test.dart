import 'dart:io';

import 'package:cairn/core/theme/cairn_theme.dart';
import 'package:cairn/domain/model/day_state.dart';
import 'package:cairn/providers/providers.dart';
import 'package:cairn/ui/app_detail/app_detail_screen.dart';
import 'package:cairn/ui/app_detail/app_detail_state.dart';
import 'package:cairn/ui/home/home_screen.dart';
import 'package:cairn/ui/home/home_state.dart';
import 'package:cairn/ui/onboarding/onboarding_flow.dart';
import 'package:cairn/ui/privacy/privacy_about_screen.dart';
import 'package:cairn/ui/widgets/cairn_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

// Hand-crafted, realistic view-model data so the data-driven screens look full
// without seeding a database. Each screen is pumped directly (the same pattern
// as the widget tests), so there is no permission gate or navigation to fight.

HomeState _home() => const HomeState(
      meta: HomeMeta(
        metaStreak: 14,
        dayNumber: 14,
        allCleanToday: true,
        rolloverInHours: 8,
        bestRun: 21,
        lifetimeClean: 63,
      ),
      apps: [
        HomeAppVm(
            packageId: 'com.instagram.android',
            name: 'Instagram',
            monogram: 'I',
            currentStreak: 23,
            today: TodayStatus.stillClean),
        HomeAppVm(
            packageId: 'com.zhiliaoapp.musically',
            name: 'TikTok',
            monogram: 'T',
            currentStreak: 18,
            today: TodayStatus.stillClean),
        HomeAppVm(
            packageId: 'com.reddit.frontpage',
            name: 'Reddit',
            monogram: 'R',
            currentStreak: 14,
            today: TodayStatus.stillClean),
      ],
    );

List<DayState> _history() {
  final h = List<DayState>.filled(30, DayState.clean);
  h[6] = DayState.slipped;
  h[7] = DayState.unverified;
  h[20] = DayState.slipped;
  return h;
}

AppDetailVm _activeVm() => AppDetailVm(
      packageId: 'com.instagram.android',
      name: 'Instagram',
      monogram: 'I',
      isFreed: false,
      currentStreak: 23,
      bestStreak: 31,
      lifetimeClean: 88,
      today: DayState.clean,
      history: _history(),
    );

AppDetailVm _freedVm() => AppDetailVm(
      packageId: 'com.zhiliaoapp.musically',
      name: 'TikTok',
      monogram: 'T',
      isFreed: true,
      currentStreak: 63,
      bestStreak: 63,
      lifetimeClean: 121,
      today: DayState.unverified,
      history: const [],
      freedAt: DateTime(2026, 5, 18),
    );

Widget _shell(Widget home) => ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: CairnTheme.dark(),
        home: home,
      ),
    );

Widget _homeApp() => ProviderScope(
      overrides: [homeStateProvider.overrideWith((ref) => _home())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: CairnTheme.dark(),
        home: Scaffold(
          body: Column(
            children: [
              const Expanded(child: HomeScreen()),
              CairnBottomNav(current: CairnTab.home, onSelect: (_) {}),
            ],
          ),
        ),
      ),
    );

Widget _detailApp(AppDetailVm vm) => ProviderScope(
      overrides: [appDetailProvider(vm.packageId).overrideWith((ref) => vm)],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: CairnTheme.dark(),
        home: AppDetailScreen(packageId: vm.packageId),
      ),
    );

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Let bundled assets (the mascot art) and fonts finish decoding before a shot.
  Future<void> ready(WidgetTester tester) async {
    await tester.pumpAndSettle();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 700)));
    await tester.pumpAndSettle();
  }

  // Each screen lives in its own test so it gets a freshly mounted ProviderScope
  // (re-pumping a new scope into the same root makes Riverpod diff the override
  // sets and throw), and so one bad screen never blocks the others.
  Future<void> shoot(WidgetTester tester, String name) async {
    await ready(tester);
    try {
      await binding.convertFlutterSurfaceToImage();
    } catch (_) {
      // Surface is converted once per process; later calls throw and are fine.
    }
    await tester.pumpAndSettle();
    // takeScreenshot returns the PNG bytes captured on-device. We write them to
    // the app's external files dir ourselves (then adb pull), because the driver
    // channel that would otherwise ferry them to the host is flaky on this setup.
    final bytes = await binding.takeScreenshot(name);
    await tester.runAsync(() async {
      final dir = await getExternalStorageDirectory();
      if (dir != null) {
        final file = File('${dir.path}/shots/$name.png');
        await file.parent.create(recursive: true);
        await file.writeAsBytes(bytes);
      }
    });
  }

  testWidgets('01_home', (tester) async {
    await tester.pumpWidget(_homeApp());
    await shoot(tester, '01_home');
  });

  testWidgets('02_detail', (tester) async {
    await tester.pumpWidget(_detailApp(_activeVm()));
    await shoot(tester, '02_detail');
  });

  testWidgets('03_summit', (tester) async {
    await tester.pumpWidget(_detailApp(_freedVm()));
    await shoot(tester, '03_summit');
  });

  testWidgets('04_onboarding', (tester) async {
    await tester.pumpWidget(_shell(const OnboardingFlow()));
    await shoot(tester, '04_onboarding');
  });

  testWidgets('05_how_it_works', (tester) async {
    await tester.pumpWidget(_shell(const OnboardingFlow()));
    await ready(tester);
    await tester.tap(find.text('Continue'));
    await shoot(tester, '05_how_it_works');
  });

  testWidgets('06_privacy', (tester) async {
    await tester.pumpWidget(_shell(const PrivacyAboutScreen()));
    await shoot(tester, '06_privacy');
  });
}
