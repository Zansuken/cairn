import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../providers/providers.dart';

/// Shared enable/disable for the Streak guard, used by both onboarding and
/// Settings. The overlay permission and the battery-optimization prompt are
/// handled by the calling UI (they need the widget lifecycle); these just own the
/// persisted setting + worker/snapshot sync + the native watcher.

/// Persist the setting (set-once `enabledAt`), sync the worker config + overlay
/// snapshot, flip the native flag, and start the watcher. The caller must ensure
/// the overlay permission is granted first.
Future<void> enableStreakGuard(WidgetRef ref) async {
  final db = ref.read(databaseProvider);
  final bridge = ref.read(usageServiceProvider);
  final current = await db.settingsDao.get();
  await db.settingsDao.save(AppSettingsCompanion(
    speedBumpEnabled: const Value(true),
    speedBumpEnabledAtMillis:
        Value(current.speedBumpEnabledAtMillis ?? DateTime.now().millisecondsSinceEpoch),
  ));
  await ref.read(trackingRepositoryProvider).syncWorkerConfig();
  await bridge.setSpeedBumpEnabled(true);
  await bridge.startSpeedBump();
}

Future<void> disableStreakGuard(WidgetRef ref) async {
  final db = ref.read(databaseProvider);
  final bridge = ref.read(usageServiceProvider);
  await db.settingsDao.save(const AppSettingsCompanion(speedBumpEnabled: Value(false)));
  await bridge.setSpeedBumpEnabled(false);
  await bridge.stopSpeedBump();
}
