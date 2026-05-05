import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/api/banking.dart';

void main() {
  test('155 - cardOpenBlockTemp action payload is valid', () {
    expect(BankingService.cardOpenBlockTemp, isA<Function>());

    final payload =
        jsonDecode(jsonEncode({'action': 'UNBLOCK_TEMPORARY', 'pin': '123456'}))
            as Map<String, dynamic>;
    expect(payload['action'], 'UNBLOCK_TEMPORARY');
    expect(payload['pin'], '123456');
  });
}
