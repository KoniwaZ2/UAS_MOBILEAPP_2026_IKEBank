import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/api/banking.dart';

void main() {
  test('159 - cardChangePin action payload is valid', () {
    expect(BankingService.cardChangePin, isA<Function>());

    final payload =
        jsonDecode(
              jsonEncode({
                'action': 'CHANGE_CARD_PIN',
                'old_pin': '123456',
                'new_pin': '654321',
              }),
            )
            as Map<String, dynamic>;
    expect(payload['action'], 'CHANGE_CARD_PIN');
    expect(payload['old_pin'], '123456');
    expect(payload['new_pin'], '654321');
  });
}
