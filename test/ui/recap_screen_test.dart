import 'package:cairn/core/theme/cairn_theme.dart';
import 'package:cairn/domain/daily_recap.dart';
import 'package:cairn/providers/providers.dart';
import 'package:cairn/ui/recap/daily_recap_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // A roomy surface: widget tests run without the bundled fonts, so the
  // fallback font's wider metrics can trip per-pixel overflow on a phone-narrow
  // surface. We're asserting wiring/presence here, not pixel layout (that's
  // validated on-device at the design's 392dp), so give it room.
  void useRoomySurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(1600, 3200);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('daily recap renders headline, rows and the calm Done action', (tester) async {
    useRoomySurface(tester);
    final recap = buildDailyRecap(
      apps: const [
        RecapInput(packageId: 'a', name: 'Reddit', monogram: 'R', state: RecapState.clean, currentStreak: 47),
        RecapInput(packageId: 'b', name: 'TikTok', monogram: 'T', state: RecapState.slipped, currentStreak: 0),
      ],
      lifetimeClean: 132,
      perfectRun: 0,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [dailyRecapProvider.overrideWith((ref) => recap)],
        child: MaterialApp(theme: CairnTheme.dark(), home: const DailyRecapScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1 of 2 cairns grew yesterday.'), findsOneWidget);
    expect(find.text('Reddit'), findsOneWidget);
    expect(find.text('TikTok'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
  });
}
