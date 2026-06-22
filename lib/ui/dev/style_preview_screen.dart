import 'package:flutter/material.dart';

import '../../core/theme/cairn_colors.dart';
import '../../core/theme/cairn_dimens.dart';
import '../../core/theme/cairn_typography.dart';

/// Temporary visual smoke-test for the theme, fonts and brand assets.
///
/// Replaced by the real Home screen in build step (b). Mirrors the
/// "Cairn Style Tile" so the dark-first system can be eyeballed on device.
class StylePreviewScreen extends StatelessWidget {
  const StylePreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            CairnSpacing.lg,
            CairnSpacing.xl,
            CairnSpacing.lg,
            CairnSpacing.huge,
          ),
          children: [
            _header(context),
            const SizedBox(height: CairnSpacing.xl),
            const _Divider(),
            _section('01 · Color · dark-first & earthy'),
            _colorGrid(),
            const _Divider(),
            _section('02 · Type · two voices'),
            _typeSpecimens(context),
            const _Divider(),
            _section('03 · Buttons & controls'),
            _buttons(context),
            const _Divider(),
            _section('04 · The living cairn'),
            _mascotRow(),
            const SizedBox(height: CairnSpacing.lg),
            _stoneStack(),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(CairnRadii.xl),
          child: Image.asset('assets/cairn_icon.png', width: 72, height: 72),
        ),
        const SizedBox(width: CairnSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cairn', style: t.displaySmall),
              const SizedBox(height: 6),
              Text('DESIGN SYSTEM V1', style: CairnType.monoTag),
            ],
          ),
        ),
      ],
    );
  }

  Widget _section(String label) => Padding(
        padding: const EdgeInsets.only(bottom: CairnSpacing.md),
        child: Text(label.toUpperCase(), style: CairnType.monoLabel),
      );

  Widget _colorGrid() {
    const swatches = <(String, String, Color)>[
      ('Canvas', '#181D18', CairnColors.canvas),
      ('Surface', '#232A24', CairnColors.surface),
      ('Raised', '#2C342D', CairnColors.raised),
      ('Text Hi', '#ECE7DB', CairnColors.textHi),
      ('Text Dim', '#A7A99B', CairnColors.textDim),
      ('Sand', '#B19C7D', CairnColors.stoneSand),
      ('Grey', '#A59F93', CairnColors.stoneGrey),
      ('Sage stone', '#9EA28B', CairnColors.stoneSage),
      ('Sage accent', '#AAB68F', CairnColors.sage),
    ];
    return Wrap(
      spacing: CairnSpacing.md,
      runSpacing: CairnSpacing.md,
      children: [for (final s in swatches) _Swatch(name: s.$1, hex: s.$2, color: s.$3)],
    );
  }

  Widget _typeSpecimens(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Day 14', style: t.displayLarge),
        const SizedBox(height: CairnSpacing.sm),
        Text('Still clean', style: t.titleLarge),
        const SizedBox(height: CairnSpacing.sm),
        Text('Your trail so far', style: t.titleMedium),
        const SizedBox(height: CairnSpacing.sm),
        Text('A stone for every day you stayed away.', style: t.bodyLarge),
        const SizedBox(height: CairnSpacing.md),
        Text('ON-DEVICE ONLY', style: CairnType.monoTag),
        const SizedBox(height: 6),
        Text('LIFETIME · 47 DAYS', style: CairnType.monoMeta),
      ],
    );
  }

  Widget _buttons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: CairnSpacing.md,
          runSpacing: CairnSpacing.md,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilledButton(onPressed: () {}, child: const Text("Place today's stone")),
            OutlinedButton(onPressed: () {}, child: const Text('Add an app')),
            TextButton(onPressed: () {}, child: const Text('Open anyway')),
          ],
        ),
        const SizedBox(height: CairnSpacing.md),
        Wrap(
          spacing: CairnSpacing.sm,
          children: const [
            _Chip(label: 'TikTok', selected: false),
            _Chip(label: 'Instagram ✓', selected: true),
          ],
        ),
      ],
    );
  }

  Widget _mascotRow() {
    const states = <(String, String)>[
      ('assets/cairn_building.png', 'Building'),
      ('assets/cairn_proud.png', 'Milestone'),
      ('assets/cairn_reset.png', 'Slip / reset'),
      ('assets/cairn_summit.png', 'Freed · summit'),
    ];
    return SizedBox(
      height: 168,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: states.length,
        separatorBuilder: (_, _) => const SizedBox(width: CairnSpacing.md),
        itemBuilder: (_, i) => _MascotCard(asset: states[i].$1, label: states[i].$2),
      ),
    );
  }

  Widget _stoneStack() {
    Widget stone(String asset, double h) =>
        Image.asset(asset, height: h, fit: BoxFit.contain);
    return Container(
      padding: const EdgeInsets.all(CairnSpacing.lg),
      decoration: BoxDecoration(
        color: CairnColors.surface,
        borderRadius: BorderRadius.circular(CairnRadii.lg),
        border: Border.all(color: CairnColors.borderSoft),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('Stacked = a 4-day run', style: CairnType.monoLabel),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.translate(offset: const Offset(0, 4), child: stone('assets/stone_sage.png', 22)),
              Transform.translate(offset: const Offset(0, 3), child: stone('assets/stone_sand.png', 22)),
              Transform.translate(offset: const Offset(0, 3), child: stone('assets/stone_grey.png', 24)),
              stone('assets/stone_sand.png', 26),
            ],
          ),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.name, required this.hex, required this.color});
  final String name;
  final String hex;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 72,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(CairnRadii.md),
              border: Border.all(color: CairnColors.border),
            ),
          ),
          const SizedBox(height: 8),
          Text(name, style: CairnType.interface(13, FontWeight.w500, color: CairnColors.textHi)),
          Text(hex, style: CairnType.mono(11, color: CairnColors.textMuted)),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected});
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: selected ? CairnColors.sage : CairnColors.raised,
        borderRadius: BorderRadius.circular(CairnRadii.pill),
        border: selected ? null : Border.all(color: CairnColors.borderSoft),
      ),
      child: Text(
        label,
        style: CairnType.interface(
          13,
          FontWeight.w500,
          color: selected ? CairnColors.onSage : CairnColors.textHi,
        ),
      ),
    );
  }
}

class _MascotCard extends StatelessWidget {
  const _MascotCard({required this.asset, required this.label});
  final String asset;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      decoration: BoxDecoration(
        color: CairnColors.surface,
        borderRadius: BorderRadius.circular(CairnRadii.lg),
        border: Border.all(color: CairnColors.borderSoft),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              color: CairnColors.cairnStage,
              padding: const EdgeInsets.all(14),
              child: Image.asset(asset, fit: BoxFit.contain),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(label.toUpperCase(), style: CairnType.monoLabel),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: CairnSpacing.xl),
        child: Divider(),
      );
}
