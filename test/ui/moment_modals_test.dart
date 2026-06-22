import 'package:cairn/core/theme/cairn_theme.dart';
import 'package:cairn/domain/moment_detector.dart';
import 'package:cairn/ui/moments/moment_modals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget trigger(MomentEvent event) => MaterialApp(
        theme: CairnTheme.dark(),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showMomentModals(context, [event]),
                child: const Text('go'),
              ),
            ),
          ),
        ),
      );

  void usePhoneSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('milestone modal shows the number and a single calm action', (tester) async {
    usePhoneSurface(tester);
    await tester.pumpWidget(trigger(
      const MomentEvent(kind: MomentKind.milestone, packageId: 'a', name: 'TikTok', value: 7),
    ));
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();

    expect(find.text('MILESTONE'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.textContaining('A full week without TikTok'), findsOneWidget);
    expect(find.text('Nice'), findsOneWidget);
  });

  testWidgets('slip modal reassures with the preserved trail and best run', (tester) async {
    usePhoneSurface(tester);
    await tester.pumpWidget(trigger(
      const MomentEvent(kind: MomentKind.slip, packageId: 'a', name: 'TikTok', value: 47, extra: 28),
    ));
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();

    expect(find.text('Run ended. A new stack starts now.'), findsOneWidget);
    expect(find.text('YOUR TRAIL'), findsOneWidget);
    expect(find.text('47'), findsOneWidget);
    expect(find.text('28 days'), findsOneWidget);
    expect(find.text('Start a new stack'), findsOneWidget);
  });
}
