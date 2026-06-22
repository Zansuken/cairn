import 'dart:convert';

import 'package:flutter/services.dart';

/// An installed, launchable app (for the picker). [iconPng] is present only when
/// icons were requested.
class InstalledApp {
  const InstalledApp({required this.packageId, required this.label, this.iconPng});

  final String packageId;
  final String label;
  final Uint8List? iconPng;
}

/// Abstraction over the native detection bridge, so the reconciliation logic can
/// be unit-tested with a fake.
abstract interface class UsageGateway {
  Future<bool> isUsageAccessGranted();
  Future<void> openUsageAccessSettings();

  /// The subset of [packages] that had a foreground open in [startMillis, endMillis).
  Future<Set<String>> openedPackages(List<String> packages, int startMillis, int endMillis);

  /// Per-open foreground event timestamps (epoch millis) for one [packageId] in
  /// [startMillis, endMillis) — the match key for reconciling speed-bump
  /// interceptions against the OS log. Same open predicate as [openedPackages].
  Future<List<int>> openTimestamps(String packageId, int startMillis, int endMillis);

  Future<List<InstalledApp>> installedApps({bool withIcons = false});
}

/// Controls the native daily reconciliation worker (PRD §4.4). Kept separate
/// from [UsageGateway] since it is scheduling, not detection.
abstract interface class WorkerController {
  /// Keep the worker's config in sync (active packages, reset hour, DB path).
  Future<void> updateWorkerConfig({
    required List<String> packages,
    required int resetHour,
    required String dbPath,
  });

  /// (Re)schedule the daily ~04:05 reconciliation.
  Future<void> scheduleDailyReconciliation();

  /// Enqueue a one-off reconciliation now (for testing).
  Future<void> runReconciliationNow();

  /// Push the per-app current streak + display name the overlay reads to render
  /// its copy (kept in native prefs, no SQLite on the overlay hot path).
  Future<void> saveSpeedBumpSnapshot(Map<String, int> streaks, Map<String, String> labels);
}

/// Controls the intervention speed-bump overlay + its watcher service, and the
/// "draw over other apps" permission it needs. Separate from detection.
abstract interface class SpeedBumpController {
  Future<bool> isOverlayGranted();
  Future<void> openOverlaySettings();
  Future<void> setSpeedBumpEnabled(bool enabled);
  Future<void> startSpeedBump();
  Future<void> stopSpeedBump();
  Future<bool> isSpeedBumpRunning();

  /// Whether Cairn is exempt from battery optimization (so the OEM is less likely
  /// to kill the watcher in the background). Defaults true if unknown, to avoid
  /// nagging when we cannot tell.
  Future<bool> isIgnoringBatteryOptimizations();

  /// Open the system prompt to let Cairn run without battery optimization.
  Future<void> requestIgnoreBatteryOptimizations();

  /// The device manufacturer (lowercased), so the UI shows the OEM "protected
  /// apps" hint only where it applies (Honor/Huawei/Xiaomi/Oppo/Vivo... kill
  /// background services). Empty string if unknown.
  Future<String> deviceManufacturer();

  /// Best-effort: open the OEM "auto-start / protected apps" page so the user can
  /// whitelist Cairn. Falls back to this app's system details page.
  Future<void> openProtectedAppsSettings();
}

/// MethodChannel client for `cairn/usage`. The channel name and method contract
/// are reused VERBATIM from the validated detection spike (with additive worker
/// control methods).
class UsageService implements UsageGateway, WorkerController, SpeedBumpController {
  const UsageService();

  static const _channel = MethodChannel('cairn/usage');

  @override
  Future<void> updateWorkerConfig({
    required List<String> packages,
    required int resetHour,
    required String dbPath,
  }) =>
      _channel.invokeMethod('updateWorkerConfig', {
        'packages': packages,
        'resetHour': resetHour,
        'dbPath': dbPath,
      });

  @override
  Future<void> scheduleDailyReconciliation() =>
      _channel.invokeMethod('scheduleDailyReconciliation');

  @override
  Future<void> runReconciliationNow() => _channel.invokeMethod('runReconciliationNow');

  @override
  Future<void> saveSpeedBumpSnapshot(Map<String, int> streaks, Map<String, String> labels) =>
      _channel.invokeMethod('saveSpeedBumpSnapshot', {'streaks': streaks, 'labels': labels});

  @override
  Future<bool> isOverlayGranted() async =>
      await _channel.invokeMethod<bool>('isOverlayGranted') ?? false;

  @override
  Future<void> openOverlaySettings() => _channel.invokeMethod('openOverlaySettings');

  @override
  Future<void> setSpeedBumpEnabled(bool enabled) =>
      _channel.invokeMethod('setSpeedBumpEnabled', {'enabled': enabled});

  @override
  Future<void> startSpeedBump() => _channel.invokeMethod('startSpeedBump');

  @override
  Future<void> stopSpeedBump() => _channel.invokeMethod('stopSpeedBump');

  @override
  Future<bool> isSpeedBumpRunning() async =>
      await _channel.invokeMethod<bool>('isSpeedBumpRunning') ?? false;

  @override
  Future<bool> isIgnoringBatteryOptimizations() async =>
      await _channel.invokeMethod<bool>('isIgnoringBatteryOptimizations') ?? true;

  @override
  Future<void> requestIgnoreBatteryOptimizations() =>
      _channel.invokeMethod('requestIgnoreBatteryOptimizations');

  @override
  Future<String> deviceManufacturer() async =>
      await _channel.invokeMethod<String>('getManufacturer') ?? '';

  @override
  Future<void> openProtectedAppsSettings() =>
      _channel.invokeMethod('openProtectedAppsSettings');

  @override
  Future<bool> isUsageAccessGranted() async =>
      await _channel.invokeMethod<bool>('isUsageAccessGranted') ?? false;

  @override
  Future<void> openUsageAccessSettings() =>
      _channel.invokeMethod('openUsageAccessSettings');

  @override
  Future<Set<String>> openedPackages(
    List<String> packages,
    int startMillis,
    int endMillis,
  ) async {
    final r = await _channel.invokeMethod<List<dynamic>>('getOpenedPackages', {
      'packages': packages,
      'startMillis': startMillis,
      'endMillis': endMillis,
    });
    return (r ?? const []).cast<String>().toSet();
  }

  @override
  Future<List<int>> openTimestamps(String packageId, int startMillis, int endMillis) async {
    final r = await _channel.invokeMethod<List<dynamic>>('getOpenTimestamps', {
      'package': packageId,
      'startMillis': startMillis,
      'endMillis': endMillis,
    });
    return (r ?? const []).map((e) => (e as num).toInt()).toList();
  }

  @override
  Future<List<InstalledApp>> installedApps({bool withIcons = false}) async {
    final r = await _channel.invokeMethod<List<dynamic>>('getInstalledApps', {
      'withIcons': withIcons,
    });
    return (r ?? const []).map((e) {
      final m = Map<String, dynamic>.from(e as Map);
      final icon = m['icon'] as String?;
      return InstalledApp(
        packageId: m['package'] as String,
        label: m['label'] as String,
        iconPng: icon == null ? null : base64Decode(icon),
      );
    }).toList();
  }
}
