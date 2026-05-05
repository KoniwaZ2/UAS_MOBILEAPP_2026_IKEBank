import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/api/auth.dart';

void main() {
  group('14 - AuthService.check() endpoint', () {
    test('check() method exists and accepts required parameters', () {
      expect(AuthService.check, isA<Function>());
    });

    test('check() returns a Future<Map<String, dynamic>>', () {
      final Future<Map<String, dynamic>> Function({
        required String phone,
        required String email,
      })
      checkFn = AuthService.check;
      expect(checkFn, isNotNull);
    });
  });
}
