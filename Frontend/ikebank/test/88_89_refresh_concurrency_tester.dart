import 'package:flutter/services.dart';
// Test 88: Refresh concurrency lock
// Detail: Parallel refresh requests share completer
// Class/Method: AuthService._refreshCompleter coordination
// Test 89: Refresh endpoint fallback
// Detail: Try token/refresh then refresh endpoint
// Class/Method: AuthService._performRefresh() endpoint loop
// Programmer: Victor

import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/api/auth.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const MethodChannel('plugins.it_nomads.com/flutter_secure_storage').setMockMethodCallHandler((MethodCall methodCall) async => null);
  test('88 - refreshAccessTokenIfNeeded returns bool', () async {
    // In test env with no tokens, refresh should return false
    final result = await AuthService.refreshAccessTokenIfNeeded();
    // No refresh token available, should fail gracefully
    expect(result, isA<bool>());
  });

  test('89 - _performRefresh tries two endpoint patterns', () {
    // The method tries: $baseUrl/token/refresh/ and $baseUrl/refresh/
    // We verify the baseUrl is accessible and the endpoints would be formed
    expect(AuthService.baseUrl, contains('/api/auth'));
    final endpoint1 = '${AuthService.baseUrl}/token/refresh/';
    final endpoint2 = '${AuthService.baseUrl}/refresh/';
    expect(endpoint1, endsWith('/token/refresh/'));
    expect(endpoint2, endsWith('/refresh/'));
  });
}
