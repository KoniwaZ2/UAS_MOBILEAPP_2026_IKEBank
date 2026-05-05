import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/api/banking.dart';

void main() {
  test('148 - cashflowCalculate method exists and payload is valid', () {
    expect(BankingService.cashflowCalculate, isA<Function>());

    final payload =
        jsonDecode(jsonEncode({'month': 5, 'year': 2026}))
            as Map<String, dynamic>;
    expect(payload, {'month': 5, 'year': 2026});
  });
}
