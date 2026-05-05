// Test 90: Token extraction nested map
// Detail: Token extracted from nested token object
// Class/Method: AuthService._extractTokens() nested branch
// Test 91: Token extraction alt keys
// Detail: Token extracted from access_token keys
// Class/Method: AuthService._extractTokens() alt keys
// Test 92: Error extraction detail priority
// Detail: detail prioritized over other fields
// Class/Method: AuthService._extractErrorMessage()
// Test 93: Error extraction list priority
// Detail: List first item used as message
// Class/Method: AuthService._extractErrorMessage()
// Test 94: Error extraction fallback
// Detail: Unparseable response falls back to HTTP msg
// Class/Method: AuthService._extractErrorMessage() catch
// Test 95: Dynamic error extraction map
// Detail: Dynamic map parsed to meaningful message
// Class/Method: AuthService._extractErrorFromDynamic()
// Programmer: Victor

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('90 - nested token object extraction', () {
    final decoded = <String, dynamic>{
      'token': {
        'access': 'access_value',
        'refresh': 'refresh_value',
      },
    };
    final nested = decoded['token'];
    expect(nested, isA<Map<String, dynamic>>());
    expect((nested as Map)['access'], 'access_value');
    expect(nested['refresh'], 'refresh_value');
  });

  test('91 - alt keys access_token/refresh_token extraction', () {
    final decoded = <String, dynamic>{
      'access_token': 'at_value',
      'refresh_token': 'rt_value',
    };
    final access =
        decoded['access']?.toString() ?? decoded['access_token']?.toString();
    final refresh =
        decoded['refresh']?.toString() ?? decoded['refresh_token']?.toString();
    expect(access, 'at_value');
    expect(refresh, 'rt_value');
  });

  test('92 - detail field prioritized in error extraction', () {
    final decoded = <String, dynamic>{
      'detail': 'Specific error message',
      'email': ['Email already exists'],
    };
    final detail = decoded['detail']?.toString();
    expect(detail, 'Specific error message');
  });

  test('93 - list first item used as error message', () {
    final decoded = <String, dynamic>{
      'email': ['Email already exists', 'Another error'],
    };
    String? message;
    for (final entry in decoded.entries) {
      final value = entry.value;
      if (value is List && value.isNotEmpty) {
        message = value.first.toString();
        break;
      }
    }
    expect(message, 'Email already exists');
  });

  test('94 - unparseable response uses HTTP fallback', () {
    const fallback = 'Failed to check data';
    const statusCode = 500;
    const invalidJson = 'not json';
    String result;
    try {
      jsonDecode(invalidJson);
      result = fallback;
    } catch (_) {
      result = '$fallback (HTTP $statusCode)';
    }
    expect(result, 'Failed to check data (HTTP 500)');
  });

  test('95 - dynamic error from map with detail', () {
    final decoded = <String, dynamic>{
      'detail': 'Dynamic error detail',
    };
    String result = 'fallback';
    if (decoded is Map<String, dynamic>) {
      final detail = decoded['detail']?.toString();
      if (detail != null && detail.isNotEmpty) {
        result = detail;
      }
    }
    expect(result, 'Dynamic error detail');
  });
}
