import 'package:flutter/material.dart';

import '../../core/theme/cairn_colors.dart';
import '../../core/theme/cairn_typography.dart';

/// Onboarding completion (screen-prompts §7): the first stone is placed, quietly
/// celebratory, one "Start" into Home.
class AllSetScreen extends StatelessWidget {
  const AllSetScreen({super.key, required this.trackedNames, required this.onStart});

  final List<String> trackedNames;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CairnColors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 8, 32, 28),
          child: Column(
            children: [
              const SizedBox(height: 14),
              Text('DAY 1 BEGINS', style: CairnType.mono(11, color: CairnColors.sage, letterSpacing: 2.4)),
              Expanded(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [CairnColors.sage.withValues(alpha: 0.15), CairnColors.sage.withValues(alpha: 0)],
                            stops: const [0, 0.68],
                          ),
                        ),
                      ),
                      Image.asset('assets/cairn_building.png', height: 224, fit: BoxFit.contain),
                    ],
                  ),
                ),
              ),
              Text(
                'Your first stone is placed.',
                textAlign: TextAlign.center,
                style: CairnType.interface(32, FontWeight.w600, color: CairnColors.textHi, height: 1.18, letterSpacing: -0.6),
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Text(
                  'Tracking has begun. Stay away today, and tomorrow your cairn grows one stone taller.',
                  textAlign: TextAlign.center,
                  style: CairnType.interface(16, FontWeight.w400, color: CairnColors.textDim, height: 1.55),
                ),
              ),
              const SizedBox(height: 18),
              _trackingPill(),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(onPressed: onStart, child: const Text('Start')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _trackingPill() {
    final names = trackedNames.isEmpty ? '—' : trackedNames.join(', ');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: CairnColors.cairnStage,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: CairnColors.borderSoft),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 7, height: 7, decoration: const BoxDecoration(color: CairnColors.sage, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Flexible(
            child: Text('Now tracking · $names',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CairnType.mono(11, color: CairnColors.textDim, letterSpacing: 0.4)),
          ),
        ],
      ),
    );
  }
}
