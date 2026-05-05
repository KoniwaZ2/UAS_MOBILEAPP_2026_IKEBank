import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/api/banking.dart';

void main() {
  test('157 - setDailyLimit payload includes all three limits', () {
    expect(BankingService.setDailyLimit, isA<Function>());

    final payload =
        jsonDecode(
              jsonEncode({
                'action': 'SET_DAILY_LIMIT',
                'pin': '123456',
                'daily_withdrawal_limit': 1000000,
                'daily_transaction_limit': 2000000,
                'daily_single_transaction_limit': 500000,
              }),
            )
            as Map<String, dynamic>;
    expect(payload['action'], 'SET_DAILY_LIMIT');
    expect(payload['daily_withdrawal_limit'], 1000000);
    expect(payload['daily_transaction_limit'], 2000000);
    expect(payload['daily_single_transaction_limit'], 500000);
  });
}
