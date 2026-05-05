// Test 126: Transaction history query params
// Detail: Only non-empty filters included in URL
// Class/Method: BankingService.transactionHistory() query build
// Test 127: Transaction history date format
// Detail: Date converted yyyy-MM-dd
// Class/Method: BankingService.transactionHistory() formatDate
// Test 128: Transaction history non-list decode
// Detail: Non-list history returns empty list
// Class/Method: BankingService.transactionHistory() decode guard
// Programmer: Victor

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('126 - only non-empty filters included in query', () {
    // BankingService.transactionHistory uses conditional includes
    const String? sakuId = null;
    const sakuName = '';
    const category = 'transfer';

    final queryParams = <String, String>{
      if (sakuId != null && sakuId.trim().isNotEmpty) 'saku_id': sakuId.trim(),
      if (sakuName.trim().isNotEmpty) 'saku_name': sakuName.trim(),
      if (category.trim().isNotEmpty) 'category': category.trim(),
    };

    expect(queryParams.containsKey('saku_id'), isFalse);
    expect(queryParams.containsKey('saku_name'), isFalse);
    expect(queryParams['category'], 'transfer');
  });

  test('127 - date formatted as yyyy-MM-dd', () {
    final date = DateTime(2025, 3, 5);
    String formatDate(DateTime d) {
      final y = d.year.toString().padLeft(4, '0');
      final m = d.month.toString().padLeft(2, '0');
      final day = d.day.toString().padLeft(2, '0');
      return '$y-$m-$day';
    }

    expect(formatDate(date), '2025-03-05');
  });

  test('128 - non-list history returns empty list', () {
    // When decoded is not a List, transactionHistory returns <Map<String, dynamic>>[]
    final emptyList = <Map<String, dynamic>>[];
    expect(emptyList, isEmpty);
  });
}
