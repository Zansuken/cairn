import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/cairn_colors.dart';
import '../../core/theme/cairn_typography.dart';
import '../../domain/model/day_state.dart';
import '../../providers/providers.dart';
import 'app_detail_state.dart';

/// One tracked app up close (PRD §6). Renders the active layout — current run,
/// records, the honest 30-day history — or, once the app is uninstalled, the
/// reserved Freed/summit trophy.
class AppDetailScreen extends ConsumerWidget {
  const AppDetailScreen({super.key, required this.packageId});

  final String packageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(appDetailProvider(packageId));

    return Scaffold(
      backgroundColor: CairnColors.canvas,
      body: SafeArea(
        child: detail.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _error(context, e),
          data: (vm) {
            if (vm == null) {
              // No longer tracked — leave the screen on the next frame.
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) Navigator.of(context).maybePop();
              });
              return const SizedBox.shrink();
            }
            return vm.isFreed ? _FreedView(vm: vm) : _ActiveView(vm: vm);
          },
        ),
      ),
    );
  }

  Widget _error(BuildContext context, Object e) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Couldn’t open this cairn.\n$e', textAlign: TextAlign.center),
        ),
      );
}

// ── Shared chrome ────────────────────────────────────────────────────────────
Widget _backRow(BuildContext context, {String? title, Widget? trailing}) {
  return SizedBox(
    height: 52,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => Navigator.of(context).maybePop(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.chevron_left, color: CairnColors.textDim, size: 26),
                const SizedBox(width: 2),
                Text('Home', style: CairnType.interface(15, FontWeight.w400, color: CairnColors.textDim)),
              ],
            ),
          ),
        ),
        if (title != null)
          Text(title, style: CairnType.interface(16, FontWeight.w600, color: CairnColors.textHi)),
        SizedBox(width: 86, child: Align(alignment: Alignment.centerRight, child: trailing)),
      ],
    ),
  );
}

// ── Active layout ────────────────────────────────────────────────────────────
class _ActiveView extends ConsumerWidget {
  const _ActiveView({required this.vm});
  final AppDetailVm vm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _backRow(
            context,
            title: vm.name,
            trailing: IconButton(
              icon: const Icon(Icons.more_horiz, color: CairnColors.textDim),
              onPressed: () => _confirmStop(context, ref, vm),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(22, 6, 22, 24),
            children: [
              _hero(),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _statTile('Best record', '${vm.bestStreak}', 'days')),
                  const SizedBox(width: 12),
                  Expanded(child: _statTile('Lifetime clean', '${vm.lifetimeClean}', 'days total')),
                ],
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(2, 28, 2, 14),
                child: Text('LAST 30 DAYS',
                    style: TextStyle(
                      fontFamily: CairnType.monoFamily,
                      fontSize: 11,
                      letterSpacing: 1.7,
                      color: CairnColors.textMuted,
                    )),
              ),
              _HistoryGrid(history: vm.history),
              const SizedBox(height: 16),
              _legend(),
              const Padding(
                padding: EdgeInsets.fromLTRB(2, 14, 2, 0),
                child: Text(
                  'Unverified days are never counted clean. If Cairn couldn’t confirm a day, it says so.',
                  style: TextStyle(
                    fontFamily: CairnType.interfaceFamily,
                    fontSize: 12,
                    height: 1.5,
                    color: CairnColors.textFaint,
                  ),
                ),
              ),
              const SizedBox(height: 26),
              OutlinedButton(
                onPressed: () => _rename(context, ref, vm),
                child: const Text('Rename'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => _confirmStop(context, ref, vm),
                style: TextButton.styleFrom(foregroundColor: CairnColors.textSubtle),
                child: Text('Stop tracking ${vm.name}'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _hero() {
    final (dotColor, label) = switch (vm.today) {
      DayState.clean => (CairnColors.sage, 'Still clean today'),
      DayState.slipped => (CairnColors.stoneSand, 'Opened today'),
      DayState.unverified => (CairnColors.textMuted, 'Unverified today'),
    };
    return Column(
      children: [
        Image.asset('assets/cairn_building.png', height: 180, fit: BoxFit.contain),
        const SizedBox(height: 14),
        Text('CURRENT RUN',
            style: CairnType.mono(10, color: CairnColors.sage, letterSpacing: 1.8)),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text('${vm.currentStreak}',
                style: CairnType.interface(64, FontWeight.w600,
                    color: CairnColors.textHi, height: 0.9, letterSpacing: -1.9)),
            const SizedBox(width: 8),
            Text('days', style: CairnType.interface(17, FontWeight.w400, color: CairnColors.textDim)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 7, height: 7, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(label, style: CairnType.interface(14, FontWeight.w400, color: CairnColors.textDim)),
          ],
        ),
      ],
    );
  }

  Widget _statTile(String label, String value, String unit) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
      decoration: BoxDecoration(
        color: CairnColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: CairnColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: CairnType.mono(9, color: CairnColors.textMuted, letterSpacing: 1.3)),
          const SizedBox(height: 6),
          Text(value, style: CairnType.interface(24, FontWeight.w600, color: CairnColors.textHi)),
          const SizedBox(height: 2),
          Text(unit, style: CairnType.interface(12, FontWeight.w400, color: CairnColors.textSubtle)),
        ],
      ),
    );
  }

  Widget _legend() {
    return Wrap(
      spacing: 18,
      runSpacing: 8,
      children: [
        _legendItem(const BoxDecoration(color: CairnColors.sage, shape: BoxShape.circle), 'Clean'),
        _legendItem(
          BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: CairnColors.stoneSand, width: 1.5),
          ),
          'Slipped',
        ),
        _legendItem(
          BoxDecoration(
            color: CairnColors.cairnStage,
            shape: BoxShape.circle,
            border: Border.all(color: CairnColors.border),
          ),
          'Unverified',
        ),
      ],
    );
  }

  Widget _legendItem(BoxDecoration deco, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 11, height: 11, decoration: deco),
        const SizedBox(width: 7),
        Text(label, style: CairnType.interface(12, FontWeight.w400, color: CairnColors.textSubtle)),
      ],
    );
  }
}

// ── Freed / summit layout ────────────────────────────────────────────────────
class _FreedView extends ConsumerWidget {
  const _FreedView({required this.vm});
  final AppDetailVm vm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _backRow(context),
        ),
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(26, 6, 26, 24),
            children: [
              Center(child: Image.asset('assets/cairn_summit.png', height: 252, fit: BoxFit.contain)),
              const SizedBox(height: 8),
              Center(
                child: Text('SUMMITED',
                    style: CairnType.mono(11, color: CairnColors.sage, letterSpacing: 2.4)),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text("You're free.",
                    style: CairnType.interface(44, FontWeight.w600, color: CairnColors.textHi, letterSpacing: -0.9)),
              ),
              const SizedBox(height: 8),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 290),
                  child: Text(
                    'You uninstalled ${vm.name}. The stack is complete. Plant the flag.',
                    textAlign: TextAlign.center,
                    style: CairnType.interface(15, FontWeight.w400, color: CairnColors.textDim, height: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(child: _summitStat('${vm.currentStreak}', 'Final run')),
                  const SizedBox(width: 12),
                  Expanded(child: _summitStat('${vm.lifetimeClean}', 'Lifetime clean')),
                ],
              ),
              if (vm.freedAt != null) ...[
                const SizedBox(height: 18),
                Center(
                  child: Text('Freed on ${_formatDate(vm.freedAt!)}',
                      style: CairnType.mono(11, color: CairnColors.textMuted, letterSpacing: 0.8)),
                ),
              ],
              const SizedBox(height: 30),
              FilledButton(
                onPressed: () => ref.read(sharerProvider).share(_summitShareText(vm)),
                child: const Text('Share your summit'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.of(context).maybePop(),
                style: TextButton.styleFrom(foregroundColor: CairnColors.textSubtle),
                child: const Text('Keep as a marker on my trail'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summitStat(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
      decoration: BoxDecoration(
        color: CairnColors.cairnStage,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: CairnColors.borderSoft),
      ),
      child: Column(
        children: [
          Text(value, style: CairnType.interface(30, FontWeight.w600, color: CairnColors.textHi)),
          const SizedBox(height: 5),
          Text(label.toUpperCase(),
              textAlign: TextAlign.center,
              style: CairnType.mono(9, color: CairnColors.textMuted, letterSpacing: 1.2)),
        ],
      ),
    );
  }
}

// ── The 30-day dot grid ──────────────────────────────────────────────────────
class _HistoryGrid extends StatelessWidget {
  const _HistoryGrid({required this.history});
  final List<DayState> history;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 9,
      crossAxisSpacing: 9,
      children: [
        for (var i = 0; i < history.length; i++)
          _dot(history[i], isToday: i == history.length - 1),
      ],
    );
  }

  Widget _dot(DayState state, {required bool isToday}) {
    final deco = switch (state) {
      DayState.clean => const BoxDecoration(color: CairnColors.sage, shape: BoxShape.circle),
      DayState.slipped => BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: CairnColors.stoneSand, width: 1.5),
        ),
      DayState.unverified => BoxDecoration(
          color: CairnColors.cairnStage,
          shape: BoxShape.circle,
          border: Border.all(color: CairnColors.borderSoft),
        ),
    };
    if (!isToday) return DecoratedBox(decoration: deco);
    // Ring the in-progress day so "today" reads as the live tip of the trail.
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: CairnColors.textHi.withValues(alpha: 0.85), width: 2),
      ),
      child: Padding(padding: const EdgeInsets.all(2), child: DecoratedBox(decoration: deco)),
    );
  }
}

// ── Actions ──────────────────────────────────────────────────────────────────
Future<void> _confirmStop(BuildContext context, WidgetRef ref, AppDetailVm vm) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: CairnColors.surface,
      title: Text('Stop tracking ${vm.name}?',
          style: CairnType.interface(18, FontWeight.w600, color: CairnColors.textHi)),
      content: Text(
        'Your lifetime total and best record are kept. The current run ends.',
        style: CairnType.interface(14, FontWeight.w400, color: CairnColors.textDim, height: 1.45),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          style: TextButton.styleFrom(foregroundColor: CairnColors.textDim),
          child: const Text('Keep tracking'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: TextButton.styleFrom(foregroundColor: CairnColors.textHi),
          child: const Text('Stop'),
        ),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;
  await ref.read(trackingRepositoryProvider).removeApp(vm.packageId);
  if (context.mounted) Navigator.of(context).maybePop();
}

/// Rename the cairn's display name. Streaks and history are keyed by packageId,
/// so a rename only changes the label (shown here and on the speed-bump overlay).
Future<void> _rename(BuildContext context, WidgetRef ref, AppDetailVm vm) async {
  final next = await showDialog<String>(
    context: context,
    builder: (ctx) => _RenameDialog(initial: vm.name),
  );
  if (next == null || next.isEmpty || next == vm.name) return;
  await ref.read(trackingRepositoryProvider).renameApp(vm.packageId, next);
}

/// A StatefulWidget so the [TextEditingController] is disposed only once the
/// dialog is gone (disposing it inline right after the route pops crashes the
/// closing-frame rebuild).
class _RenameDialog extends StatefulWidget {
  const _RenameDialog({required this.initial});

  final String initial;

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final TextEditingController _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.of(context).pop(_controller.text.trim());

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: CairnColors.surface,
      title: Text('Rename',
          style: CairnType.interface(18, FontWeight.w600, color: CairnColors.textHi)),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        style: CairnType.interface(16, FontWeight.w400, color: CairnColors.textHi),
        decoration: const InputDecoration(hintText: 'Display name'),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(foregroundColor: CairnColors.textDim),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _submit,
          style: TextButton.styleFrom(foregroundColor: CairnColors.textHi),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

/// The recap handed to the share sheet when a cairn is summited. Plain text so
/// it reads well in any target app; no link, so nothing of the user's leaves
/// beyond what they choose to send.
String _summitShareText(AppDetailVm vm) =>
    'I summited ${vm.name} with Cairn. ${vm.lifetimeClean} clean days total, '
    'and a ${vm.currentStreak}-day final run.';

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
String _formatDate(DateTime d) => '${_months[d.month - 1]} ${d.day}, ${d.year}';
