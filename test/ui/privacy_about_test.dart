import 'package:cairn/core/theme/cairn_theme.dart';
import 'package:cairn/platform/link_launcher.dart';
import 'package:cairn/providers/providers.dart';
import 'package:cairn/ui/privacy/privacy_about_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLink implements LinkLauncher {
  final opened = <String>[];

  @override
  Future<bool> open(String url) async {
    opened.add(url);
    return true;
  }
}

void main() {
  Widget host(_FakeLink link) => ProviderScope(
        overrides: [linkLauncherProvider.overrideWithValue(link)],
        child: MaterialApp(
          theme: CairnTheme.dark(),
          home: const PrivacyAboutScreen(),
        ),
      );

  void usePhoneSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('tapping Source code opens the public repo', (tester) async {
    usePhoneSurface(tester);
    final link = _FakeLink();
    await tester.pumpWidget(host(link));
    await tester.pump();

    await tester.tap(find.text('Source code'));
    await tester.pump();

    expect(link.opened, ['https://github.com/Zansuken/cairn']);
  });

  testWidgets('the Source code row shows the real repo path', (tester) async {
    usePhoneSurface(tester);
    await tester.pumpWidget(host(_FakeLink()));
    await tester.pump();

    expect(find.text('github.com/Zansuken/cairn'), findsOneWidget);
    expect(find.text('github.com/cairn-app'), findsNothing);
  });

  testWidgets('the F-Droid row is hidden until Cairn is published there', (tester) async {
    usePhoneSurface(tester);
    await tester.pumpWidget(host(_FakeLink()));
    await tester.pump();

    expect(find.text('Get it on F-Droid'), findsNothing);
  });

  testWidgets('tapping Leave a tip opens the Ko-fi page', (tester) async {
    usePhoneSurface(tester);
    final link = _FakeLink();
    await tester.pumpWidget(host(link));
    await tester.pump();

    // Scroll to the footer (below the tip card) so the button is fully in view
    // rather than clipped at the bottom edge, which would make the tap miss.
    await tester.scrollUntilVisible(find.text('Mark the days you stayed away.'), 240,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Leave a tip'));
    await tester.pump();

    expect(link.opened, ['https://ko-fi.com/zansuken']);
  });
}
