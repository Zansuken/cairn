import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme/cairn_colors.dart';

/// The branded boot moment. The cairn mascot settles in over the dark canvas
/// with its soft sage glow, holds for a beat, then fades to reveal [child].
///
/// The OS (native) splash uses the same canvas colour and mascot, so the hand-off
/// into this screen is seamless — no colour jump, no logo pop.
class BootSplash extends StatefulWidget {
  const BootSplash({super.key, required this.child});

  final Widget child;

  @override
  State<BootSplash> createState() => _BootSplashState();
}

class _BootSplashState extends State<BootSplash> with SingleTickerProviderStateMixin {
  late final AnimationController _in;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  // Once true, the splash layer cross-fades out to reveal the app underneath.
  bool _revealed = false;
  Timer? _revealTimer;

  static const _holdBeforeReveal = Duration(milliseconds: 1150);
  static const _revealDuration = Duration(milliseconds: 480);

  @override
  void initState() {
    super.initState();
    _in = AnimationController(vsync: this, duration: const Duration(milliseconds: 720))..forward();
    _fade = CurvedAnimation(parent: _in, curve: Curves.easeOut);
    _scale = Tween(begin: 0.92, end: 1.0)
        .animate(CurvedAnimation(parent: _in, curve: Curves.easeOutCubic));
    _revealTimer = Timer(_holdBeforeReveal, () {
      if (mounted) setState(() => _revealed = true);
    });
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    _in.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The app boots underneath while the splash plays.
        widget.child,
        IgnorePointer(
          ignoring: _revealed,
          child: AnimatedOpacity(
            opacity: _revealed ? 0 : 1,
            duration: _revealDuration,
            curve: Curves.easeOut,
            child: _splash(),
          ),
        ),
      ],
    );
  }

  Widget _splash() {
    return ColoredBox(
      color: CairnColors.canvas,
      child: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        CairnColors.sage.withValues(alpha: 0.14),
                        CairnColors.sage.withValues(alpha: 0),
                      ],
                      stops: const [0, 0.68],
                    ),
                  ),
                ),
                Image.asset('assets/cairn_building.png', height: 188, fit: BoxFit.contain),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
