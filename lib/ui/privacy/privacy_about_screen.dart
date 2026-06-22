import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/cairn_colors.dart';
import '../../core/theme/cairn_typography.dart';
import '../../providers/providers.dart';

/// The public source repository. The "Source code" link opens it in the browser.
const _repoUrl = 'https://github.com/Zansuken/cairn';

/// The tip page. "Leave a tip" opens it in the browser; the supporter picks the
/// amount there (Ko-fi has no URL way to preset one, and nothing leaves Cairn).
const _kofiUrl = 'https://ko-fi.com/zansuken';

/// Privacy / About (screen-prompts). The plain-language promise that nothing
/// leaves the device, the trust bullets, links to the source, and a no-strings
/// "support" tip card. The outbound links open in the browser; Cairn itself
/// sends nothing.
class PrivacyAboutScreen extends ConsumerWidget {
  const PrivacyAboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: CairnColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            _backRow(context),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(26, 4, 26, 24),
                children: [
                  _header(),
                  Text(
                    'Your usage data, and which apps you track, never leave this phone.',
                    style: CairnType.interface(25, FontWeight.w600,
                        color: CairnColors.textHi, height: 1.25, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    "Cairn counts your clean days on your device. There's no account "
                    'to make and no server to sync to, so nothing about you ever gets '
                    'uploaded.',
                    style: CairnType.interface(15, FontWeight.w400,
                        color: CairnColors.textDim, height: 1.6),
                  ),
                  const SizedBox(height: 24),
                  _bullet('No account, no sign-in.', ' Cairn never asks who you are.'),
                  const SizedBox(height: 14),
                  _bullet('No servers.', " There's nowhere for your data to be sent."),
                  const SizedBox(height: 14),
                  _bullet('Open source.', ' Anyone can read exactly what it does.'),
                  _sectionLabel('SEE FOR YOURSELF'),
                  _linksCard(context, ref),
                  _sectionLabel('SUPPORT'),
                  _supportCard(context, ref),
                  _footer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Chrome ──────────────────────────────────────────────────────────────
  Widget _backRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 52,
        child: Row(
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
                    Text('Settings',
                        style: CairnType.interface(15, FontWeight.w400, color: CairnColors.textDim)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header (icon + wordmark) ────────────────────────────────────────────
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 6, 0, 22),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset('assets/cairn_icon.png', width: 60, height: 60, fit: BoxFit.cover),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cairn',
                  style: CairnType.interface(21, FontWeight.w600,
                      color: CairnColors.textHi, letterSpacing: -0.2)),
              const SizedBox(height: 3),
              Text('v1.0 · open source',
                  style: CairnType.mono(11, color: CairnColors.textSubtle)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Trust bullet (sage dot + rich text) ─────────────────────────────────
  Widget _bullet(String lead, String rest) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 7,
          height: 7,
          decoration: const BoxDecoration(color: CairnColors.sage, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: lead,
                  style: CairnType.interface(14, FontWeight.w500,
                      color: CairnColors.textHi, height: 1.5),
                ),
                TextSpan(
                  text: rest,
                  style: CairnType.interface(14, FontWeight.w400,
                      color: CairnColors.textDim, height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Mono section label ──────────────────────────────────────────────────
  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 28, 6, 10),
      child: Text(text, style: CairnType.mono(11, color: CairnColors.textMuted, letterSpacing: 1.7)),
    );
  }

  // ── "See for yourself" link card ────────────────────────────────────────
  Widget _linksCard(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: CairnColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: CairnColors.borderSoft),
      ),
      // F-Droid is intentionally omitted until Cairn is actually published there
      // (a dead "coming soon" link reads worse than no link at all).
      child: Column(
        children: [
          _linkRow(context, 'Source code', 'github.com/Zansuken/cairn',
              divider: false, onTap: () => ref.read(linkLauncherProvider).open(_repoUrl)),
        ],
      ),
    );
  }

  Widget _linkRow(BuildContext context, String title, String subtitle,
      {required bool divider, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: divider ? const BorderSide(color: CairnColors.borderSoft) : BorderSide.none,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: CairnType.interface(16, FontWeight.w500, color: CairnColors.textHi)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: CairnType.interface(12, FontWeight.w400, color: CairnColors.textSubtle)),
                ],
              ),
            ),
            Text('↗', style: CairnType.interface(14, FontWeight.w400, color: CairnColors.textMuted)),
          ],
        ),
      ),
    );
  }

  // ── "Support" tip card ──────────────────────────────────────────────────
  Widget _supportCard(BuildContext context, WidgetRef ref) {
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(13));
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CairnColors.cairnStage,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: CairnColors.sage.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Free, forever.',
              style: CairnType.interface(17, FontWeight.w600, color: CairnColors.textHi)),
          const SizedBox(height: 8),
          Text(
            'No ads, no subscriptions, nothing locked away. If Cairn helped you, '
            'you can leave a tip. It changes nothing in the app either way.',
            style: CairnType.interface(14, FontWeight.w400,
                color: CairnColors.textDim, height: 1.55),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => ref.read(linkLauncherProvider).open(_kofiUrl),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 13),
                minimumSize: Size.zero,
                shape: shape,
              ),
              child: Text('Leave a tip',
                  style: CairnType.interface(15, FontWeight.w600, color: CairnColors.onSage)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Footer ──────────────────────────────────────────────────────────────
  Widget _footer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 30, 0, 24),
      child: Column(
        children: [
          Text('Cairn v1.0 · GPL-3.0',
              style: CairnType.mono(11, color: CairnColors.textFaint, letterSpacing: 1.1)),
          const SizedBox(height: 6),
          Text('Mark the days you stayed away.',
              style: CairnType.mono(10, color: const Color(0xFF3F463D), letterSpacing: 0.6)),
        ],
      ),
    );
  }

}
