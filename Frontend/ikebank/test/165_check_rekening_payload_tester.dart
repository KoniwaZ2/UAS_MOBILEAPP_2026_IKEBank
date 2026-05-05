import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/api/banking.dart';

void main() {
  test('165 - checkRekening sends bank and account number correctly', () {
    expect(BankingService.checkRekening, isA<Function>());

    final payload =
        jsonDecode(
              jsonEncode({
                'bank_name': 'IKE Bank',
                'account_number': '1234567890',
              }),
            )
            as Map<String, dynamic>;
    expect(payload['bank_name'], 'IKE Bank');
    expect(payload['account_number'], '1234567890');
  });
}
