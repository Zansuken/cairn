import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Driver for the screenshot integration test. Writes each captured frame to
/// `store/screenshots/<name>.png` on the host. Run with:
///   flutter drive --driver=test_driver/integration_test.dart \
///     --target=integration_test/screenshot_test.dart -d emulator-5554
Future<void> main() async {
  await integrationDriver(
    onScreenshot: (String name, List<int> bytes, [Map<String, Object?>? args]) async {
      final file = File('store/screenshots/$name.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes);
      return true;
    },
  );
}
