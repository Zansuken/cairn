import 'package:cairn/platform/oem_support.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isAggressiveOem', () {
    test('Honor needs the app-launch whitelist (battery exemption is not enough)', () {
      expect(isAggressiveOem('HONOR'), isTrue);
    });

    test('Huawei and Xiaomi are aggressive too', () {
      expect(isAggressiveOem('huawei'), isTrue);
      expect(isAggressiveOem('Xiaomi'), isTrue);
    });

    test('matching is case- and whitespace-insensitive', () {
      expect(isAggressiveOem('  Honor '), isTrue);
    });

    test('stock-Android makers do not need the extra step', () {
      expect(isAggressiveOem('Google'), isFalse);
      expect(isAggressiveOem(''), isFalse);
    });
  });
}
