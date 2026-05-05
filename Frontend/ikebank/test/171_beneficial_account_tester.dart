// Test 171: BeneficialAccount parse robustness
// Detail: All fields parsed with safe string read
// Class/Method: BeneficialAccount.fromJson()
// Programmer: Victor

import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/models/beneficial_account.dart';

void main() {
  test('171 - all fields parsed with safe string read', () {
    final json = <String, dynamic>{
      'id': '1',
      'account_number': '1234567890',
      'bank_name': 'IKE Bank',
      'account_holder_name': 'Victor',
      'added_at': '2025-01-01',
    };
    final account = BeneficialAccount.fromJson(json);
    expect(account.id, '1');
    expect(account.accountNumber, '1234567890');
    expect(account.bankName, 'IKE Bank');
    expect(account.accountHolderName, 'Victor');
    expect(account.addedAt, '2025-01-01');
  });

  test('171b - missing fields default to empty string', () {
    final json = <String, dynamic>{};
    final account = BeneficialAccount.fromJson(json);
    expect(account.id, '');
    expect(account.accountNumber, '');
    expect(account.bankName, '');
    expect(account.accountHolderName, '');
    expect(account.addedAt, '');
  });

  test('171c - toString includes all fields', () {
    final account = const BeneficialAccount(
      id: '1',
      accountNumber: '1234567890',
      bankName: 'IKE Bank',
      accountHolderName: 'Victor',
      addedAt: '2025-01-01',
    );
    final str = account.toString();
    expect(str, contains('1234567890'));
    expect(str, contains('IKE Bank'));
    expect(str, contains('Victor'));
  });
}
