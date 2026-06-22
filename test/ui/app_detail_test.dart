import 'package:cairn/core/theme/cairn_theme.dart';
import 'package:cairn/domain/model/day_state.dart';
import 'package:cairn/providers/providers.dart';
import 'package:cairn/ui/app_detail/app_detail_screen.dart';
import 'package:cairn/ui/app_detail/app_detail_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host(AppDetailVm vm) => ProviderScope(
        overrides: [appDetailProvider(vm.packageId).overrideWith((ref) => vm)],
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
}
