import 'dart:io';

import 'package:cairn/data/db/database.dart';
import 'package:cairn/data/interception_journal.dart';
import 'package:cairn/domain/day_window.dart';
import 'package:cairn/domain/model/interception_outcome.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late CairnDatabase db;
  late Directory tmp;
  late File journal;

  setUp(() async {
    db = CairnDatabase.forTesting(NativeDatabase.memory());
    tmp = await Directory.systemTemp.createTemp('cairn_journal_test');
    journal = File(p.join(tmp.path, 'cairn_interceptions.jsonl'));
  });

  tearDown(() async {
    await db.close();
    if (await tmp.exists()) await tmp.delete(recursive: true);
  });

  // One JSONL line as the native overlay writes it.
  String line(String pkg, int fg, InterceptionOutcome outcome, {int? rec}) =>
      '{"pkg":"$pkg","fg":$fg,"outcome":${outcome.index},"rec":${rec ?? fg + 100}}';

  int dayStartFor(int fgMillis, int resetHour) =>
      DayWindow.startOfDay(DateTime.fromMillisecondsSinceEpoch(fgMillis), resetHour: resetHour)
          .millisecondsSinceEpoch;

  test('drain parses well-formed JSONL lines into rows with Dart-computed dayStartMillis', () async {
    // 10:00 on a day (after the 4am reset) and 02:00 (before reset → previous day).
    final afterReset = DateTime(2026, 6, 20, 10).millisecondsSinceEpoch;
    final beforeReset = DateTime(2026, 6, 20, 2).millisecondsSinceEpoch;
    await journal.writeAsString(
      '${line("com.app", afterReset, InterceptionOutcome.resisted)}\n'
      '${line("com.app", beforeReset, InterceptionOutcome.allowed)}\n',
    );

    final drained = await InterceptionJournal(journal).drainInto(db.interceptionDao, resetHour: 4);
    expect(drained, 2);

    final dayA = dayStartFor(afterReset, 4); // 2026-06-20 04:00
    final dayB = dayStartFor(beforeReset, 4); // 2026-06-19 04:00
    expect(dayA, isNot(dayB));

    final onA = await db.interceptionDao.interceptionsForDay('com.app', dayA);
    final onB = await db.interceptionDao.interceptionsForDay('com.app', dayB);
    expect(onA.single.outcome, InterceptionOutcome.resisted);
    expect(onB.single.outcome, InterceptionOutcome.allowed);

    final days = await db.interceptionDao.daysWithInterceptions('com.app');
    expect(days.toSet(), {dayA, dayB});

    // The file is emptied after a clean drain (line ended with a newline).
    expect(await journal.readAsString(), isEmpty);
  });

  test('drain retains a half-written final line for the next drain', () async {
    final fg = DateTime(2026, 6, 20, 10).millisecondsSinceEpoch;
    final tail = line('com.app', fg + 5000, InterceptionOutcome.allowed); // no trailing newline
    await journal.writeAsString('${line("com.app", fg, InterceptionOutcome.resisted)}\n$tail');

    final drained = await InterceptionJournal(journal).drainInto(db.interceptionDao, resetHour: 4);
    expect(drained, 1, reason: 'only the complete line is drained');
    expect(await journal.readAsString(), tail, reason: 'the half-written tail is kept verbatim');

    // After the tail is completed with a newline, the next drain picks it up.
    await journal.writeAsString('$tail\n');
    final drained2 = await InterceptionJournal(journal).drainInto(db.interceptionDao, resetHour: 4);
    expect(drained2, 1);
    expect(await journal.readAsString(), isEmpty);
  });

  test('draining an empty or missing journal is a no-op', () async {
    expect(await journal.exists(), isFalse);
    expect(await InterceptionJournal(journal).drainInto(db.interceptionDao, resetHour: 4), 0);

    await journal.writeAsString('');
    expect(await InterceptionJournal(journal).drainInto(db.interceptionDao, resetHour: 4), 0);
  });
}
