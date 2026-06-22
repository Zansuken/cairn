import 'package:share_plus/share_plus.dart';

/// Hands text to the OS share sheet. Abstracted behind an interface so widget
/// tests can capture what would be shared without invoking the platform sheet,
/// and so the app keeps one seam for sharing. The target app the user picks does
/// the sending; Cairn transmits nothing of its own.
abstract class Sharer {
  Future<void> share(String text);
}

class SharePlusSharer implements Sharer {
  const SharePlusSharer();

  @override
  Future<void> share(String text) => SharePlus.instance.share(ShareParams(text: text));
}
