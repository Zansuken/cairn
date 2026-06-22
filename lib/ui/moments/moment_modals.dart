import 'package:flutter/material.dart';

import '../../core/theme/cairn_colors.dart';
import '../../core/theme/cairn_typography.dart';
import '../../domain/moment_detector.dart';
import '../app_detail/app_detail_screen.dart';

/// Presents the detected "moments" (PRD §7) one at a time. Slip and milestone
/// are calm centered modals; Freed is the full-screen summit (the App detail
/// trophy view), the most shareable screen.
Future<void> showMomentModals(BuildContext context, List<MomentEvent> events) async {
  for (final e in events) {
    if (!context.mounted) return;
    switch (e.kind) {
      case MomentKind.slip:
        await _showCardModal(context, _SlipCard(event: e));
      case MomentKind.milestone:
        await _showCardModal(context, _MilestoneCard(event: e));
      case MomentKind.freed:
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => AppDetailScreen(packageId: e.packageId)),
        );
    }
  }
}

Future<void> _showCardModal(BuildContext context, Widget card) {
  return showDialog<void>(
    context: context,
    barrierColor: const Color(0xA6080A08), // .65 near-black, calm dim
    builder: (_) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      // Center when it fits; scroll on short screens so the card never overflows.
      child: Center(child: SingleChildScrollView(child: card)),
    ),
  );
}

/// A modal card with the mascot overlapping its top edge, matching the designs.
class _MomentCard extends StatelessWidget {
  const _MomentCard({required this.mascot, required this.mascotHeight, required this.children, this.glow = false});

  final String mascot;
  final double mascotHeight;
  final bool glow;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: mascotHeight * 0.62),
            padding: const EdgeInsets.fromLTRB(26, 0, 26, 26),
            decoration: BoxDecoration(
              color: CairnColors.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: CairnColors.border),
              boxShadow: const [BoxShadow(color: Color(0x73000000), blurRadius: 50, offset: Offset(0, 20))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [SizedBox(height: mascotHeight * 0.38 + 8), ...children],
            ),
          ),
          Positioned(
            top: 0,
            child: glow
                ? Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [CairnColors.sage.withValues(alpha: 0.16), CairnColors.sage.withValues(alpha: 0)],
                        stops: const [0, 0.68],
                      ),
                    ),
                    child: Image.asset(mascot, height: mascotHeight, fit: BoxFit.contain),
                  )
                : Image.asset(mascot, height: mascotHeight, fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }
}

class _SlipCard extends StatelessWidget {
  const _SlipCard({required this.event});
  final MomentEvent event;

  @override
  Widget build(BuildContext context) {
    return _MomentCard(
      mascot: 'assets/cairn_reset.png',
      mascotHeight: 140,
      children: [
        Text('${event.name.toUpperCase()} · RUN ENDED',
            style: CairnType.mono(10, color: CairnColors.textSubtle, letterSpacing: 2)),
        const SizedBox(height: 14),
        Text('Run ended. A new stack starts now.',
            textAlign: TextAlign.center,
            style: CairnType.interface(26, FontWeight.w600, color: CairnColors.textHi, height: 1.22, letterSpacing: -0.26)),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: Text(
            'You opened ${event.name} today, so this streak resets to zero. '
            "That's alright. The trail you've already walked stays behind you.",
            textAlign: TextAlign.center,
            style: CairnType.interface(15, FontWeight.w400, color: CairnColors.textDim, height: 1.55),
          ),
        ),
        const SizedBox(height: 22),
        _trailCard(),
        const SizedBox(height: 12),
        Text('Your lifetime total and best record are kept. They only ever grow.',
            textAlign: TextAlign.center,
            style: CairnType.interface(12, FontWeight.w400, color: CairnColors.textFaint, height: 1.5)),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Text('Start a new stack'),
          ),
        ),
      ],
    );
  }

  Widget _trailCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: CairnColors.cairnStage,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: CairnColors.sage.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('YOUR TRAIL', style: CairnType.mono(10, color: CairnColors.sage, letterSpacing: 1.4)),
                const SizedBox(height: 3),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('${event.value}',
                        style: CairnType.interface(38, FontWeight.w600, color: CairnColors.textHi, height: 1, letterSpacing: -0.7)),
                    const SizedBox(width: 7),
                    Flexible(
                      child: Text('clean days',
                          style: CairnType.interface(14, FontWeight.w400, color: CairnColors.textDim)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(width: 1, height: 44, color: CairnColors.border),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('BEST RUN', style: CairnType.mono(10, color: CairnColors.textMuted, letterSpacing: 1.4)),
                const SizedBox(height: 3),
                Text('${event.extra} days',
                    style: CairnType.interface(20, FontWeight.w600, color: CairnColors.textHi)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MilestoneCard extends StatelessWidget {
  const _MilestoneCard({required this.event});
  final MomentEvent event;

  @override
  Widget build(BuildContext context) {
    return _MomentCard(
      mascot: 'assets/cairn_proud.png',
      mascotHeight: 168,
      glow: true,
      children: [
        Text('MILESTONE', style: CairnType.mono(10, color: CairnColors.sage, letterSpacing: 2.4)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text('${event.value}',
                style: CairnType.interface(72, FontWeight.w600, color: CairnColors.textHi, height: 0.9, letterSpacing: -2.2)),
            const SizedBox(width: 9),
            Text('days clean', style: CairnType.interface(18, FontWeight.w400, color: CairnColors.textDim)),
          ],
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 270),
          child: Text(
            _affirmation(event.value, event.name),
            textAlign: TextAlign.center,
            style: CairnType.interface(16, FontWeight.w400, color: CairnColors.textDim, height: 1.5),
          ),
        ),
        const SizedBox(height: 26),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Text('Nice'),
          ),
        ),
      ],
    );
  }

  static String _affirmation(int value, String name) => switch (value) {
        7 => "A full week without $name. The habit's taking shape.",
        30 => "Thirty days clean. That's a real stretch behind you.",
        100 => 'A hundred days clean. That’s a long way to come.',
        _ => '$value days clean. Keep building.',
      };
}
