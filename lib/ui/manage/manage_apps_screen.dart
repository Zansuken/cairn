import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/curated_apps.dart';
import '../../core/theme/cairn_colors.dart';
import '../../core/theme/cairn_typography.dart';
import '../../domain/model/tracked_app.dart';
import '../../platform/usage_service.dart';
import '../../providers/providers.dart';
import '../app_detail/app_detail_screen.dart';
import '../home/home_state.dart';
import '../widgets/app_icon_tile.dart';

/// Manage apps (screen-prompts §3): the tracked list with remove + an "add"
/// entry point that opens the curated picker. Removing keeps the trail.
class ManageAppsScreen extends ConsumerWidget {
  const ManageAppsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(homeStateProvider);
    // Freed apps are filtered out of the Home view-model, so source the permanent
    // "Summited" trophies straight from the tracked set.
    final freed = ref.watch(trackedAppsProvider).value?.where((a) => a.isFreed).toList() ??
        const <TrackedApp>[];
    return Scaffold(
      backgroundColor: CairnColors.canvas,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _topBar(),
            Expanded(
              child: home.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Couldn’t load.\n$e', textAlign: TextAlign.center)),
                data: (state) => _list(context, ref, state.apps, freed),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 8, 24, 14),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Manage apps',
          style: TextStyle(
            fontFamily: CairnType.interfaceFamily,
            fontSize: 27,
            fontWeight: FontWeight.w600,
            color: CairnColors.textHi,
            letterSpacing: -0.54,
          ),
        ),
      ),
    );
  }

  Widget _list(BuildContext context, WidgetRef ref, List<HomeAppVm> apps, List<TrackedApp> freed) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(22, 6, 22, 24),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 10, 4, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TRACKING NOW', style: CairnType.mono(11, color: CairnColors.textMuted, letterSpacing: 1.7)),
              Text('${apps.length} app${apps.length == 1 ? '' : 's'}',
                  style: CairnType.mono(11, color: CairnColors.textMuted)),
            ],
          ),
        ),
        if (apps.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Text('No apps tracked yet.',
                style: CairnType.interface(14, FontWeight.w400, color: CairnColors.textMuted)),
          )
        else
          for (var i = 0; i < apps.length; i++)
            _trackedRow(context, ref, apps[i], last: i == apps.length - 1),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => _openAddSheet(context, ref),
            child: const Text('+ Add an app'),
          ),
        ),
        const SizedBox(height: 18),
        _guidanceCard(),
        const Padding(
          padding: EdgeInsets.fromLTRB(4, 16, 4, 0),
          child: Text(
            'Removing an app stops tracking but keeps its trail. You can add it back anytime.',
            style: TextStyle(
              fontFamily: CairnType.interfaceFamily,
              fontSize: 12,
              height: 1.5,
              color: CairnColors.textFaint,
            ),
          ),
        ),
        if (freed.isNotEmpty) ...[
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Text('SUMMITED',
                style: CairnType.mono(11, color: CairnColors.textMuted, letterSpacing: 1.7)),
          ),
          for (var i = 0; i < freed.length; i++)
            _summitedRow(context, freed[i], last: i == freed.length - 1),
          const Padding(
            padding: EdgeInsets.fromLTRB(4, 14, 4, 0),
            child: Text(
              'Apps you uninstalled. Their stacks are complete — tap to revisit the summit.',
              style: TextStyle(
                fontFamily: CairnType.interfaceFamily,
                fontSize: 12,
                height: 1.5,
                color: CairnColors.textFaint,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _summitedRow(BuildContext context, TrackedApp app, {required bool last}) {
    final monogram = app.displayName.trim().isEmpty ? '?' : app.displayName.trim()[0].toUpperCase();
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => AppDetailScreen(packageId: app.packageId)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 2),
        decoration: BoxDecoration(
          border: Border(bottom: last ? BorderSide.none : const BorderSide(color: CairnColors.borderSoft)),
        ),
        child: Row(
          children: [
            AppIconTile(monogram: monogram),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(app.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CairnType.interface(16, FontWeight.w600, color: CairnColors.textHi)),
                  const SizedBox(height: 2),
                  Text('Summited · free',
                      style: CairnType.interface(12, FontWeight.w400, color: CairnColors.sage)),
                ],
              ),
            ),
            Text('›',
                style: TextStyle(
                  fontFamily: CairnType.interfaceFamily,
                  fontSize: 16,
                  color: CairnColors.textMuted,
                )),
          ],
        ),
      ),
    );
  }

  Widget _trackedRow(BuildContext context, WidgetRef ref, HomeAppVm app, {required bool last}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 2),
      decoration: BoxDecoration(
        border: Border(bottom: last ? BorderSide.none : const BorderSide(color: CairnColors.borderSoft)),
      ),
      child: Row(
        children: [
          AppIconTile(monogram: app.monogram),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(app.name, style: CairnType.interface(16, FontWeight.w600, color: CairnColors.textHi)),
                const SizedBox(height: 2),
                Text('Day ${app.currentStreak} · ${app.today.label}',
                    style: CairnType.interface(12, FontWeight.w400, color: CairnColors.textSubtle)),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () => _remove(ref, app.packageId),
            style: OutlinedButton.styleFrom(
              foregroundColor: CairnColors.textDim,
              side: const BorderSide(color: CairnColors.borderStrong),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
            child: Text('Remove', style: CairnType.interface(13, FontWeight.w500, color: CairnColors.textDim)),
          ),
        ],
      ),
    );
  }

  Widget _guidanceCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: CairnColors.cairnStage,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CairnColors.borderSoft),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 7,
            height: 7,
            decoration: const BoxDecoration(color: CairnColors.sage, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'Most people start with ', style: CairnType.interface(13, FontWeight.w400, color: CairnColors.textDim, height: 1.5)),
                  TextSpan(text: '1 to 3 apps', style: CairnType.interface(13, FontWeight.w600, color: CairnColors.textHi, height: 1.5)),
                  TextSpan(
                    text: '. There’s no limit, but a shorter list is easier to keep clean.',
                    style: CairnType.interface(13, FontWeight.w400, color: CairnColors.textDim, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _remove(WidgetRef ref, String packageId) async {
    await ref.read(trackingRepositoryProvider).removeApp(packageId);
    ref.invalidate(homeStateProvider);
  }

  void _openAddSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x8C0A0D0B),
      builder: (_) => const _AddAppSheet(),
    );
  }
}

// ── Add-app picker (bottom sheet) ────────────────────────────────────────────
class _AddAppSheet extends ConsumerStatefulWidget {
  const _AddAppSheet();

  @override
  ConsumerState<_AddAppSheet> createState() => _AddAppSheetState();
}

class _AddAppSheetState extends ConsumerState<_AddAppSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final tracked = ref.watch(trackedAppsProvider).value ?? const [];
    final trackedIds = {for (final a in tracked) a.packageId};
    final installed = ref.watch(installedAppsProvider);

    return FractionallySizedBox(
      heightFactor: 0.86,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1C221D),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          border: Border(top: BorderSide(color: CairnColors.border)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 38, height: 4, decoration: BoxDecoration(color: CairnColors.borderStrong, borderRadius: BorderRadius.circular(999))),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Add an app', style: CairnType.interface(19, FontWeight.w600, color: CairnColors.textHi)),
                  TextButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    style: TextButton.styleFrom(foregroundColor: CairnColors.sage),
                    child: Text('Done', style: CairnType.interface(15, FontWeight.w500, color: CairnColors.sage)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 6),
              child: _search(),
            ),
            Expanded(
              child: installed.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Couldn’t list apps.\n$e', textAlign: TextAlign.center)),
                data: (apps) => _candidates(apps, trackedIds),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _search() {
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

  Widget _candidates(List<InstalledApp> apps, Set<String> trackedIds) {
    final q = _query.trim().toLowerCase();
    final list = apps.where((a) {
      if (q.isEmpty) return curatedPackages.contains(a.packageId) || trackedIds.contains(a.packageId);
      return a.label.toLowerCase().contains(q) || a.packageId.toLowerCase().contains(q);
    }).toList()
      ..sort((a, b) {
        final ca = curatedPackages.contains(a.packageId) ? 0 : 1;
        final cb = curatedPackages.contains(b.packageId) ? 0 : 1;
        if (ca != cb) return ca - cb;
        return a.label.toLowerCase().compareTo(b.label.toLowerCase());
      });

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(2, 0, 2, 10),
          child: Text(q.isEmpty ? 'SUGGESTIONS' : 'RESULTS',
              style: CairnType.mono(11, color: CairnColors.textMuted, letterSpacing: 1.6)),
        ),
        for (final a in list) _candidateRow(a, tracked: trackedIds.contains(a.packageId)),
        if (list.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text('No matches.', style: CairnType.interface(14, FontWeight.w400, color: CairnColors.textMuted)),
          ),
        const SizedBox(height: 20),
        _sheetGuidance(),
      ],
    );
  }

  Widget _sheetGuidance() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: CairnColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CairnColors.borderSoft),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 7,
            height: 7,
            decoration: const BoxDecoration(color: CairnColors.sage, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'Most people start with ', style: CairnType.interface(13, FontWeight.w400, color: CairnColors.textDim, height: 1.5)),
                  TextSpan(text: '1 to 3 apps', style: CairnType.interface(13, FontWeight.w600, color: CairnColors.textHi, height: 1.5)),
                  TextSpan(
                    text: '. Pick the one you most want to master. You can always add more.',
                    style: CairnType.interface(13, FontWeight.w400, color: CairnColors.textDim, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _candidateRow(InstalledApp app, {required bool tracked}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: CairnColors.borderSoft))),
      child: Row(
        children: [
          _icon(app),
          const SizedBox(width: 12),
          Expanded(
            child: Text(app.label,
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: CairnType.interface(16, FontWeight.w600, color: CairnColors.textHi)),
          ),
          if (tracked)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(color: CairnColors.sage, shape: BoxShape.circle),
                  child: const Icon(Icons.check, size: 11, color: CairnColors.onSage),
                ),
                const SizedBox(width: 6),
                Text('TRACKING', style: CairnType.mono(10, color: CairnColors.sage, letterSpacing: 1)),
              ],
            )
          else
            FilledButton(
              onPressed: () => _add(app),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              ),
              child: Text('Add', style: CairnType.interface(13, FontWeight.w600, color: CairnColors.onSage)),
            ),
        ],
      ),
    );
  }

  Widget _icon(InstalledApp app) {
    final Uint8List? png = app.iconPng;
    if (png != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Image.memory(png, width: 38, height: 38, fit: BoxFit.cover, gaplessPlayback: true),
      );
    }
    return AppIconTile(monogram: app.label.isEmpty ? '?' : app.label[0].toUpperCase(), size: 38);
  }

  Future<void> _add(InstalledApp app) async {
    await ref.read(trackingRepositoryProvider).addApp(
          packageId: app.packageId,
          displayName: app.label,
          now: DateTime.now(),
        );
    ref.invalidate(homeStateProvider);
  }
}
