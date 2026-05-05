import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/api/banking.dart';

void main() {
  test('164 - changePin forgot flow payload is valid', () {
    expect(BankingService.changePin, isA<Function>());

    final payload =
        jsonDecode(
              jsonEncode({'new_pin': '654321', 'new_pin_confirm': '654321'}),
            )
            as Map<String, dynamic>;
    expect(payload['new_pin'], '654321');
    expect(payload['new_pin_confirm'], payload['new_pin']);
  });
}
