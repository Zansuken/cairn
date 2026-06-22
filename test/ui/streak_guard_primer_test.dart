import 'package:cairn/core/theme/cairn_theme.dart';
import 'package:cairn/ui/speedbump/streak_guard_primer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  void useRoomySurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(1400, 3200);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('streak guard primer renders the two actions and fires them', (tester) async {
    useRoomySurface(tester);
    var turnedOn = false;
    var skipped = false;
    await tester.pumpWidget(MaterialApp(
      theme: CairnTheme.dark(),
      home: StreakGuardPrimer(
        onTurnOn: () => turnedOn = true,
        onSkip: () => skipped = true,
      ),
    ));
    await tester.pump();

    expect(find.text('A calm pause before you open'), findsOneWidget);
    expect(find.text('Turn on Streak guard'), findsOneWidget);
    expect(find.text('Maybe later'), findsOneWidget);

    await tester.tap(find.text('Maybe later'));
    expect(skipped, isTrue);
    await tester.tap(find.text('Turn on Streak guard'));
    expect(turnedOn, isTrue);
  });

  testWidgets('the permission hint shows only when requested', (tester) async {
    useRoomySurface(tester);
    await tester.pumpWidget(MaterialApp(
      theme: CairnTheme.dark(),
      home: StreakGuardPrimer(onTurnOn: () {}, onSkip: () {}, needsPermissionHint: true),
    ));
    await tester.pump();
    expect(find.textContaining('draw over other apps'), findsOneWidget);
  });
}
