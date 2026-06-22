import 'package:flutter/material.dart';

import '../../../core/theme/cairn_colors.dart';
import '../../../core/theme/cairn_dimens.dart';
import '../../../core/theme/cairn_typography.dart';
import '../home_state.dart';

/// The Home hero: the global "perfect-day" meta-streak as the focal number,
/// the living cairn beside it, today's rollover line, and best/lifetime stats.
class CairnHero extends StatelessWidget {
  const CairnHero({super.key, required this.meta});

  final HomeMeta meta;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      decoration: BoxDecoration(
        color: CairnColors.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: CairnColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PERFECT-DAY RUN', style: CairnType.monoTag.copyWith(fontSize: 10, letterSpacing: 1.8)),
                    const SizedBox(height: 2),
                    Text(
                      '${meta.metaStreak}',
                      style: CairnType.interface(74, FontWeight.w600,
                          color: CairnColors.textHi, height: 0.88, letterSpacing: -2.2),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      meta.allCleanToday
                          ? 'Day ${meta.dayNumber}, still clean today'
                          : 'A tracked app was opened today',
                      style: CairnType.interface(15, FontWeight.w400, color: CairnColors.textDim),
                    ),
                  ],
                ),
              ),
              Image.asset('assets/cairn_building.png', height: 140, fit: BoxFit.contain),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(color: CairnColors.sage, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _rolloverLine(meta),
                  style: CairnType.interface(13, FontWeight.w400, color: CairnColors.textSubtle),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 18, 0, 16),
            child: Divider(height: 1, color: CairnColors.textHi.withValues(alpha: 0.08)),
          ),
          Row(
            children: [
              _stat('Best run', '${meta.bestRun} days'),
              const SizedBox(width: CairnSpacing.xl),
              _stat('Lifetime clean', '${meta.lifetimeClean} days'),
            ],
          ),
        ],
      ),
    );
  }

  String _rolloverLine(HomeMeta m) {
    final tail = m.allCleanToday ? 'every tracked app still clean' : 'one app opened today';
    return 'Today rolls over in ${m.rolloverInHours}h · $tail';
  }

  Widget _stat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: CairnType.mono(10, color: CairnColors.textMuted, letterSpacing: 1.4)),
        const SizedBox(height: 3),
        Text(value, style: CairnType.interface(17, FontWeight.w600, color: CairnColors.textHi)),
      ],
    );
  }
}
