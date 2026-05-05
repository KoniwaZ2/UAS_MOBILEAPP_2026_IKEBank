import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/api/banking.dart';

void main() {
  test('152 - cardActivate action payload is valid', () {
    expect(BankingService.cardActivate, isA<Function>());

    final payload =
        jsonDecode(
              jsonEncode({
                'action': 'ACTIVATE_CARD',
                'card_last6_digits': '123456',
                'new_pin': '654321',
              }),
            )
            as Map<String, dynamic>;
    expect(payload['action'], 'ACTIVATE_CARD');
    expect(payload['card_last6_digits'], '123456');
    expect(payload['new_pin'], '654321');
  });
}
