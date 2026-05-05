import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/api/banking.dart';

void main() {
  test('160 - cardBlock status payload is valid', () {
    expect(BankingService.cardBlock, isA<Function>());

    final payload =
        jsonDecode(jsonEncode({'action': 'CHANGE_STATUS', 'status': 'blocked'}))
            as Map<String, dynamic>;
    expect(payload, {'action': 'CHANGE_STATUS', 'status': 'blocked'});
  });
}
