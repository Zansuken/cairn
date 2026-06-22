import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/cairn_colors.dart';
import '../../core/theme/cairn_typography.dart';
import '../../data/db/database.dart';
import '../../providers/providers.dart';
import '../privacy/privacy_about_screen.dart';
import '../recap/daily_recap_screen.dart';
import '../speedbump/streak_guard_actions.dart';

/// Manufacturers known to aggressively kill background services / foreground
/// services. Only on these do we surface the "keep running in background" hint,
/// to avoid cluttering stock-Android phones where it is unnecessary.
const _aggressiveOems = {
  'huawei', 'honor', 'xiaomi', 'redmi', 'poco', 'oppo', 'realme',
  'vivo', 'iqoo', 'oneplus', 'meizu', 'samsung', 'tecno', 'infinix',
  'asus', 'lenovo',
};

/// Settings (screen-prompts §16): the quiet control room — your day, the calm
/// notifications, privacy. A bottom-nav destination, so the title carries no
/// back chevron. Every change persists straight to the settings row.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: CairnColors.canvas,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _title(),
            Expanded(
              child: settings.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text('Couldn’t load settings.\n$e', textAlign: TextAlign.center),
                ),
                data: (row) => _body(context, ref, row),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _title() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 8, 24, 14),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Settings',
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

  Widget _body(BuildContext context, WidgetRef ref, AppSettingsRow row) {
    // Reliability rows only matter (and only render) while the guard is on, so
    // we only query the device for them then.
    final guardOn = row.speedBumpEnabled;
    bool? batteryExempt;
    var showProtectedApps = false;
    if (guardOn) {
      batteryExempt = ref.watch(batteryExemptProvider).value;
      showProtectedApps = _aggressiveOems.contains(ref.watch(deviceManufacturerProvider).value ?? '');
    }
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(22, 4, 22, 0),
      children: [
        // ── YOUR DAY ────────────────────────────────────────────────────────
        _sectionLabel('Your day'),
        _card([
          _navRow(
            title: 'Day resets at',
            subtitle: 'A day counts clean after this hour',
            value: _formatHour(row.dayResetHour),
            onTap: () => _pickResetHour(context, ref, row.dayResetHour),
          ),
          _divider(),
          _navRow(
            title: "Yesterday's recap",
            subtitle: 'How each cairn fared',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const DailyRecapScreen()),
            ),
          ),
        ]),

        // ── NOTIFICATIONS ───────────────────────────────────────────────────
        const SizedBox(height: 24),
        _sectionLabel('Notifications'),
        _card([
          _toggleRow(
            title: 'Daily summary',
            subtitle: 'One calm recap each morning',
            value: row.notificationsEnabled,
            onChanged: (v) => _saveAndReschedule(ref, AppSettingsCompanion(notificationsEnabled: Value(v))),
          ),
          _divider(),
          _navRow(
            title: 'Summary time',
            value: _formatMinutes(row.dailySummaryMinutes),
            onTap: () => _pickSummaryTime(context, ref, row.dailySummaryMinutes),
          ),
          _divider(),
          _toggleRow(
            title: 'Milestone moments',
            subtitle: '7, 30, and 100 clean days',
            value: row.milestonesEnabled,
            onChanged: (v) => _save(ref, AppSettingsCompanion(milestonesEnabled: Value(v))),
          ),
        ]),
        const Padding(
          padding: EdgeInsets.fromLTRB(6, 11, 6, 0),
          child: Text(
            "Cairn never sends reminders to come back, and never nags. That's the whole point.",
            style: TextStyle(
              fontFamily: CairnType.interfaceFamily,
              fontSize: 12,
              height: 1.5,
              color: CairnColors.textFaint,
            ),
          ),
        ),

        // ── STREAK GUARD ────────────────────────────────────────────────────
        const SizedBox(height: 24),
        _sectionLabel('Streak guard'),
        _card([
          _toggleRow(
            title: 'Guard my streak',
            subtitle: 'A calm pause before you open a tracked app',
            value: row.speedBumpEnabled,
            onChanged: (v) => _toggleSpeedBump(context, ref, v),
          ),
          if (guardOn) ...[
            _divider(),
            _navRow(
              title: 'Battery optimization',
              subtitle: 'Keep Cairn awake so the guard never misses an open',
              value: batteryExempt == null ? null : (batteryExempt ? 'Allowed' : 'Restricted'),
              valueColor: batteryExempt == true ? CairnColors.sage : CairnColors.textMuted,
              onTap: () => ref.read(usageServiceProvider).requestIgnoreBatteryOptimizations(),
            ),
            if (showProtectedApps) ...[
              _divider(),
              _navRow(
                title: 'Keep running in background',
                subtitle: "Allow auto-start so your phone can't stop the guard",
                onTap: () => ref.read(usageServiceProvider).openProtectedAppsSettings(),
              ),
            ],
          ],
        ]),
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 11, 6, 0),
          child: Text(
            guardOn
                ? 'When you open an app you are keeping a streak on, Cairn shows a calm reminder '
                    'first. You can always open it anyway. It never blocks you. Some phones put '
                    'apps to sleep, so the two settings above keep the guard alive in the background.'
                : 'When you open an app you are keeping a streak on, Cairn shows a calm reminder '
                    'first. You can always open it anyway. It never blocks you.',
            style: const TextStyle(
              fontFamily: CairnType.interfaceFamily,
              fontSize: 12,
              height: 1.5,
              color: CairnColors.textFaint,
            ),
          ),
        ),

        // ── PRIVACY ─────────────────────────────────────────────────────────
        const SizedBox(height: 24),
        _sectionLabel('Privacy'),
        _card([
          // No analytics toggle: Cairn collects nothing, so there's nothing to
          // switch. The honest control is "read exactly what it does".
          _navRow(
            title: 'About & open source',
            subtitle: 'How it works · the code · ways to support',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PrivacyAboutScreen()),
            ),
          ),
        ]),
        const Padding(
          padding: EdgeInsets.fromLTRB(6, 11, 6, 0),
          child: Text(
            'Cairn has no analytics and no servers. Nothing about you ever leaves this phone.',
            style: TextStyle(
              fontFamily: CairnType.interfaceFamily,
              fontSize: 12,
              height: 1.5,
              color: CairnColors.textFaint,
            ),
          ),
        ),

        // ── Footer ──────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 30, 0, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'CAIRN · V${ref.watch(appVersionProvider).value ?? '1.0.0'}',
                textAlign: TextAlign.center,
                style: CairnType.mono(11, color: CairnColors.textFaint, letterSpacing: 1.3),
              ),
              const SizedBox(height: 6),
              Text(
                'Build something by leaving it alone.',
                textAlign: TextAlign.center,
                style: CairnType.mono(10, color: const Color(0xFF3F463D), letterSpacing: 0.6),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Section + card chrome ───────────────────────────────────────────────────
  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 8, 6, 10),
      child: Text(
        text.toUpperCase(),
        style: CairnType.mono(11, color: CairnColors.textMuted, letterSpacing: 1.76),
      ),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: CairnColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: CairnColors.borderSoft),
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() => const Divider(height: 1, thickness: 1, color: CairnColors.borderSoft);

  // ── Rows ────────────────────────────────────────────────────────────────────
  Widget _navRow({
    required String title,
    String? subtitle,
    String? value,
    Color valueColor = CairnColors.sage,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Expanded(child: _labelBlock(title, subtitle)),
            const SizedBox(width: 12),
            if (value != null) ...[
              Text(
                value,
                style: CairnType.interface(15, FontWeight.w500, color: valueColor),
              ),
              const SizedBox(width: 8),
            ],
            const Text(
              '›',
              style: TextStyle(
                fontFamily: CairnType.interfaceFamily,
                fontSize: 15,
                color: CairnColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggleRow({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          Expanded(child: _labelBlock(title, subtitle)),
          const SizedBox(width: 12),
          _CairnSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _labelBlock(String title, String? subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: CairnType.interface(16, FontWeight.w500, color: CairnColors.textHi)),
        if (subtitle != null) ...[
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: CairnType.interface(12, FontWeight.w400, color: CairnColors.textSubtle, height: 1.4),
          ),
        ],
      ],
    );
  }

  // ── Persistence ─────────────────────────────────────────────────────────────
  Future<void> _save(WidgetRef ref, AppSettingsCompanion changes) {
    return ref.read(databaseProvider).settingsDao.save(changes);
  }

  /// Persist a notification-affecting change, then reschedule the daily summary.
  Future<void> _saveAndReschedule(WidgetRef ref, AppSettingsCompanion changes) async {
    await _save(ref, changes);
    final s = await ref.read(databaseProvider).settingsDao.get();
    final notifications = ref.read(notificationServiceProvider);
    if (s.notificationsEnabled) await notifications.requestPermission();
    await notifications.syncDailySummary(
      enabled: s.notificationsEnabled,
      minutes: s.dailySummaryMinutes,
    );
  }

  /// Toggle the Streak guard. Turning it on needs the "draw over other apps"
  /// permission; if it is missing we open the system page and ask the user to come
  /// back and flip the switch again. Once on, we also offer the battery-optimization
  /// exemption so an aggressive OEM does not kill the watcher in the background.
  Future<void> _toggleSpeedBump(BuildContext context, WidgetRef ref, bool on) async {
    final bridge = ref.read(usageServiceProvider);
    if (!on) {
      await disableStreakGuard(ref);
      return;
    }

    if (!await bridge.isOverlayGranted()) {
      await bridge.openOverlaySettings();
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(
            content: Text('Allow "draw over other apps", then turn this on again.'),
          ));
      }
      return;
    }

    await enableStreakGuard(ref);
    if (!await bridge.isIgnoringBatteryOptimizations()) {
      await bridge.requestIgnoreBatteryOptimizations();
    }
  }

  // ── Pickers ─────────────────────────────────────────────────────────────────
  Future<void> _pickResetHour(BuildContext context, WidgetRef ref, int current) async {
    final picked = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x8C0A0D0B),
      isScrollControlled: true,
      builder: (_) => _HourPickerSheet(selected: current),
    );
    if (picked == null || picked == current) return;
    await _save(ref, AppSettingsCompanion(dayResetHour: Value(picked)));
    await ref.read(trackingRepositoryProvider).syncWorkerConfig();
    // The reset hour shifts every day window, so the live Home view and the
    // recap must recompute rather than show numbers from the old boundary.
    ref.invalidate(homeStateProvider);
    ref.invalidate(dailyRecapProvider);
  }

  Future<void> _pickSummaryTime(BuildContext context, WidgetRef ref, int currentMinutes) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: currentMinutes ~/ 60, minute: currentMinutes % 60),
      helpText: 'SUMMARY TIME',
    );
    if (picked == null) return;
    final minutes = picked.hour * 60 + picked.minute;
    if (minutes == currentMinutes) return;
    await _saveAndReschedule(ref, AppSettingsCompanion(dailySummaryMinutes: Value(minutes)));
  }

  // ── Formatting ──────────────────────────────────────────────────────────────
  String _formatHour(int hour) => _formatClock(hour, 0);

  String _formatMinutes(int minutes) => _formatClock(minutes ~/ 60, minutes % 60);

  static String _formatClock(int hour, int minute) {
    final period = hour < 12 ? 'AM' : 'PM';
    var h = hour % 12;
    if (h == 0) h = 12;
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m $period';
  }
}

// ── The pill toggle (matches the design: 46×28 track, 22 knob) ─────────────────
class _CairnSwitch extends StatelessWidget {
  const _CairnSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        width: 46,
        height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? CairnColors.sage : CairnColors.raised,
          borderRadius: BorderRadius.circular(999),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: value ? CairnColors.textHi : const Color(0xFF8A8F82),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Reset-hour picker (0..23 as "h:00 AM/PM") ──────────────────────────────────
class _HourPickerSheet extends StatelessWidget {
  const _HourPickerSheet({required this.selected});

  final int selected;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.7,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1C221D),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          border: Border(top: BorderSide(color: CairnColors.border)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: CairnColors.borderStrong,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Day resets at',
                  style: CairnType.interface(19, FontWeight.w600, color: CairnColors.textHi),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 28),
                itemCount: 24,
                itemBuilder: (context, hour) {
                  final active = hour == selected;
                  return InkWell(
                    onTap: () => Navigator.of(context).pop(hour),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: CairnColors.borderSoft)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              SettingsScreen._formatClock(hour, 0),
                              style: CairnType.interface(
                                16,
                                active ? FontWeight.w600 : FontWeight.w400,
                                color: active ? CairnColors.sage : CairnColors.textHi,
                              ),
                            ),
                          ),
                          if (active)
                            const Icon(Icons.check, size: 18, color: CairnColors.sage),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
