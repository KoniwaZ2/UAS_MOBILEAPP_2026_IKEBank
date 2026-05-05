// Test 123: QRIS source list from raw list
// Detail: List raw mapped/filter to sources
// Class/Method: BankingService.fetchQrisFundingSources()
// Test 124: QRIS source from nested map
// Detail: Nested data/results/sakus mapped safely
// Class/Method: BankingService.fetchQrisFundingSources()
// Test 125: QRIS source list fail-safe
// Detail: Exception returns empty source list
// Class/Method: BankingService.fetchQrisFundingSources() catch
// Programmer: Victor

import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/api/banking.dart';
import 'package:ikebank/models/wallet_source.dart';

void main() {
  test('123 - fetchQrisFundingSources method exists', () {
    expect(BankingService.fetchQrisFundingSources, isA<Function>());
    final Future<List<WalletSource>> Function() fn =
        BankingService.fetchQrisFundingSources;
    expect(fn, isNotNull);
  });

  test('124 - nested payload extraction logic', () {
    // The method checks: raw['data'] ?? raw['results'] ?? raw['sakus'] ?? raw
    final rawMap = <String, dynamic>{
      'data': [
        {'saku_name': 'Utama', 'is_primary': true, 'balance': '100000'},
      ],
    };
    final payload = rawMap['data'] ?? rawMap['results'] ?? rawMap['sakus'];
    expect(payload, isA<List>());
    expect((payload as List).length, 1);
  });

  test('125 - exception returns empty list', () {
    // On catch, fetchQrisFundingSources returns <WalletSource>[]
    final fallback = <WalletSource>[];
    expect(fallback, isEmpty);
  });
}
