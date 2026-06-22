import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/curated_apps.dart';
import '../../core/theme/cairn_colors.dart';
import '../../core/theme/cairn_typography.dart';
import '../../platform/usage_service.dart';
import '../../providers/providers.dart';
import '../widgets/stone_stack.dart';

/// First-run "pick your apps" (screen-prompts §6): curated suggestions as
/// selectable cards, a search across all installed apps, the 1–3 nudge, and a
/// footer where the chosen apps preview as small forming cairns.
class PickAppsScreen extends ConsumerStatefulWidget {
  const PickAppsScreen({super.key, required this.onContinue});

  /// Called with the chosen apps when the user confirms.
  final ValueChanged<List<InstalledApp>> onContinue;

  @override
  ConsumerState<PickAppsScreen> createState() => _PickAppsScreenState();
}

class _PickAppsScreenState extends ConsumerState<PickAppsScreen> {
  String _query = '';
  final _selected = <String, InstalledApp>{};

  @override
  Widget build(BuildContext context) {
    final installed = ref.watch(installedAppsProvider);
    return Scaffold(
      backgroundColor: CairnColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 10, 26, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pick your apps',
                      style: CairnType.interface(27, FontWeight.w600, color: CairnColors.textHi, letterSpacing: -0.5)),
                  const SizedBox(height: 8),
                  _rich(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 8),
              child: _searchField(),
            ),
            Expanded(
              child: installed.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Couldn’t list apps.\n$e', textAlign: TextAlign.center)),
                data: (apps) => _grid(apps),
              ),
            ),
            _footer(),
          ],
        ),
      ),
    );
  }

  Widget _rich() {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: 'Start with ', style: CairnType.interface(15, FontWeight.w400, color: CairnColors.textDim, height: 1.5)),
          TextSpan(text: '1 to 3', style: CairnType.interface(15, FontWeight.w600, color: CairnColors.sage, height: 1.5)),
          TextSpan(
            text: ', the ones you most want to master. You can add more later.',
            style: CairnType.interface(15, FontWeight.w400, color: CairnColors.textDim, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _searchField() {
    return TextField(
      onChanged: (v) => setState(() => _query = v),
      style: CairnType.interface(15, FontWeight.w400, color: CairnColors.textHi),
      decoration: InputDecoration(
        hintText: 'Search all installed apps',
        hintStyle: CairnType.interface(15, FontWeight.w400, color: CairnColors.textMuted),
        prefixIcon: const Icon(Icons.search, size: 20, color: CairnColors.textMuted),
        filled: true,
        fillColor: CairnColors.surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: CairnColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: CairnColors.sage),
        ),
      ),
    );
  }

  Widget _grid(List<InstalledApp> apps) {
    final q = _query.trim().toLowerCase();
    final list = apps.where((a) {
      if (q.isEmpty) return curatedPackages.contains(a.packageId);
      return a.label.toLowerCase().contains(q) || a.packageId.toLowerCase().contains(q);
    }).toList()
      ..sort((a, b) {
        final ca = curatedPackages.contains(a.packageId) ? 0 : 1;
        final cb = curatedPackages.contains(b.packageId) ? 0 : 1;
        if (ca != cb) return ca - cb;
        return a.label.toLowerCase().compareTo(b.label.toLowerCase());
      });

    if (list.isEmpty) {
      return Center(
        child: Text(q.isEmpty ? 'No suggested apps installed.' : 'No matches.',
            style: CairnType.interface(14, FontWeight.w400, color: CairnColors.textMuted)),
      );
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(22, 6, 22, 12),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(2, 4, 2, 12),
          child: Text(q.isEmpty ? 'SUGGESTIONS' : 'RESULTS',
              style: CairnType.mono(11, color: CairnColors.textMuted, letterSpacing: 1.6)),
        ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.55,
          children: [for (final a in list) _card(a)],
        ),
      ],
    );
  }

  Widget _card(InstalledApp app) {
    final selected = _selected.containsKey(app.packageId);
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => setState(() {
        if (selected) {
          _selected.remove(app.packageId);
        } else {
          _selected[app.packageId] = app;
        }
      }),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? CairnColors.sage.withValues(alpha: 0.10) : CairnColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? CairnColors.sage : CairnColors.borderSoft,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _icon(app),
                Text(app.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CairnType.interface(16, FontWeight.w600, color: CairnColors.textHi)),
              ],
            ),
            Positioned(top: 0, right: 0, child: _checkCircle(selected)),
          ],
        ),
      ),
    );
  }

  Widget _icon(InstalledApp app) {
    final Uint8List? png = app.iconPng;
    if (png != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Image.memory(png, width: 40, height: 40, fit: BoxFit.cover, gaplessPlayback: true),
      );
    }
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: CairnColors.raised, borderRadius: BorderRadius.circular(11)),
      child: Text(app.label.isEmpty ? '?' : app.label[0].toUpperCase(),
          style: CairnType.mono(13, color: CairnColors.textDim)),
    );
  }

  Widget _checkCircle(bool selected) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? CairnColors.sage : Colors.transparent,
        border: selected ? null : Border.all(color: CairnColors.borderStrong, width: 1.5),
      ),
      child: selected ? const Icon(Icons.check, size: 13, color: CairnColors.onSage) : null,
    );
  }

  Widget _footer() {
    final n = _selected.length;
    final picks = _selected.values.toList();
    return Container(
      padding: const EdgeInsets.fromLTRB(26, 16, 26, 24),
      decoration: const BoxDecoration(
        color: CairnColors.navBar,
        border: Border(top: BorderSide(color: CairnColors.borderSoft)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (n == 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 14, top: 6),
              child: Text('Tap an app to start its cairn',
                  style: CairnType.mono(11, color: CairnColors.textFaint, letterSpacing: 0.6)),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Wrap(
                spacing: 30,
                alignment: WrapAlignment.center,
                children: [for (final a in picks) _formingCairn(a.label)],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Text('$n cairn${n == 1 ? '' : 's'} forming',
                  style: CairnType.mono(11, color: CairnColors.sage, letterSpacing: 0.6)),
            ),
          ],
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: n == 0 ? null : () => widget.onContinue(picks),
              child: Text(n == 0 ? 'Continue' : 'Continue with $n'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _formingCairn(String name) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        StoneStack(count: 2, minSize: 12, maxSize: 20, width: 30),
        const SizedBox(height: 8),
        SizedBox(
          width: 64,
          child: Text(name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: CairnType.mono(10, color: CairnColors.textSubtle)),
        ),
      ],
    );
  }
}
