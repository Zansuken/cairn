import 'package:flutter/material.dart';

import '../../core/theme/cairn_colors.dart';
import '../../core/theme/cairn_typography.dart';

/// The Streak guard consent screen: explains the in-the-moment pause and what it
/// needs (draw over other apps + a quiet background notice), then offers to turn
/// it on or skip. Used as an onboarding step and reachable later from Settings.
/// Copy is plain and calm: no em dashes, no fancy unicode.
class StreakGuardPrimer extends StatelessWidget {
  const StreakGuardPrimer({
    super.key,
    required this.onTurnOn,
    required this.onSkip,
    this.needsPermissionHint = false,
  });

  final VoidCallback onTurnOn;
  final VoidCallback onSkip;

  /// True after the user came back from system settings without granting overlay.
  final bool needsPermissionHint;

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
                    'A calm pause before you open',
                    style: CairnType.interface(28, FontWeight.w600,
                        color: CairnColors.textHi, height: 1.2, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'When you open an app you are keeping a streak on, Cairn can show a short, '
                    'calm reminder first. You decide what happens next: stay away, or open it '
                    'anyway. Cairn never blocks you.',
                    style: CairnType.interface(16, FontWeight.w400,
                        color: CairnColors.textDim, height: 1.55),
                  ),
                  const SizedBox(height: 22),
                  _bullet('Shows only for the apps you are tracking.'),
                  _bullet('It checks which app you opened, only to show the pause. '
                      'Nothing is ever sent anywhere.'),
                  _bullet('It runs quietly in the background, so you will see a small ongoing notice.'),
                  if (needsPermissionHint) ...[
                    const SizedBox(height: 18),
                    _hint(),
                  ],
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

  Widget _hint() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: CairnColors.cairnStage,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CairnColors.borderSoft),
      ),
      child: Text(
        "Cairn still needs the \"draw over other apps\" permission. Tap \"Turn on Streak guard\" to try again.",
        style: CairnType.interface(13, FontWeight.w400, color: CairnColors.textDim, height: 1.45),
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
            child: FilledButton(onPressed: onTurnOn, child: const Text('Turn on Streak guard')),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onSkip,
            style: TextButton.styleFrom(foregroundColor: CairnColors.textSubtle),
            child: const Text('Maybe later'),
          ),
          const SizedBox(height: 4),
          Text('Opens your phone settings. You can turn it off anytime.',
              style: CairnType.mono(11, color: CairnColors.textFaint, letterSpacing: 0.4)),
        ],
      ),
    );
  }
}
