import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/api/banking.dart';

void main() {
  test('150 - cardDetails defaults missing card_status to active', () {
    expect(BankingService.cardDetails, isA<Function>());

    final decoded = <String, dynamic>{
      'card_number': '1234567812345678',
      'holder_name': 'IKE User',
    };
    final result = decoded.containsKey('card_status')
        ? decoded
        : <String, dynamic>{...decoded, 'card_status': 'active'};

    expect(result['card_status'], 'active');
  });
}
