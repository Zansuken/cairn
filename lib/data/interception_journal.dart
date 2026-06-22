import 'dart:convert';
import 'dart:io';

import '../domain/day_window.dart';
import '../domain/model/interception_event.dart';
import '../domain/model/interception_outcome.dart';
import 'db/database.dart';
import 'db/daos/interception_dao.dart';
import 'db/mappers.dart';

/// Dart side of the speed-bump journal. The native overlay appends one JSON
/// object per line (`{"pkg","fg","outcome","rec"}`) to a file; this drains the
/// complete lines into Drift (the only SQLite writer) and truncates them, keeping
/// any half-written final line for the next drain.
class InterceptionJournal {
  /// A journal over a concrete [file] (tests).
  InterceptionJournal(File file) : _resolve = (() async => file);

  /// A journal whose file path is resolved lazily — production builds the service
  /// synchronously but the path needs an async path_provider lookup.
  InterceptionJournal.lazy(this._resolve);

  final Future<File> Function() _resolve;

  /// Parse complete JSONL lines into the [dao], deriving each row's reset-hour
  /// day in Dart (never trusting a native day boundary), then truncate the
  /// drained lines. Returns the number of rows drained.
  Future<int> drainInto(InterceptionDao dao, {required int resetHour}) async {
    final file = await _resolve();
    if (!await file.exists()) return 0;
    final content = await file.readAsString();

    // Only drain up to the last newline; a tail without a trailing newline is a
    // possibly half-written line and is retained verbatim.
    final lastNewline = content.lastIndexOf('\n');
    if (lastNewline < 0) return 0;
    final complete = content.substring(0, lastNewline);
    final remainder = content.substring(lastNewline + 1);

    final rows = <InterceptionEventsCompanion>[];
    for (final raw in complete.split('\n')) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      Map<String, dynamic> obj;
      try {
        obj = jsonDecode(line) as Map<String, dynamic>;
      } catch (_) {
        // Skip a corrupt complete line. Losing it errs toward unverified, never
        // a false clean.
        continue;
      }
      final event = InterceptionEvent(
        packageId: obj['pkg'] as String,
        foregroundAt: DateTime.fromMillisecondsSinceEpoch((obj['fg'] as num).toInt()),
        outcome: InterceptionOutcome.fromIndex((obj['outcome'] as num).toInt()),
        recordedAt: DateTime.fromMillisecondsSinceEpoch((obj['rec'] as num).toInt()),
      );
      final dayStart =
          DayWindow.startOfDay(event.foregroundAt, resetHour: resetHour).millisecondsSinceEpoch;
      rows.add(event.toCompanion(dayStartMillis: dayStart));
    }

    if (rows.isNotEmpty) await dao.upsertAll(rows);
    await file.writeAsString(remainder);
    return rows.length;
  }
}
