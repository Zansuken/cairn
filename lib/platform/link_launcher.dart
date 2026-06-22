import 'package:url_launcher/url_launcher.dart';

/// Opens outbound links (the source repo, F-Droid, a tip page) in the system
/// browser. Abstracted behind an interface so widget tests can assert the URL
/// without hitting the platform channel, and so the app keeps one seam for every
/// outbound link. Cairn itself stays network-free: it hands a URL to the browser
/// and sends nothing of its own.
abstract class LinkLauncher {
  Future<bool> open(String url);
}

class UrlLauncherLink implements LinkLauncher {
  const UrlLauncherLink();

  @override
  Future<bool> open(String url) =>
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}
