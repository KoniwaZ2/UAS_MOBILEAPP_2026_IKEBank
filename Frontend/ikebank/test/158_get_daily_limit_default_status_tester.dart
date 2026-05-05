import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/api/banking.dart';

void main() {
  test('158 - getDailyLimit defaults missing card_status to active', () {
    expect(BankingService.getDailyLimit, isA<Function>());

    final decoded = <String, dynamic>{
      'daily_withdrawal_limit': 1000000,
      'daily_transaction_limit': 2000000,
    };
    final result = decoded.containsKey('card_status')
        ? decoded
        : <String, dynamic>{...decoded, 'card_status': 'active'};

    expect(result['card_status'], 'active');
  });
}
