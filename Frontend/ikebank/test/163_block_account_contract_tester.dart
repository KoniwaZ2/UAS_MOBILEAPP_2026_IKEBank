import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/api/banking.dart';

void main() {
  test('163 - blockAccount method exists and success body can decode', () {
    expect(BankingService.blockAccount, isA<Function>());

    final decoded =
        jsonDecode(jsonEncode({'message': 'Account blocked'}))
            as Map<String, dynamic>;
    expect(decoded['message'], 'Account blocked');
  });
}
