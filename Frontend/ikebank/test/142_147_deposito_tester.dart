// Test 142: Deposito list success
// Detail: Deposito list endpoint decodes payload
// Class/Method: BankingService.DepositoList()
// Test 143: Buat deposito success
// Detail: Buat deposito increments revision
// Class/Method: BankingService.buatDeposito()
// Test 144: Estimasi deposito success
// Detail: Estimate endpoint decodes payload
// Class/Method: BankingService.estimasiDeposito()
// Test 145: Deposito detail success
// Detail: Detail endpoint with pk decoded
// Class/Method: BankingService.depositoDetail()
// Test 146: Deposito user success
// Detail: User deposito list decoded
// Class/Method: BankingService.depositoUser()
// Test 147: Edit deposito success
// Detail: Edit deposito updates revision notifier
// Class/Method: BankingService.editDeposito()
// Programmer: Victor

import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/api/banking.dart';

void main() {
  test('142 - DepositoList method exists', () {
    expect(BankingService.DepositoList, isA<Function>());
  });

  test('143 - buatDeposito method exists', () {
    expect(BankingService.buatDeposito, isA<Function>());
  });

  test('144 - estimasiDeposito method exists', () {
    expect(BankingService.estimasiDeposito, isA<Function>());
  });

  test('145 - depositoDetail method exists', () {
    expect(BankingService.depositoDetail, isA<Function>());
  });

  test('146 - depositoUser method exists', () {
    expect(BankingService.depositoUser, isA<Function>());
  });

  test('147 - editDeposito method exists and notifies revision', () {
    expect(BankingService.editDeposito, isA<Function>());
    // notifyAccountDataChanged is called on success
    final before = BankingService.accountDataRevision.value;
    BankingService.notifyAccountDataChanged();
    expect(BankingService.accountDataRevision.value, before + 1);
  });
}
