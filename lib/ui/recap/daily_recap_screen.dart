import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/cairn_colors.dart';
import '../../core/theme/cairn_typography.dart';
import '../../domain/daily_recap.dart';
import '../../providers/providers.dart';

/// Morning daily recap (screen-prompts §15): a calm summary of how each tracked
/// cairn fared yesterday — a headline, the per-app rows, and the honest lifetime
/// counts. No alarm colours; sage is the single accent.
class DailyRecapScreen extends ConsumerWidget {
  const DailyRecapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recap = ref.watch(dailyRecapProvider);

    return Scaffold(
      backgroundColor: CairnColors.canvas,
      body: SafeArea(
        child: recap.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Couldn’t load your recap.\n$e',
                textAlign: TextAlign.center,
                style: CairnType.interface(15, FontWeight.w400, color: CairnColors.textDim),
              ),
            ),
          ),
          data: (recap) => _RecapView(recap: recap),
        ),
      ),
    );
  }
}

class _RecapView extends StatelessWidget {
  const _RecapView({required this.recap});

  final DailyRecap recap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(26, 8, 26, 18),
            children: [
              const _Header(),
              const SizedBox(height: 22),
              _Headline(headline: recap.headline),
              const SizedBox(height: 12),
              Text(
                recap.subtitle,
                style: CairnType.interface(15, FontWeight.w400, color: CairnColors.textDim, height: 1.55),
              ),
              if (recap.isEmpty)
                const _EmptyState()
              else ...[
                const SizedBox(height: 18),
                _RowsList(rows: recap.rows),
                const SizedBox(height: 24),
                _LifetimeStrip(lifetimeClean: recap.lifetimeClean, perfectRun: recap.perfectRun),
              ],
            ],
          ),
        ),
        const _PinnedAction(),
      ],
    );
  }
}

// ── Header (greeting + subtle mascot) ────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header();

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _yesterday() {
    final d = DateTime.now().subtract(const Duration(days: 1));
    // DateTime.weekday is 1 (Mon) … 7 (Sun).
    return '${_weekdays[d.weekday - 1]}, ${_months[d.month - 1]} ${d.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('GOOD MORNING',
                    style: CairnType.mono(11, color: CairnColors.textMuted, letterSpacing: 1.76)),
                const SizedBox(height: 5),
                Text('Yesterday · ${_yesterday()}',
                    style: CairnType.interface(15, FontWeight.w400, color: CairnColors.textDim)),
              ],
            ),
          ),
          Opacity(
            opacity: 0.9,
            child: Image.asset('assets/cairn_building.png', height: 70, fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }
}

// ── Headline ─────────────────────────────────────────────────────────────────
class _Headline extends StatelessWidget {
  const _Headline({required this.headline});

  final String headline;

  /// Matches a leading "N of M" count so it can be tinted sage, e.g.
  /// "3 of 4 cairns grew yesterday." → ["3 of 4", " cairns grew yesterday."].
  static final _countPrefix = RegExp(r'^(\d+ of \d+)(.*)$');

  @override
  Widget build(BuildContext context) {
    final base = CairnType.interface(32, FontWeight.w600,
        color: CairnColors.textHi, height: 1.15, letterSpacing: -0.64);

    final match = _countPrefix.firstMatch(headline);
    if (match == null) {
      return Text(headline, style: base);
    }
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          TextSpan(text: match.group(1), style: base.copyWith(color: CairnColors.sage)),
          TextSpan(text: match.group(2)),
        ],
      ),
    );
  }
}

// ── Rows ─────────────────────────────────────────────────────────────────────
class _RowsList extends StatelessWidget {
  const _RowsList({required this.rows});

  final List<RecapRow> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < rows.length; i++)
          _RecapRowTile(row: rows[i], last: i == rows.length - 1),
      ],
    );
  }
}

class _RecapRowTile extends StatelessWidget {
  const _RecapRowTile({required this.row, required this.last});

  final RecapRow row;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 2),
      decoration: BoxDecoration(
        border: Border(
          bottom: last ? BorderSide.none : const BorderSide(color: CairnColors.borderSoft),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: CairnColors.raised,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Text(row.monogram,
                style: CairnType.mono(13, color: CairnColors.textDim)),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Text(row.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CairnType.interface(16, FontWeight.w600, color: CairnColors.textHi)),
          ),
          const SizedBox(width: 13),
          _StatusPill(state: row.state),
          const SizedBox(width: 13),
          SizedBox(
            width: 56,
            child: Text(
              _trailing(row),
              textAlign: TextAlign.right,
              style: _trailingStyle(row.state),
            ),
          ),
        ],
      ),
    );
  }

  String _trailing(RecapRow row) {
    return switch (row.state) {
      RecapState.clean => 'Day ${row.dayNumber}',
      RecapState.slipped => 'New stack',
      RecapState.unverified => '—',
    };
  }

  TextStyle _trailingStyle(RecapState state) {
    return switch (state) {
      RecapState.clean =>
        CairnType.interface(15, FontWeight.w400, color: CairnColors.textDim),
      RecapState.slipped =>
        CairnType.interface(13, FontWeight.w400, color: CairnColors.textSubtle),
      RecapState.unverified =>
        CairnType.interface(13, FontWeight.w400, color: CairnColors.textSubtle),
    };
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.state});

  final RecapState state;

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case RecapState.clean:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: CairnColors.sage,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text('CLEAN',
              style: CairnType.mono(10, color: CairnColors.onSage, letterSpacing: 0.8)),
        );
      case RecapState.slipped:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: CairnColors.stoneSand.withValues(alpha: 0.5)),
          ),
          child: Text('RESET',
              style: CairnType.mono(10, color: CairnColors.stoneSand, letterSpacing: 0.8)),
        );
      case RecapState.unverified:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: CairnColors.borderSoft),
          ),
          child: Text('UNVERIFIED',
              style: CairnType.mono(10, color: CairnColors.textMuted, letterSpacing: 0.8)),
        );
    }
  }
}

// ── Lifetime strip ───────────────────────────────────────────────────────────
class _LifetimeStrip extends StatelessWidget {
  const _LifetimeStrip({required this.lifetimeClean, required this.perfectRun});

  final int lifetimeClean;
  final int perfectRun;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: CairnColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: CairnColors.borderSoft),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _metric(
              label: 'LIFETIME CLEAN',
              value: '$lifetimeClean',
              unit: 'days',
              alignEnd: false,
            ),
            Container(width: 1, color: CairnColors.textHi.withValues(alpha: 0.08)),
            _metric(
              label: 'PERFECT-DAY RUN',
              value: '$perfectRun',
              unit: perfectRun == 0 ? 'restarting' : 'days',
              alignEnd: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _metric({
    required String label,
    required String value,
    required String unit,
    required bool alignEnd,
  }) {
    final column = Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label, style: CairnType.mono(10, color: CairnColors.textMuted, letterSpacing: 1.4)),
        const SizedBox(height: 3),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(value,
                style: CairnType.interface(30, FontWeight.w600,
                    color: CairnColors.textHi, height: 1, letterSpacing: -0.6)),
            const SizedBox(width: 7),
            Flexible(
              child: Text(unit,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CairnType.interface(13, FontWeight.w400, color: CairnColors.textDim)),
            ),
          ],
        ),
      ],
    );
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(left: alignEnd ? 20 : 0, right: alignEnd ? 0 : 20),
        child: column,
      ),
    );
  }
}

// ── Empty state ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Center(
        child: Text('No cairns tracked yet.',
            style: CairnType.interface(15, FontWeight.w400, color: CairnColors.textMuted)),
      ),
    );
  }
}

// ── Pinned bottom action ─────────────────────────────────────────────────────
class _PinnedAction extends StatelessWidget {
  const _PinnedAction();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(26, 14, 26, 14),
      decoration: const BoxDecoration(
        color: CairnColors.canvas,
        border: Border(top: BorderSide(color: CairnColors.borderSoft)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('Done'),
            ),
          ),
          const SizedBox(height: 11),
          Text("That's the whole recap. See you tomorrow.",
              style: CairnType.mono(11, color: CairnColors.textFaint, letterSpacing: 0.66)),
        ],
      ),
    );
  }
}
