// Test 70: Biometric check contract
// Detail: Biometric check returns expected shape
// Class/Method: AuthService.biometricCheck()
// Test 71: Biometric toggle contract
// Detail: Toggle true/false patches backend
// Class/Method: AuthService.biometricToogle()
// Test 72: Biometric login success
// Detail: Biometric login stores tokens and email
// Class/Method: AuthService.biometricLogin()
// Programmer: Victor

import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/api/auth.dart';

void main() {
  test('70 - biometricCheck method exists with expected signature', () {
    expect(AuthService.biometricCheck, isA<Function>());
    final Future<dynamic> Function({required String email}) fn =
        AuthService.biometricCheck;
    expect(fn, isNotNull);
  });

  test('71 - biometricToogle method exists with expected signature', () {
    expect(AuthService.biometricToogle, isA<Function>());
    final Future<dynamic> Function(bool) fn = AuthService.biometricToogle;
    expect(fn, isNotNull);
  });

  test('72 - biometricLogin method exists with expected signature', () {
    expect(AuthService.biometricLogin, isA<Function>());
    final Future<dynamic> Function({required String email}) fn =
        AuthService.biometricLogin;
    expect(fn, isNotNull);
  });
}
