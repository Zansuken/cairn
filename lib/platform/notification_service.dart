import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// On-device local notifications (PRD §8): a single calm daily summary, no
/// re-engagement nags. Everything is scheduled by the OS — nothing phones home.
/// Milestone celebrations are shown in-app as modals (see moment_modals), so the
/// only scheduled notification is the morning recap.
class NotificationService {
  const NotificationService();

  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  static const int _dailySummaryId = 1;
  static const String _channelId = 'daily_summary';
  static const String _channelName = 'Daily summary';
  static const String _channelDesc = 'One calm recap each morning';

  /// Payload carried by the daily-summary notification; tapping it should open
  /// the daily recap.
  static const String recapPayload = 'daily_recap';

  /// Idempotent. [onTap] receives the payload of a tapped notification.
  Future<void> init({void Function(String? payload)? onTap}) async {
    if (_ready) return;

    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      // Leave tz.local as UTC if the platform can't report a zone — the daily
      // summary still fires, just anchored to UTC wall-clock.
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      settings: const InitializationSettings(android: android),
      onDidReceiveNotificationResponse: (resp) => onTap?.call(resp.payload),
    );

    await _android?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.defaultImportance,
      ),
    );

    _ready = true;
  }

  /// If the app was launched by tapping a notification (cold start), return its
  /// payload so the caller can route to the right screen.
  Future<String?> launchPayload() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp ?? false) {
      return details!.notificationResponse?.payload;
    }
    return null;
  }

  /// Android 13+ runtime permission. No-op (returns true) below 13.
  Future<bool> requestPermission() async =>
      (await _android?.requestNotificationsPermission()) ?? true;

  /// Schedule (or cancel) the daily summary to repeat at [minutes] after
  /// midnight, honouring the user's toggle.
  Future<void> syncDailySummary({required bool enabled, required int minutes}) async {
    await _plugin.cancel(id: _dailySummaryId);
    if (!enabled) return;

    await _plugin.zonedSchedule(
      id: _dailySummaryId,
      title: 'Your morning recap',
      body: 'See how your cairns fared yesterday.',
      scheduledDate: _nextInstanceOf(minutes ~/ 60, minutes % 60),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      // Inexact: no SCHEDULE_EXACT_ALARM special permission needed (PRD §8 — a
      // calm morning nudge doesn't need to-the-second precision).
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // repeat daily
      payload: recapPayload,
    );
  }

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var next = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!next.isAfter(now)) next = next.add(const Duration(days: 1));
    return next;
  }
}
