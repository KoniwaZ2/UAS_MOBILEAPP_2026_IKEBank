// Test 166: AccountDetail parse id int/string
// Detail: ID parsed from int or string
// Class/Method: AccountDetail._parseInt()
// Test 167: AccountDetail parse user id
// Detail: user_id parsed robustly
// Class/Method: AccountDetail._parseInt()
// Test 168: AccountDetail read mandatory strings
// Detail: Username/account read with trim fallback
// Class/Method: AccountDetail._readString()
// Test 169: AccountDetail nullable card number
// Detail: Card number null/empty handled
// Class/Method: AccountDetail._readNullableString()
// Test 170: AccountDetail block flag semantics
// Detail: block/is_blocked translated consistently
// Class/Method: AccountDetail.fromJson() isBlocked
// Programmer: Victor

import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/models/account_detail.dart';

void main() {
  test('166 - id parsed from int', () {
    final json = <String, dynamic>{
      'id': 42,
      'user_id': 1,
      'user_name': 'Test',
      'account_number': '1234567890',
      'card_number': null,
      'balance': '100000',
      'block': true,
      'created_at': '2025-01-01T00:00:00Z',
    };
    final detail = AccountDetail.fromJson(json);
    expect(detail.id, 42);
  });

  test('166b - id parsed from string', () {
    final json = <String, dynamic>{
      'id': '42',
      'user_id': '1',
      'user_name': 'Test',
      'account_number': '1234567890',
      'card_number': null,
      'balance': '100000',
      'block': true,
      'created_at': '2025-01-01T00:00:00Z',
    };
    final detail = AccountDetail.fromJson(json);
    expect(detail.id, 42);
  });

  test('167 - user_id parsed robustly', () {
    final json = <String, dynamic>{
      'id': 1,
      'user_id': '99',
      'user_name': 'Test',
      'account_number': '1234567890',
      'card_number': null,
      'balance': '0',
      'block': true,
      'created_at': '2025-01-01T00:00:00Z',
    };
    final detail = AccountDetail.fromJson(json);
    expect(detail.userid, 99);
  });

  test('168 - username and account read with trim', () {
    final json = <String, dynamic>{
      'id': 1,
      'user_id': 1,
      'user_name': '  Victor  ',
      'account_number': '  1234567890  ',
      'card_number': null,
      'balance': '0',
      'block': true,
      'created_at': '2025-01-01T00:00:00Z',
    };
    final detail = AccountDetail.fromJson(json);
    expect(detail.username, 'Victor');
    expect(detail.accountnumber, '1234567890');
  });

  test('169 - card number null handled', () {
    final json = <String, dynamic>{
      'id': 1,
      'user_id': 1,
      'user_name': 'Test',
      'account_number': '1234567890',
      'card_number': null,
      'balance': '0',
      'block': true,
      'created_at': '2025-01-01T00:00:00Z',
    };
    final detail = AccountDetail.fromJson(json);
    expect(detail.cardnumber, isNull);
  });

  test('169b - card number empty string handled as null', () {
    final json = <String, dynamic>{
      'id': 1,
      'user_id': 1,
      'user_name': 'Test',
      'account_number': '1234567890',
      'card_number': '  ',
      'balance': '0',
      'block': true,
      'created_at': '2025-01-01T00:00:00Z',
    };
    final detail = AccountDetail.fromJson(json);
    expect(detail.cardnumber, isNull);
  });

  test('170 - block flag semantics', () {
    // block == false || is_blocked == 'false' => isBlocked = true
    final json1 = <String, dynamic>{
      'id': 1,
      'user_id': 1,
      'user_name': 'Test',
      'account_number': '1234567890',
      'card_number': null,
      'balance': '0',
      'block': false,
      'created_at': '2025-01-01T00:00:00Z',
    };
    final detail1 = AccountDetail.fromJson(json1);
    expect(detail1.isBlocked, isTrue);

    final json2 = <String, dynamic>{
      'id': 1,
      'user_id': 1,
      'user_name': 'Test',
      'account_number': '1234567890',
      'card_number': null,
      'balance': '0',
      'is_blocked': 'false',
      'created_at': '2025-01-01T00:00:00Z',
    };
    final detail2 = AccountDetail.fromJson(json2);
    expect(detail2.isBlocked, isTrue);
  });
}
