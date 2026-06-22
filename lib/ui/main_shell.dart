import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core_tabs.dart';
import 'home/home_screen.dart';
import 'manage/manage_apps_screen.dart';
import 'settings/settings_screen.dart';
import 'widgets/cairn_bottom_nav.dart';

/// The persistent home shell. The three top-level destinations live in an
/// [IndexedStack] under a single, fixed [CairnBottomNav], so switching tabs swaps
/// only the content — the bar never slides with a page transition. Detail screens
/// (app detail, recap, about) still push as full routes over the shell.
class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(selectedTabProvider);
    void go(CairnTab t) => ref.read(selectedTabProvider.notifier).select(t);

    return PopScope(
      // On a non-Home tab, the system back button returns to Home first instead
      // of leaving the app.
      canPop: tab == CairnTab.home,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) go(CairnTab.home);
      },
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: IndexedStack(
                sizing: StackFit.expand,
                index: tab.index,
                children: const [
                  HomeScreen(),
                  ManageAppsScreen(),
                  SettingsScreen(),
                ],
              ),
            ),
            CairnBottomNav(current: tab, onSelect: go),
          ],
        ),
      ),
    );
  }
}
