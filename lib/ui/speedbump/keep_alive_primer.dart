import 'package:flutter/material.dart';

import '../../core/theme/cairn_colors.dart';
import '../../core/theme/cairn_typography.dart';

/// Shown right after the user turns on Streak guard, but only on phones whose
/// makers aggressively freeze background apps (see [isAggressiveOem]). On those,
/// a battery-optimization exemption is not enough: the watcher gets frozen within
/// seconds of Cairn going to the background, so the pause never appears. This
/// step sends the user to the OEM "app launch / protected apps" page to allow
/// background activity. Copy is plain and calm: no em dashes, no fancy unicode.
class KeepAlivePrimer extends StatelessWidget {
  const KeepAlivePrimer({
    super.key,
    required this.onOpenSettings,
    required this.onContinue,
  });

  /// Opens the OEM app-launch / protected-apps settings page.
  final VoidCallback onOpenSettings;

  /// Continue past this step (the user has allowed background activity, or chose
  /// to do it later).
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CairnColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(30, 6, 30, 8),
                children: [
                  _mascot(),
                  Text(
                    'Keep the guard running',
                    style: CairnType.interface(28, FontWeight.w600,
                        color: CairnColors.textHi, height: 1.2, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'This phone can put apps to sleep to save battery. If that happens to '
                    'Cairn, the pause will not appear when you open a tracked app. Allowing '
                    'Cairn to run in the background keeps the guard working.',
                    style: CairnType.interface(16, FontWeight.w400,
                        color: CairnColors.textDim, height: 1.55),
                  ),
                  const SizedBox(height: 22),
                  _bullet('Tap "Open background settings" below.'),
                  _bullet('Find Cairn in the list.'),
                  _bullet('Allow auto-launch and running in the background.'),
                ],
              ),
            ),
            _actions(),
          ],
        ),
      ),
    );
  }

  Widget _mascot() {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 10),
      child: SizedBox(
        height: 180,
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 230,
                height: 230,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [CairnColors.sage.withValues(alpha: 0.13), CairnColors.sage.withValues(alpha: 0)],
                    stops: const [0, 0.68],
                  ),
                ),
              ),
              Image.asset('assets/cairn_building.png', height: 168, fit: BoxFit.contain),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 7,
            height: 7,
            decoration: const BoxDecoration(color: CairnColors.sage, shape: BoxShape.circle),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(text,
                style: CairnType.interface(14, FontWeight.w400, color: CairnColors.textDim, height: 1.45)),
          ),
        ],
      ),
    );
  }

  Widget _actions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(30, 14, 30, 24),
      decoration: const BoxDecoration(
        color: CairnColors.canvas,
        border: Border(top: BorderSide(color: CairnColors.borderSoft)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: onOpenSettings, child: const Text('Open background settings')),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onContinue,
            style: TextButton.styleFrom(foregroundColor: CairnColors.textSubtle),
            child: const Text('Continue'),
          ),
          const SizedBox(height: 4),
          Text('A battery exemption alone is not enough on this phone.',
              style: CairnType.mono(11, color: CairnColors.textFaint, letterSpacing: 0.4)),
        ],
      ),
    );
  }
}
