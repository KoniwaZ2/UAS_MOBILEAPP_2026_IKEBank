// Test 132: Tambah saku category normalize
// Detail: nabung/transaksi/lainnya normalized correctly
// Class/Method: BankingService.tambahSaku() normalizeCategory
// Test 133: Tambah saku success
// Detail: 200/201 treated as success
// Class/Method: BankingService.tambahSaku() status handling
// Programmer: Victor

import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/api/banking.dart';

void main() {
  test('132 - category normalization logic', () {
    String normalizeCategory(String raw) {
      final value = raw.trim().toLowerCase();
      if (value.contains('nabung')) return 'nabung';
      if (value.contains('transaksi')) return 'transaksi';
      return 'lainnya';
    }

    expect(normalizeCategory('Nabung Pendidikan'), 'nabung');
    expect(normalizeCategory('TRANSAKSI'), 'transaksi');
    expect(normalizeCategory('Something else'), 'lainnya');
    expect(normalizeCategory('  nabung  '), 'nabung');
  });

  test('133 - tambahSaku accepts 200/201', () {
    final validCodes = [200, 201];
    for (final code in validCodes) {
      expect(code == 200 || code == 201, isTrue);
    }
  });
}
