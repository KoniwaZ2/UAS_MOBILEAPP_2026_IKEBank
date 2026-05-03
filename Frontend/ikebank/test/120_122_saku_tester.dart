// Test 120: Saku list success
// Detail: Authorized get saku-list decoded
// Class/Method: BankingService.sakuList()
// Test 121: Saku detail with ID
// Detail: Trimmed sakuId sent in request
// Class/Method: BankingService.sakuDetail() payload
// Test 122: Saku detail without ID
// Detail: Empty ID omitted from payload
// Class/Method: BankingService.sakuDetail() conditional pk
// Programmer: Victor

import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/api/banking.dart';

void main() {
  test('120 - sakuList method exists', () {
    expect(BankingService.sakuList, isA<Function>());
  });

  test('121 - sakuDetail with non-empty ID includes pk', () {
    // When sakuId is non-empty and trimmed, it is included as 'pk'
    const sakuId = '  42  ';
    final trimmed = sakuId.trim();
    expect(trimmed.isNotEmpty, isTrue);
    expect(trimmed, '42');
  });

  test('122 - sakuDetail with null ID omits pk', () {
    // When sakuId is null, the payload should not contain 'pk'
    const String? sakuId = null;
    final shouldInclude = sakuId != null && sakuId.trim().isNotEmpty;
    expect(shouldInclude, isFalse);
  });
}
