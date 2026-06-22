import 'package:flutter/material.dart';

import '../../core/theme/cairn_colors.dart';
import '../../core/theme/cairn_dimens.dart';
import '../../core/theme/cairn_typography.dart';

/// The "ON-DEVICE" trust tag — privacy as a visible, earned signal.
class OnDevicePill extends StatelessWidget {
  const OnDevicePill({super.key, this.label = 'On-device'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(CairnRadii.pill),
        border: Border.all(color: CairnColors.sage.withValues(alpha: 0.3)),
      ),
      child: Text(
        label.toUpperCase(),
        style: CairnType.mono(10, color: CairnColors.sage, letterSpacing: 1.6),
      ),
    );
  }
}
