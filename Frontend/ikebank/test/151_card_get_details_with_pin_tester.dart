import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/api/banking.dart';

void main() {
  test('151 - cardGetDetails pin payload is valid', () {
    expect(BankingService.cardGetDetails, isA<Function>());

    final payload =
        jsonDecode(jsonEncode({'pin': '123456'})) as Map<String, dynamic>;
    expect(payload, {'pin': '123456'});
  });
}
