import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/api/banking.dart';

void main() {
  test('153 - cardVerify action payload is valid', () {
    expect(BankingService.cardVerify, isA<Function>());

    final payload =
        jsonDecode(
              jsonEncode({
                'action': 'VERIFY_CARD',
                'card_last6_digits': '123456',
                'status': 'active',
              }),
            )
            as Map<String, dynamic>;
    expect(payload, {
      'action': 'VERIFY_CARD',
      'card_last6_digits': '123456',
      'status': 'active',
    });
  });
}
