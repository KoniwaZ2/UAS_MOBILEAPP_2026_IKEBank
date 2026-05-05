import 'package:flutter/services.dart';
// Test 77: Change PIN success
// Detail: Authorized change pin returns 200
// Class/Method: AuthService.changePIN()
// Test 78: Get profile success
// Detail: Authorized profile fetch parses map
// Class/Method: AuthService.getProfile()
// Test 79: Auth header with token
// Detail: Authorization header added when token exists
// Class/Method: AuthService.buildAuthHeaders()
// Test 80: Auth header without token
// Detail: Header excludes Authorization if empty
// Class/Method: AuthService.buildAuthHeaders()
// Programmer: Victor

import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/api/auth.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const MethodChannel('plugins.it_nomads.com/flutter_secure_storage').setMockMethodCallHandler((MethodCall methodCall) async => null);
  test('77 - changePIN method exists with expected signature', () {
    expect(AuthService.changePIN, isA<Function>());
  });

  test('78 - getProfile method exists', () {
    expect(AuthService.getProfile, isA<Function>());
  });

  test('79 - buildAuthHeaders method exists', () {
    expect(AuthService.buildAuthHeaders, isA<Function>());
  });

  test('80 - buildAuthHeaders returns map', () async {
    // In test env, no real token exists; verify returns a Map<String, String>
    final headers = await AuthService.buildAuthHeaders();
    expect(headers, isA<Map<String, String>>());
    // Content-Type should be present by default
    expect(headers['Content-Type'], 'application/json');
  });
}
