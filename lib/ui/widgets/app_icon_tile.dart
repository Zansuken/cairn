import 'package:flutter/material.dart';

import '../../core/theme/cairn_colors.dart';
import '../../core/theme/cairn_dimens.dart';
import '../../core/theme/cairn_typography.dart';

/// Rounded app-icon tile. For now a monogram fallback on a raised tile; the
/// native layer (step e) will supply real launcher icons to slot in here.
class AppIconTile extends StatelessWidget {
  const AppIconTile({super.key, required this.monogram, this.size = 42});

  final String monogram;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: CairnColors.raised,
        borderRadius: BorderRadius.circular(CairnRadii.md - 2),
      ),
      child: Text(
        monogram,
        style: CairnType.mono(size * 0.34, color: CairnColors.textDim),
      ),
    );
  }
}
