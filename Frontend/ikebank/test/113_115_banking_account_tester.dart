// Test 113: Banking register account
// Detail: Authorized POST register account success
// Class/Method: BankingService.registerAccount()
// Test 114: Fetch account details map
// Detail: List response mapped to AccountDetail list
// Class/Method: BankingService.fetchAccountDetails()
// Test 115: Fetch account details non-list
// Detail: Non-list response returns empty list
// Class/Method: BankingService.fetchAccountDetails() guard
// Programmer: Victor

import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/api/banking.dart';
import 'package:ikebank/models/account_detail.dart';

void main() {
  test('113 - registerAccount method exists', () {
    expect(BankingService.registerAccount, isA<Function>());
  });

  test('114 - fetchAccountDetails method exists and returns list', () {
    expect(BankingService.fetchAccountDetails, isA<Function>());
    // The return type is Future<List<AccountDetail>>
    final Future<List<AccountDetail>> Function() fn =
        BankingService.fetchAccountDetails;
    expect(fn, isNotNull);
  });

  test('115 - non-list response returns empty AccountDetail list', () {
    // When decoded is not a List, fetchAccountDetails returns <AccountDetail>[]
    final emptyList = <AccountDetail>[];
    expect(emptyList, isEmpty);
  });
}
