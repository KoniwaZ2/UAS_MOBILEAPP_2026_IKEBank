import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/api/banking.dart';

void main() {
  test('161 - getQrisDailyLimit method exists and decoded map is valid', () {
    expect(BankingService.getQrisDailyLimit, isA<Function>());

    final decoded =
        jsonDecode(jsonEncode({'qris_limit': 1500000})) as Map<String, dynamic>;
    expect(decoded['qris_limit'], 1500000);
  });
}
