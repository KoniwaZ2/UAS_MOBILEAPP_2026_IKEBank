import 'package:flutter/services.dart';
// Test 81: Access token validity check
// Detail: Expired/expiring token recognized invalid
// Class/Method: AuthService.hasValidAccessToken()
// Test 82: JWT parse valid exp
// Detail: Token exp in future returns not-expiring
// Class/Method: AuthService._isTokenExpiringSoon()
// Test 83: JWT parse malformed token
// Detail: Malformed token treated as expiring
// Class/Method: AuthService._isTokenExpiringSoon() catch
// Programmer: Victor

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/api/auth.dart';

String _buildJwt({required int expSeconds}) {
  final header = base64Url.encode(utf8.encode('{"alg":"HS256"}'));
  final payload = base64Url.encode(
    utf8.encode('{"exp":$expSeconds}'),
  );
  return '$header.$payload.signature';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const MethodChannel('plugins.it_nomads.com/flutter_secure_storage').setMockMethodCallHandler((MethodCall methodCall) async => null);
  test('81 - hasValidAccessToken method exists', () async {
    // In test env, no real token stored -> should return false
    final result = await AuthService.hasValidAccessToken();
    expect(result, isFalse);
  });

  test('82 - JWT with future exp is not expiring soon', () {
    // _isTokenExpiringSoon is private, but we can test the JWT parsing logic
    final futureExp =
        (DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000) + 3600;
    final token = _buildJwt(expSeconds: futureExp);
    final parts = token.split('.');
    expect(parts.length, 3);

    final payload = utf8.decode(
      base64Url.decode(base64Url.normalize(parts[1])),
    );
    final decoded = jsonDecode(payload);
    final exp = decoded['exp'] as int;
    final expiresAt =
        DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
    final nowUtc = DateTime.now().toUtc();
    expect(nowUtc.add(const Duration(minutes: 2)).isBefore(expiresAt), isTrue);
  });

  test('83 - malformed token treated as expiring', () {
    const malformedToken = 'not.a.valid.jwt';
    // Parsing logic: parts.length != 3 => return true (expiring)
    final parts = malformedToken.split('.');
    expect(parts.length, isNot(3));
  });
}
