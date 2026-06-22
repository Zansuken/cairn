import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/database.dart';
import '../domain/moment_detector.dart';
import '../providers/providers.dart';
import 'main_shell.dart';
import 'moments/moment_modals.dart';
import 'onboarding/onboarding_flow.dart';
import 'permission/permission_screen.dart';

/// Decides between the permission primer and Home, and drives the lazy
/// detection: on every foreground it rechecks permission and (when granted)
/// runs the reconcile + keeps the worker config in sync (PRD §4.3).
class RootGate extends ConsumerStatefulWidget {
  const RootGate({super.key});

  @override
  ConsumerState<RootGate> createState() => _RootGateState();
}

class _RootGateState extends ConsumerState<RootGate> with WidgetsBindingObserver {
  bool _everGranted = false;
  bool _markedComplete = false;
  bool _askedNotifPermission = false;
  // True once the onboarding flow is on screen. It then owns the screen until it
  // sets [AppSettings.onboardingComplete] itself, so the pick-apps step writing
  // the first tracked app mid-flow never yanks the flow over to Home.
  bool _onboardingActive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onForeground());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _onForeground();
  }

  Future<void> _onForeground() async {
    ref.invalidate(permissionStatusProvider);
    // Re-read the battery-exemption status so the Settings row reflects a change
    // the user just made on the system page they were sent to.
    ref.invalidate(batteryExemptProvider);
    try {
      final granted = await ref.read(usageServiceProvider).isUsageAccessGranted();
      if (!granted) return;
      _everGranted = true;
      final repo = ref.read(trackingRepositoryProvider);
      final moments = await repo.recomputeAndDetectMoments(now: DateTime.now());
      await repo.syncWorkerConfig();
      ref.invalidate(homeStateProvider);
      // Yesterday's verdicts may have just been finalized — refresh the recap too
      // so it never shows a stale "unverified" for a day the reconcile just wrote.
      ref.invalidate(dailyRecapProvider);
      await _syncNotifications();

      final settings = await ref.read(databaseProvider).settingsDao.get();
      await _syncSpeedBump(settings);

      // Milestone celebrations honour the user's toggle; slip/freed always show.
      final toShow = settings.milestonesEnabled
          ? moments
          : moments.where((m) => m.kind != MomentKind.milestone).toList();
      if (toShow.isNotEmpty && mounted) {
        await showMomentModals(context, toShow);
      }
    } catch (_) {
      // Detection is best-effort on foreground; the worker is the backstop.
    }
  }

  /// Keep the speed-bump watcher alive. OEMs (notably the HONOR/MTK target) kill
  /// background foreground-services, so re-affirm it on every foreground when the
  /// feature is on. If the overlay permission was revoked meanwhile, stop watching
  /// and turn the setting off honestly so we never poll blindly.
  Future<void> _syncSpeedBump(AppSettingsRow settings) async {
    if (!settings.speedBumpEnabled) return;
    final bridge = ref.read(usageServiceProvider);
    if (await bridge.isOverlayGranted()) {
      await bridge.setSpeedBumpEnabled(true);
      await bridge.startSpeedBump();
    } else {
      await bridge.stopSpeedBump();
      await bridge.setSpeedBumpEnabled(false);
      await ref
          .read(databaseProvider)
          .settingsDao
          .save(const AppSettingsCompanion(speedBumpEnabled: Value(false)));
    }
  }

  /// Keep the single daily-summary notification in line with the user's
  /// settings (requesting the Android 13+ permission once when enabled).
  Future<void> _syncNotifications() async {
    final settings = await ref.read(databaseProvider).settingsDao.get();
    // Don't touch notifications (and never slam the OS permission dialog) until
    // the user has finished onboarding — otherwise the prompt interrupts the
    // first-run flow before they know what Cairn is.
    if (!settings.onboardingComplete) return;
    final notifications = ref.read(notificationServiceProvider);
    if (settings.notificationsEnabled && !_askedNotifPermission) {
      _askedNotifPermission = true;
      await notifications.requestPermission();
    }
    await notifications.syncDailySummary(
      enabled: settings.notificationsEnabled,
      minutes: settings.dailySummaryMinutes,
    );
  }

  /// Pre-flag installs that already track apps shouldn't be sent through
  /// onboarding — flip the flag once so the gate is stable thereafter.
  void _markCompleteOnce() {
    if (_markedComplete) return;
    _markedComplete = true;
    final db = ref.read(databaseProvider);
    db.settingsDao.save(const AppSettingsCompanion(onboardingComplete: Value(true)));
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    return settings.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => _permissionGate(),
      data: (s) {
        if (s.onboardingComplete) {
          _onboardingActive = false;
          return _permissionGate();
        }
        final trackedAsync = ref.watch(trackedAppsProvider);
        // Wait for the real tracked list before deciding, so an existing user
        // (flag not yet set, list still loading) never flashes onboarding.
        if (!trackedAsync.hasValue) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final tracked = trackedAsync.value!;
        // Once onboarding is showing it owns the screen until it completes. Its
        // pick-apps step writes the first tracked app, so a non-empty list while
        // onboarding is active must NOT be read as "skip onboarding" — that would
        // unmount the flow before the Streak guard / All set steps can run.
        if (_onboardingActive || tracked.isEmpty) {
          _onboardingActive = true;
          return const OnboardingFlow();
        }
        // Pre-flag install that already tracks apps (an upgrade): never send it
        // through onboarding — flip the flag once so the gate is stable.
        WidgetsBinding.instance.addPostFrameCallback((_) => _markCompleteOnce());
        return _permissionGate();
      },
    );
  }

  Widget _permissionGate() {
    final perm = ref.watch(permissionStatusProvider);
    return perm.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => const PermissionScreen(),
      data: (granted) => granted ? const MainShell() : PermissionScreen(lost: _everGranted),
    );
  }
}
