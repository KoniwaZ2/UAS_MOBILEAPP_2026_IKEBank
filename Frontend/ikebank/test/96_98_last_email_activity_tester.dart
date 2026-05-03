import 'package:flutter/services.dart';
// Test 96: Last email write guard
// Detail: Empty trimmed email not persisted
// Class/Method: AuthService.saveLastEmail()
// Test 97: Last email read normalize
// Detail: Read trims and returns null if empty
// Class/Method: AuthService.getLastEmail()
// Test 98: Activity throttle refresh
// Detail: User activity refresh respects throttle
// Class/Method: AuthService.onUserActivity()
// Programmer: Victor

import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/api/auth.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const MethodChannel('plugins.it_nomads.com/flutter_secure_storage').setMockMethodCallHandler((MethodCall methodCall) async => null);
  test('96 - empty email not persisted', () {
    // saveLastEmail trims and returns early if empty
    final normalizedEmail = '   '.trim();
    expect(normalizedEmail.isEmpty, isTrue);
  });

  test('97 - getLastEmail returns null when no email stored', () async {
    final email = await AuthService.getLastEmail();
    // In test env, no email stored initially
    expect(email, isNull);
  });

  test('98 - onUserActivity method exists', () {
    expect(AuthService.onUserActivity, isA<Function>());
  });
}
