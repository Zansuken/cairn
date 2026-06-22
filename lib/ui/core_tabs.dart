import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'widgets/cairn_bottom_nav.dart';

/// The selected top-level destination of [MainShell]. Screens inside the shell
/// switch tabs by writing this (e.g. Home's "Track another app" jumps to Apps),
/// instead of pushing a new route — that is what keeps the bottom bar fixed.
class SelectedTabNotifier extends Notifier<CairnTab> {
  @override
  CairnTab build() => CairnTab.home;

  void select(CairnTab tab) => state = tab;
}

final selectedTabProvider =
    NotifierProvider<SelectedTabNotifier, CairnTab>(SelectedTabNotifier.new);
