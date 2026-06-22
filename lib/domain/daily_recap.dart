/// Builds the morning "daily recap" (screen-prompts §15): how each tracked
/// cairn fared yesterday, a calm headline, and the honest counts. Pure and
/// synchronous — the provider gathers yesterday's verdicts + streaks and the
/// meta numbers, this turns them into display copy.
enum RecapState { clean, slipped, unverified }

class RecapInput {
  const RecapInput({
    required this.packageId,
    required this.name,
    required this.monogram,
    required this.state,
    required this.currentStreak,
  });

  final String packageId;
  final String name;
  final String monogram;
  final RecapState state;

  /// The run length as of yesterday (Day N) — 0 for a fresh stack after a reset.
  final int currentStreak;
}

class RecapRow {
  const RecapRow({
    required this.name,
    required this.monogram,
    required this.state,
    required this.dayNumber,
  });

  final String name;
  final String monogram;
  final RecapState state;
  final int dayNumber;
}

class DailyRecap {
  const DailyRecap({
    required this.rows,
    required this.grew,
    required this.total,
    required this.anyReset,
    required this.headline,
    required this.subtitle,
    required this.lifetimeClean,
    required this.perfectRun,
  });

  final List<RecapRow> rows;
  final int grew;
  final int total;
  final bool anyReset;
  final String headline;
  final String subtitle;
  final int lifetimeClean;
  final int perfectRun;

  bool get isEmpty => rows.isEmpty;
}

DailyRecap buildDailyRecap({
  required List<RecapInput> apps,
  required int lifetimeClean,
  required int perfectRun,
}) {
  final rows = [
    for (final a in apps)
      RecapRow(name: a.name, monogram: a.monogram, state: a.state, dayNumber: a.currentStreak),
  ];
  final total = apps.length;
  final grew = apps.where((a) => a.state == RecapState.clean).length;
  final resets = apps.where((a) => a.state == RecapState.slipped).length;
  final unverified = apps.where((a) => a.state == RecapState.unverified).length;

  return DailyRecap(
    rows: rows,
    grew: grew,
    total: total,
    anyReset: resets > 0,
    headline: _headline(grew: grew, total: total, unverified: unverified),
    subtitle: _subtitle(grew: grew, total: total, resets: resets, unverified: unverified),
    lifetimeClean: lifetimeClean,
    perfectRun: perfectRun,
  );
}

String _headline({required int grew, required int total, required int unverified}) {
  if (total == 0) return 'No cairns tracked yet.';
  if (total == 1) {
    if (grew == 1) return 'Your cairn grew yesterday.';
    // An unverified day is not a slip — don't call it a reset.
    if (unverified == 1) return "Yesterday couldn't be verified.";
    return 'Your cairn reset yesterday.';
  }
  if (grew == total) return 'All $total cairns grew yesterday.';
  return '$grew of $total cairns grew yesterday.';
}

String _subtitle({
  required int grew,
  required int total,
  required int resets,
  required int unverified,
}) {
  if (total == 0) return 'Add an app to start a cairn.';
  if (resets > 0) {
    return resets == 1
        ? "One stack reset. Its trail is safe, and a new one's already started."
        : '$resets stacks reset. Their trails are safe, and new ones have started.';
  }
  if (unverified > 0) {
    return "Some days couldn't be verified, so they aren't counted clean.";
  }
  return 'A clean sweep — every stack stands taller today.';
}
