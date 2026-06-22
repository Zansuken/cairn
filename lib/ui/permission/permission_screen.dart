import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/cairn_colors.dart';
import '../../core/theme/cairn_typography.dart';
import '../../providers/providers.dart';

/// Usage Access primer — the make-or-break ask (PRD §3, screen-prompts §5/§12).
/// Warm, plain-language, privacy front-and-centre. Renders the first-run primer
/// or, when [lost] is set, the "tracking paused / re-enable" recovery.
class PermissionScreen extends ConsumerStatefulWidget {
  const PermissionScreen({super.key, this.lost = false});

  /// True when access was previously granted and has since been revoked.
  final bool lost;

  @override
  ConsumerState<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends ConsumerState<PermissionScreen> {
  bool _whyOpen = false;

  void _grant() => ref.read(usageServiceProvider).openUsageAccessSettings();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CairnColors.canvas,
      body: SafeArea(
        child: widget.lost ? _lost() : _primer(),
      ),
    );
  }

  // ── First-run primer ───────────────────────────────────────────────────────
  Widget _primer() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(30, 6, 30, 8),
            children: [
              _mascot(172, glow: 230),
              Text(
                'To count your clean days, Cairn needs Usage Access.',
                style: CairnType.interface(28, FontWeight.w600, color: CairnColors.textHi, height: 1.22, letterSpacing: -0.5),
              ),
              const SizedBox(height: 14),
              _rich(
                const [
                  _Span('It needs to see '),
                  _Span('which', hi: true),
                  _Span(' apps you open, only to mark the days you stayed away. '),
                  _Span('This never leaves your phone.', hi: true),
                ],
                size: 16,
              ),
              const SizedBox(height: 22),
              _bullet('Counts only whether an app was opened, never what you do in it.'),
              _bullet('Stays on this device. No servers, no account, no sign-in.'),
              _bullet('Open source — you can read exactly what it checks.'),
              const SizedBox(height: 22),
              _whyExpandable(),
            ],
          ),
        ),
        _pinnedGrant('Opens your phone’s Settings · revoke anytime'),
      ],
    );
  }

  // ── Permission lost / recovery ─────────────────────────────────────────────
  Widget _lost() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(30, 6, 30, 8),
            children: [
              _mascot(158, glow: 210, opacity: 0.94),
              Text('TRACKING PAUSED', style: CairnType.mono(10, color: CairnColors.textDim, letterSpacing: 2)),
              const SizedBox(height: 12),
              Text(
                'Cairn lost Usage Access.',
                style: CairnType.interface(27, FontWeight.w600, color: CairnColors.textHi, height: 1.2, letterSpacing: -0.5),
              ),
              const SizedBox(height: 12),
              _rich(
                const [
                  _Span("Without it, Cairn can’t confirm whether you opened an app. Rather than guess, it marks those days "),
                  _Span('unverified', hi: true),
                  _Span('. They’re never counted clean.'),
                ],
                size: 15,
              ),
              const SizedBox(height: 22),
              _unverifiedCard(),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sageDot(),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      'Your streaks, best records, and lifetime trail are all safe. Re-enable access and Cairn picks up right where it left off.',
                      style: CairnType.interface(14, FontWeight.w400, color: CairnColors.textDim, height: 1.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        _pinnedGrant('Opens your phone’s Settings', label: 'Re-enable access'),
      ],
    );
  }

  // ── Pieces ─────────────────────────────────────────────────────────────────
  Widget _mascot(double h, {required double glow, double opacity = 1}) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: SizedBox(
        height: h + 16,
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: glow,
                height: glow,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [CairnColors.sage.withValues(alpha: 0.13), CairnColors.sage.withValues(alpha: 0)],
                    stops: const [0, 0.68],
                  ),
                ),
              ),
              Opacity(opacity: opacity, child: Image.asset('assets/cairn_building.png', height: h, fit: BoxFit.contain)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sageDot(),
          const SizedBox(width: 11),
          Expanded(
            child: Text(text, style: CairnType.interface(14, FontWeight.w400, color: CairnColors.textDim, height: 1.45)),
          ),
        ],
      ),
    );
  }

  Widget _sageDot() => Container(
        margin: const EdgeInsets.only(top: 6),
        width: 7,
        height: 7,
        decoration: const BoxDecoration(color: CairnColors.sage, shape: BoxShape.circle),
      );

  Widget _whyExpandable() {
    return Container(
      decoration: BoxDecoration(
        color: CairnColors.cairnStage,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _whyOpen ? CairnColors.sage.withValues(alpha: 0.18) : CairnColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => _whyOpen = !_whyOpen),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Why does Cairn need this?',
                      style: CairnType.interface(14, FontWeight.w500,
                          color: _whyOpen ? CairnColors.textHi : CairnColors.textDim)),
                  Icon(_whyOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 18, color: _whyOpen ? CairnColors.sage : CairnColors.textMuted),
                ],
              ),
            ),
          ),
          if (_whyOpen)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _whySection('What it reads',
                      'Android reports when an app was last used. That’s the single signal Cairn checks to decide if a day was clean.'),
                  const SizedBox(height: 16),
                  _whySection('What it never sees',
                      'Not your messages, your activity inside an app, your location, or your contacts. None of it.'),
                  const SizedBox(height: 16),
                  _whySection('Where it lives',
                      'All counting happens on your device. Nothing is uploaded, because there’s no account to upload it to.'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _whySection(String label, String body) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: CairnType.mono(10, color: CairnColors.sage, letterSpacing: 1.2)),
        const SizedBox(height: 5),
        Text(body, style: CairnType.interface(14, FontWeight.w400, color: CairnColors.textDim, height: 1.5)),
      ],
    );
  }

  Widget _unverifiedCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: CairnColors.cairnStage,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: CairnColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('SINCE ACCESS WAS LOST', style: CairnType.mono(10, color: CairnColors.textMuted, letterSpacing: 1.4)),
              Text('2 days unverified', style: CairnType.mono(10, color: CairnColors.textDim, letterSpacing: 0.4)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var i = 0; i < 4; i++) ...[
                const _MiniDot(clean: true),
                const SizedBox(width: 9),
              ],
              const _MiniDot(clean: false),
              const SizedBox(width: 9),
              const _MiniDot(clean: false),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _legendRow(true, 'clean'),
                  const SizedBox(height: 3),
                  _legendRow(false, 'unverified'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendRow(bool clean, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MiniDot(clean: clean, size: 9),
        const SizedBox(width: 6),
        Text(label, style: CairnType.interface(11, FontWeight.w400, color: CairnColors.textSubtle)),
      ],
    );
  }

  Widget _pinnedGrant(String caption, {String label = 'Grant access'}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(30, 14, 30, 24),
      decoration: const BoxDecoration(
        color: CairnColors.canvas,
        border: Border(top: BorderSide(color: CairnColors.borderSoft)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: _grant, child: Text(label)),
          ),
          const SizedBox(height: 11),
          Text(caption, style: CairnType.mono(11, color: CairnColors.textFaint, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _rich(List<_Span> spans, {required double size}) {
    return Text.rich(
      TextSpan(
        children: [
          for (final s in spans)
            TextSpan(
              text: s.text,
              style: CairnType.interface(size, FontWeight.w400,
                  color: s.hi ? CairnColors.textHi : CairnColors.textDim, height: 1.55),
            ),
        ],
      ),
    );
  }
}

class _Span {
  const _Span(this.text, {this.hi = false});
  final String text;
  final bool hi;
}

class _MiniDot extends StatelessWidget {
  const _MiniDot({required this.clean, this.size = 16});
  final bool clean;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: clean
          ? const BoxDecoration(color: CairnColors.sage, shape: BoxShape.circle)
          : BoxDecoration(
              color: CairnColors.cairnStage,
              shape: BoxShape.circle,
              border: Border.all(color: CairnColors.borderStrong, width: 1, style: BorderStyle.solid),
            ),
    );
  }
}
