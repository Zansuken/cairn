import 'package:flutter/material.dart';

import 'core/theme/cairn_theme.dart';
import 'ui/boot_splash.dart';
import 'ui/recap/daily_recap_screen.dart';
import 'ui/root_gate.dart';

/// Key on the root navigator so a tapped notification can route into the app
/// from outside the widget tree (see NotificationService + main).
final rootNavigatorKey = GlobalKey<NavigatorState>();

bool _recapOpen = false;

/// Open the daily recap from a notification tap. Safe to call before the first
/// frame settles — it no-ops until the navigator is attached — and guards
/// against repeated taps stacking multiple recap screens.
void showDailyRecap() {
  final nav = rootNavigatorKey.currentState;
  if (nav == null || _recapOpen) return;
  _recapOpen = true;
  nav
      .push(MaterialPageRoute(builder: (_) => const DailyRecapScreen()))
      .whenComplete(() => _recapOpen = false);
}

/// Root widget. Dark-first: the dark theme leads, light is the polished
/// secondary.
class CairnApp extends StatelessWidget {
  const CairnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cairn',
      debugShowCheckedModeBanner: false,
      navigatorKey: rootNavigatorKey,
      theme: CairnTheme.light(),
      darkTheme: CairnTheme.dark(),
      themeMode: ThemeMode.dark,
      home: const BootSplash(child: RootGate()),
    );
  }
}
