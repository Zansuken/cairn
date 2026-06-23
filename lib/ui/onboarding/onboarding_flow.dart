import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/cairn_colors.dart';
import '../../core/theme/cairn_typography.dart';
import '../../data/db/database.dart';
import '../../platform/oem_support.dart';
import '../../platform/usage_service.dart';
import '../../providers/providers.dart';
import '../permission/permission_screen.dart';
import '../speedbump/keep_alive_primer.dart';
import '../speedbump/streak_guard_actions.dart';
import '../speedbump/streak_guard_primer.dart';
import '../widgets/stone_stack.dart';
import 'all_set_screen.dart';
import 'pick_apps_screen.dart';

enum _Step { welcome1, welcome2, permission, pick, streakGuard, keepAlive, allSet }

/// First-run flow (screen-prompts §4–7): pitch → how it works → permission →
/// pick apps → all set. Marking [AppSettings.onboardingComplete] true on finish
/// is what RootGate watches to swap over to Home.
class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> with WidgetsBindingObserver {
  _Step _step = _Step.welcome1;
  List<String> _trackedNames = const [];

  // Streak-guard step: waiting for the user to return from the overlay-permission
  // page, and whether they came back without granting it.
  bool _awaitingOverlay = false;
  bool _overlayDenied = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    _maybeAdvancePermission();
    _maybeFinishStreakGuard();
  }

  Future<void> _maybeAdvancePermission() async {
    if (_step != _Step.permission) return;
    final granted = await ref.read(usageServiceProvider).isUsageAccessGranted();
    if (granted && mounted && _step == _Step.permission) {
      setState(() => _step = _Step.pick);
    }
  }

  void _goTo(_Step step) {
    setState(() => _step = step);
    if (step == _Step.permission) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAdvancePermission());
    }
  }

  Future<void> _confirmPicks(List<InstalledApp> apps) async {
    final repo = ref.read(trackingRepositoryProvider);
    final now = DateTime.now();
    for (final a in apps) {
      await repo.addApp(packageId: a.packageId, displayName: a.label, now: now);
    }
    if (!mounted) return;
    setState(() {
      _trackedNames = [for (final a in apps) a.label];
      _step = _Step.streakGuard;
    });
  }

  // ── Streak guard (default-on onboarding step) ───────────────────────────────
  Future<void> _enableStreakGuardFromOnboarding() async {
    final bridge = ref.read(usageServiceProvider);
    if (await bridge.isOverlayGranted()) {
      await _finishStreakGuardEnable();
    } else {
      if (mounted) {
        setState(() {
          _awaitingOverlay = true;
          _overlayDenied = false;
        });
      }
      await bridge.openOverlaySettings();
    }
  }

  /// Called on resume after the user returns from the overlay-permission page.
  Future<void> _maybeFinishStreakGuard() async {
    if (_step != _Step.streakGuard || !_awaitingOverlay) return;
    if (await ref.read(usageServiceProvider).isOverlayGranted()) {
      await _finishStreakGuardEnable();
    } else if (mounted) {
      setState(() {
        _awaitingOverlay = false;
        _overlayDenied = true;
      });
    }
  }

  Future<void> _finishStreakGuardEnable() async {
    final bridge = ref.read(usageServiceProvider);
    await enableStreakGuard(ref);
    if (!await bridge.isIgnoringBatteryOptimizations()) {
      await bridge.requestIgnoreBatteryOptimizations();
    }
    // On phones that aggressively freeze background apps (HONOR/Huawei/Xiaomi/...),
    // the battery exemption is not enough — the watcher is frozen seconds after
    // Cairn is backgrounded. Send the user to the OEM app-launch whitelist first.
    final needsKeepAlive = isAggressiveOem(await bridge.deviceManufacturer());
    if (mounted) setState(() => _step = needsKeepAlive ? _Step.keepAlive : _Step.allSet);
  }

  Future<void> _finish() async {
    final db = ref.read(databaseProvider);
    await db.settingsDao.save(const AppSettingsCompanion(onboardingComplete: Value(true)));
    try {
      await ref.read(trackingRepositoryProvider).recompute(now: DateTime.now());
    } catch (_) {
      // Best-effort first compute; the foreground/worker path will catch up.
    }
    ref.invalidate(homeStateProvider);
    // RootGate watches settings → flips to the Home/permission gate automatically.
  }

  @override
  Widget build(BuildContext context) {
    return switch (_step) {
      _Step.welcome1 => _welcome1(),
      _Step.welcome2 => _welcome2(),
      _Step.permission => const PermissionScreen(),
      _Step.pick => PickAppsScreen(onContinue: _confirmPicks),
      _Step.streakGuard => StreakGuardPrimer(
          onTurnOn: _enableStreakGuardFromOnboarding,
          onSkip: () => setState(() => _step = _Step.allSet),
          needsPermissionHint: _overlayDenied,
        ),
      _Step.keepAlive => KeepAlivePrimer(
          onOpenSettings: () => ref.read(usageServiceProvider).openProtectedAppsSettings(),
          onContinue: () => setState(() => _step = _Step.allSet),
        ),
      _Step.allSet => AllSetScreen(trackedNames: _trackedNames, onStart: _finish),
    };
  }

  // ── Welcome slides ─────────────────────────────────────────────────────────
  Widget _slideScaffold({required Widget art, required Widget copy, required int active}) {
    return Scaffold(
      backgroundColor: CairnColors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 8, 32, 28),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Text('CAIRN', style: CairnType.mono(12, color: CairnColors.textMuted, letterSpacing: 3.4)),
              Expanded(child: Center(child: art)),
              copy,
              const SizedBox(height: 30),
              _dots(active),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _goTo(active == 0 ? _Step.welcome2 : _Step.permission),
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _welcome1() {
    return _slideScaffold(
      active: 0,
      art: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [CairnColors.sage.withValues(alpha: 0.14), CairnColors.sage.withValues(alpha: 0)],
                stops: const [0, 0.68],
              ),
            ),
          ),
          Image.asset('assets/cairn_building.png', height: 236, fit: BoxFit.contain),
        ],
      ),
      copy: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(children: [
              TextSpan(text: 'A streak for the days you ', style: _h(33)),
              TextSpan(text: 'don’t', style: _h(33, color: CairnColors.sage)),
              TextSpan(text: ' open the app you can’t quit.', style: _h(33)),
            ]),
          ),
          const SizedBox(height: 16),
          Text(
            'Meet your cairn. It gains a stone for every clean day you stay away. Quiet, steady progress.',
            style: CairnType.interface(16, FontWeight.w400, color: CairnColors.textDim, height: 1.55),
          ),
        ],
      ),
    );
  }

  Widget _welcome2() {
    return _slideScaffold(
      active: 1,
      art: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _formingDay(1, 'day 1'),
          const SizedBox(width: 22),
          _formingDay(2, 'day 2'),
          const SizedBox(width: 22),
          _formingDay(3, 'day 3', highlight: true),
        ],
      ),
      copy: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Don’t open it all day, and that day adds a stone.', style: _h(30)),
          const SizedBox(height: 16),
          Text(
            'Cairn just notices the days you stay away. No blocking, no willpower battles, and everything stays on your phone.',
            style: CairnType.interface(16, FontWeight.w400, color: CairnColors.textDim, height: 1.55),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip('On-device', accent: true),
              _chip('No blocking'),
              _chip('No accounts'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _formingDay(int count, String label, {bool highlight = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        StoneStack(count: count, minSize: 16, maxSize: 26, width: 40, boxHeight: 80),
        const SizedBox(height: 12),
        Text(label,
            style: CairnType.mono(10, color: highlight ? CairnColors.sage : CairnColors.textFaint)),
      ],
    );
  }

  Widget _chip(String label, {bool accent = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent ? CairnColors.sage.withValues(alpha: 0.3) : CairnColors.border),
      ),
      child: Text(label.toUpperCase(),
          style: CairnType.mono(10, color: accent ? CairnColors.sage : CairnColors.textDim, letterSpacing: 1.2)),
    );
  }

  Widget _dots(int active) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < 2; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == active ? 22 : 6,
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: i == active ? CairnColors.sage : CairnColors.textHi.withValues(alpha: 0.18),
            ),
          ),
      ],
    );
  }

  TextStyle _h(double size, {Color? color}) =>
      CairnType.interface(size, FontWeight.w600, color: color ?? CairnColors.textHi, height: 1.2, letterSpacing: -0.6);
}
