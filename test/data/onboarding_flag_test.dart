import 'package:cairn/data/db/database.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CairnDatabase db;

  setUp(() => db = CairnDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('onboardingComplete defaults to false on a fresh database', () async {
    final settings = await db.settingsDao.get();
    expect(settings.onboardingComplete, isFalse);
  });

  test('saving the flag persists and is readable', () async {
    await db.settingsDao.save(const AppSettingsCompanion(onboardingComplete: Value(true)));
    final settings = await db.settingsDao.get();
    expect(settings.onboardingComplete, isTrue);
    // Other defaults remain intact (reset hour, notifications).
    expect(settings.dayResetHour, 4);
    expect(settings.notificationsEnabled, isTrue);
  });
}
