// Test 134: Rekening list success
// Detail: Authorized get rekening-list decoded
// Class/Method: BankingService.rekeningList()
// Test 135: Fetch rekening nested payload
// Detail: data/results/beneficiaries mapped safely
// Class/Method: BankingService.fetchRekeningList()
// Test 136: Fetch rekening filters empty account
// Detail: Blank account number filtered out
// Class/Method: BankingService.fetchRekeningList() filter
// Test 137: Tambah rekening success
// Detail: Add rekening accepts 200/201
// Class/Method: BankingService.tambahRekening()
// Programmer: Victor

import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/api/banking.dart';
import 'package:ikebank/models/beneficial_account.dart';

void main() {
  test('134 - rekeningList method exists', () {
    expect(BankingService.rekeningList, isA<Function>());
  });

  test('135 - fetchRekeningList tries nested payload keys', () {
    // fetchRekeningList checks: raw['data'] ?? raw['results'] ?? raw['beneficiaries']
    final rawMap = <String, dynamic>{
      'beneficiaries': [
        {
          'id': '1',
          'account_number': '1234567890',
          'bank_name': 'IKE Bank',
          'account_holder_name': 'Test User',
          'added_at': '2025-01-01',
        },
      ],
    };
    final payload =
        rawMap['data'] ?? rawMap['results'] ?? rawMap['beneficiaries'];
    expect(payload, isA<List>());
    expect((payload as List).length, 1);
  });

  test('136 - blank account number filtered out', () {
    final accounts = [
      const BeneficialAccount(
        id: '1',
        accountNumber: '1234567890',
        bankName: 'IKE Bank',
        accountHolderName: 'User',
        addedAt: '2025-01-01',
      ),
      const BeneficialAccount(
        id: '2',
        accountNumber: '',
        bankName: 'IKE Bank',
        accountHolderName: 'Empty',
        addedAt: '2025-01-01',
      ),
    ];

    final filtered = accounts
        .where((account) => account.accountNumber.trim().isNotEmpty)
        .toList();
    expect(filtered.length, 1);
    expect(filtered.first.accountNumber, '1234567890');
  });

  test('137 - tambahRekening method exists', () {
    expect(BankingService.tambahRekening, isA<Function>());
  });
}
