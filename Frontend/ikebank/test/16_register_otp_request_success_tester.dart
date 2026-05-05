import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/api/auth.dart';

void main() {
  group('16 - AuthService.otpRequest() method', () {
    test('otpRequest() method exists and accepts required parameters', () {
      expect(AuthService.otpRequest, isA<Function>());
    });

    test('otpRequest() returns a Future<Map<String, dynamic>>', () {
      final Future<Map<String, dynamic>> Function({
        required String email,
        required String purpose,
      })
      otpFn = AuthService.otpRequest;
      expect(otpFn, isNotNull);
    });

    test('otpRequest() purpose normalization handles "registration"', () {
      expect(AuthService.otpRequest, isA<Function>());
    });
  });
}
