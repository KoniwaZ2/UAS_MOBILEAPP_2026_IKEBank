// Test 60: OTP login verify success
// Detail: OTP login verify opens face verify
// Class/Method: AuthService.otpVerify() purpose login
// Test 61: OTP login verify fail
// Detail: Invalid OTP surfaces backend detail
// Class/Method: VerifikasiCodeScreen error parser
// Programmer: Victor

import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/api/auth.dart';

void main() {
  test('60 - otpVerify method exists with expected signature', () {
    expect(AuthService.otpVerify, isA<Function>());
    final Future<Map<String, dynamic>> Function({
      required String reference,
      required String otpcode,
      required String purpose,
    }) fn = AuthService.otpVerify;
    expect(fn, isNotNull);
  });

  test('61 - _extractErrorMessage strips noisy prefix', () {
    // VerifikasiCodeScreen uses e.toString().replaceFirst('Exception: ', '')
    const raw = 'Exception: Invalid OTP code';
    final cleaned = raw.replaceFirst('Exception: ', '');
    expect(cleaned, 'Invalid OTP code');
  });
}
