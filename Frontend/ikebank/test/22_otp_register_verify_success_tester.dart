import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/api/auth.dart';

void main() {
  group('22 - AuthService.otpVerify() method', () {
    test('otpVerify() method exists and accepts required parameters', () {
      expect(AuthService.otpVerify, isA<Function>());
    });

    test('otpVerify() returns a Future<Map<String, dynamic>>', () {
      final Future<Map<String, dynamic>> Function({
        required String reference,
        required String otpcode,
        required String purpose,
      })
      verifyFn = AuthService.otpVerify;
      expect(verifyFn, isNotNull);
    });
  });
}
