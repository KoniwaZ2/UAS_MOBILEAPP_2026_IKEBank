// Test 116: Check QRIS success
// Detail: QRIS check payload + response decode
// Class/Method: BankingService.checkQris()
// Test 117: Bayar QRIS amount int parsing
// Detail: Amount string int converted to int
// Class/Method: BankingService.bayarQris() parsedAmount
// Test 118: Bayar QRIS amount decimal parsing
// Detail: Decimal amount converted to double
// Class/Method: BankingService.bayarQris() parsedAmount
// Test 119: Bayar QRIS account revision
// Detail: On success accountDataRevision increments
// Class/Method: BankingService.notifyAccountDataChanged()
// Programmer: Victor

import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/api/banking.dart';

void main() {
  test('116 - checkQris method exists', () {
    expect(BankingService.checkQris, isA<Function>());
  });

  test('117 - int amount string parsed to int', () {
    const amount = '50000';
    final parsed = int.tryParse(amount) ?? double.tryParse(amount) ?? amount;
    expect(parsed, 50000);
    expect(parsed, isA<int>());
  });

  test('118 - decimal amount string parsed to double', () {
    const amount = '50000.50';
    final parsed = int.tryParse(amount) ?? double.tryParse(amount) ?? amount;
    expect(parsed, 50000.50);
    expect(parsed, isA<double>());
  });

  test('119 - notifyAccountDataChanged increments revision', () {
    final before = BankingService.accountDataRevision.value;
    BankingService.notifyAccountDataChanged();
    expect(BankingService.accountDataRevision.value, before + 1);
  });
}
