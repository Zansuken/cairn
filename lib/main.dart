import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'platform/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const notifications = NotificationService();
  await notifications.init(
    onTap: (payload) {
      if (payload == NotificationService.recapPayload) showDailyRecap();
    },
  );
  final launchPayload = await notifications.launchPayload();

  runApp(const ProviderScope(child: CairnApp()));

  // Cold-started by tapping the daily summary → land on the recap.
  if (launchPayload == NotificationService.recapPayload) {
    WidgetsBinding.instance.addPostFrameCallback((_) => showDailyRecap());
  }
}
