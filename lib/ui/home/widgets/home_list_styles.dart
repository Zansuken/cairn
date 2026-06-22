import 'package:flutter/material.dart';

import '../../../core/theme/cairn_colors.dart';
import '../../../core/theme/cairn_typography.dart';
import '../../app_detail/app_detail_screen.dart';
import '../../widgets/app_icon_tile.dart';
import '../../widgets/stone_stack.dart';
import '../home_state.dart';

BorderSide get _hairline => const BorderSide(color: CairnColors.borderSoft);

void _open(BuildContext context, HomeAppVm app) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => AppDetailScreen(packageId: app.packageId)),
  );
}

// ── Option A — Quiet rows ─────────────────────────────────────────────────
class QuietRowsList extends StatelessWidget {
  const QuietRowsList({super.key, required this.apps});
  final List<HomeAppVm> apps;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < apps.length; i++) _row(context, apps[i], last: i == apps.length - 1),
      ],
    );
  }

  Widget _row(BuildContext context, HomeAppVm app, {required bool last}) {
    return InkWell(
      onTap: () => _open(context, app),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        decoration: BoxDecoration(
          border: Border(bottom: last ? BorderSide.none : _hairline),
        ),
        child: Row(
          children: [
            AppIconTile(monogram: app.monogram),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(app.name, style: CairnType.interface(16, FontWeight.w600, color: CairnColors.textHi)),
                  const SizedBox(height: 2),
                  Text(app.today.label,
                      style: CairnType.interface(13, FontWeight.w400, color: CairnColors.textSubtle)),
                ],
              ),
            ),
            StoneStack(
              count: stoneCountForStreak(app.currentStreak),
              boxHeight: 52,
              width: 40,
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 38,
              child: Text(
                '${app.currentStreak}',
                textAlign: TextAlign.right,
                style: CairnType.interface(22, FontWeight.w600, color: CairnColors.textHi),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

