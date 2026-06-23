import 'package:cairn/core/theme/cairn_theme.dart';
import 'package:cairn/ui/speedbump/keep_alive_primer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  void useRoomySurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(1400, 3200);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('keep-alive primer renders the two actions and fires them', (tester) async {
    useRoomySurface(tester);
    var opened = false;
    var continued = false;
    await tester.pumpWidget(MaterialApp(
      theme: CairnTheme.dark(),
      home: KeepAlivePrimer(
        onOpenSettings: () => opened = true,
        onContinue: () => continued = true,
      ),
    ));
    await tester.pump();

    expect(find.text('Keep the guard running'), findsOneWidget);
    expect(find.text('Open background settings'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);

    await tester.tap(find.text('Open background settings'));
    expect(opened, isTrue);
    await tester.tap(find.text('Continue'));
    expect(continued, isTrue);
  });
}
