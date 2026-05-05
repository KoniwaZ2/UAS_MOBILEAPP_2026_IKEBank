import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/api/banking.dart';

void main() {
  test('149 - cardRequest method exists and revision can update', () {
    expect(BankingService.cardRequest, isA<Function>());

    final payload =
        jsonDecode(
              jsonEncode({'pin': '123456', 'source_funds_id': 'saku-utama'}),
            )
            as Map<String, dynamic>;
    expect(payload['pin'], '123456');
    expect(payload['source_funds_id'], 'saku-utama');

    final before = BankingService.accountDataRevision.value;
    BankingService.notifyAccountDataChanged();
    expect(BankingService.accountDataRevision.value, before + 1);
  });
}
