import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/api/banking.dart';

void main() {
  test('156 - cardBlockPerm action payload is valid', () {
    expect(BankingService.cardBlockPerm, isA<Function>());

    final payload =
        jsonDecode(jsonEncode({'action': 'BLOCK_PERMANENT', 'pin': '123456'}))
            as Map<String, dynamic>;
    expect(payload['action'], 'BLOCK_PERMANENT');
    expect(payload['pin'], '123456');
  });
}
