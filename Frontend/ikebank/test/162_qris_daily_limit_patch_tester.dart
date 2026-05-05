import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/api/banking.dart';

void main() {
  test('162 - setQrisDailyLimit patch payload sends integer', () {
    expect(BankingService.setQrisDailyLimit, isA<Function>());

    final payload =
        jsonDecode(jsonEncode({'qris_limit': 1500000})) as Map<String, dynamic>;
    expect(payload['qris_limit'], isA<int>());
    expect(payload['qris_limit'], 1500000);
  });
}
