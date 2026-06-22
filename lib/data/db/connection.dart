import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Absolute path of the on-device SQLite file. Shared with the native worker so
/// it writes to the same database (PRD §4.4).
Future<String> databaseFilePath() async {
  final dir = await getApplicationDocumentsDirectory();
  return p.join(dir.path, 'cairn.sqlite');
}

/// The speed-bump interception journal, kept in the SAME directory as the DB so
/// the native overlay (which derives it from the synced dbPath) and Dart agree on
/// the path. Native appends; Dart drains + truncates.
Future<File> interceptionJournalFile() async {
  final dir = await getApplicationDocumentsDirectory();
  return File(p.join(dir.path, 'cairn_interceptions.jsonl'));
}

/// On-device SQLite file. Nothing here ever leaves the device (PRD §11).
QueryExecutor openConnection() {
  return LazyDatabase(() async {
    return NativeDatabase.createInBackground(File(await databaseFilePath()));
  });
}
