import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/cairn_colors.dart';
import '../../core/theme/cairn_typography.dart';
import '../../providers/providers.dart';
import '../core_tabs.dart';
import '../widgets/cairn_bottom_nav.dart';
import '../widgets/on_device_pill.dart';
import 'home_state.dart';
import 'widgets/cairn_hero.dart';
import 'widgets/home_list_styles.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(homeStateProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _topBar(),
            Expanded(
              child: home.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('Couldn’t load your cairns.\n$e', textAlign: TextAlign.center),
                  ),
                ),
                data: (state) => state.isEmpty ? _empty(ref) : _content(ref, state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(WidgetRef ref, HomeState state) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(22, 6, 22, 24),
      children: [
        CairnHero(meta: state.meta),
        _listHeader(state),
        QuietRowsList(apps: state.apps),
        const SizedBox(height: 22),
        _addAppButton(ref),
        const SizedBox(height: 22),
        Center(
          child: Text(
            'Build something by leaving it alone.',
            style: CairnType.mono(11, color: CairnColors.textFaint, letterSpacing: 0.9),
          ),
        ),
      ],
    );
  }

  Widget _empty(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
      child: Column(
        children: [
          // Mascot up top with its single sage glow; copy + CTA settle lower.
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [CairnColors.sage.withValues(alpha: 0.13), CairnColors.sage.withValues(alpha: 0)],
                        stops: const [0, 0.68],
                      ),
                    ),
                  ),
                  Image.asset('assets/cairn_building.png', height: 204, fit: BoxFit.contain),
                ],
              ),
            ),
          ),
          Text(
            'Your first cairn is waiting.',
            textAlign: TextAlign.center,
            style: CairnType.interface(28, FontWeight.w600, color: CairnColors.textHi, height: 1.1, letterSpacing: -0.4),
          ),
          const SizedBox(height: 12),
          Text(
            'Choose an app you’d like to master. Every day you stay away adds a stone. That’s all it takes.',
            textAlign: TextAlign.center,
            style: CairnType.interface(16, FontWeight.w400, color: CairnColors.textDim, height: 1.55),
          ),
          const SizedBox(height: 26),
          SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: () => _switchTo(ref, CairnTab.apps), child: const Text('Choose an app')),
          ),
          const SizedBox(height: 14),
          Text(
            'Most people start with just one',
            style: CairnType.mono(11, color: CairnColors.textFaint, letterSpacing: 0.6),
          ),
        ],
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Cairn', style: CairnType.interface(21, FontWeight.w600, color: CairnColors.textHi, letterSpacing: -0.2)),
          const OnDevicePill(),
        ],
      ),
    );
  }

  Widget _listHeader(HomeState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 24, 4, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('YOUR CAIRNS', style: CairnType.mono(11, color: CairnColors.textMuted, letterSpacing: 1.7)),
          Text('${state.apps.length} apps', style: CairnType.mono(11, color: CairnColors.textMuted)),
        ],
      ),
    );
  }

  Widget _addAppButton(WidgetRef ref) {
    return InkWell(
      onTap: () => _switchTo(ref, CairnTab.apps),
      borderRadius: BorderRadius.circular(16),
      child: CustomPaint(
        painter: _DashedRRectPainter(color: CairnColors.textHi.withValues(alpha: 0.18), radius: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          alignment: Alignment.center,
          child: Text(
            '+ Track another app',
            style: CairnType.interface(14, FontWeight.w600, color: CairnColors.textDim),
          ),
        ),
      ),
    );
  }

  void _switchTo(WidgetRef ref, CairnTab tab) =>
      ref.read(selectedTabProvider.notifier).select(tab);
}

class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  static const double _dash = 5;
  static const double _gap = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius));
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + _dash), paint);
        distance += _dash + _gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRRectPainter old) => old.color != color || old.radius != radius;
}
