import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/api/banking.dart';

void main() {
  test('154 - cardBlockTemp action payload is valid', () {
    expect(BankingService.cardBlockTemp, isA<Function>());

    final payload =
        jsonDecode(jsonEncode({'action': 'BLOCK_TEMPORARY', 'pin': '123456'}))
            as Map<String, dynamic>;
    expect(payload['action'], 'BLOCK_TEMPORARY');
    expect(payload['pin'], '123456');
  });
}
