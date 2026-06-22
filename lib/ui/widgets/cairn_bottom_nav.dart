import 'package:flutter/material.dart';

import '../../core/theme/cairn_colors.dart';
import '../../core/theme/cairn_typography.dart';

enum CairnTab { home, apps, settings }

/// The three-tab bottom bar. Only Home is wired in build step (b); Apps and
/// Settings light up when their screens land (step g).
class CairnBottomNav extends StatelessWidget {
  const CairnBottomNav({super.key, required this.current, this.onSelect});

  final CairnTab current;
  final ValueChanged<CairnTab>? onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: CairnColors.navBar,
        border: Border(top: BorderSide(color: CairnColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _item(CairnTab.home, 'Home', Icons.home_rounded, Icons.home_outlined),
          _item(CairnTab.apps, 'Apps', Icons.apps_rounded, Icons.apps_outlined),
          _item(CairnTab.settings, 'Settings', Icons.settings_rounded, Icons.settings_outlined),
        ],
      ),
    );
  }

  Widget _item(CairnTab tab, String label, IconData activeIcon, IconData inactiveIcon) {
    final active = tab == current;
    final color = active ? CairnColors.sage : CairnColors.textMuted;
    return Expanded(
      child: InkResponse(
        onTap: onSelect == null ? null : () => onSelect!(tab),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(active ? activeIcon : inactiveIcon, size: 22, color: color),
            const SizedBox(height: 4),
            Text(label.toUpperCase(), style: CairnType.mono(9, color: color, letterSpacing: 0.9)),
          ],
        ),
      ),
    );
  }
}
