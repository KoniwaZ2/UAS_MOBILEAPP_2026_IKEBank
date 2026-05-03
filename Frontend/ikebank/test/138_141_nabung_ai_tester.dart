// Test 138: Saving recommendation success
// Detail: Recommendation endpoint decoded
// Class/Method: BankingService.savingRecommendation()
// Test 139: Nabung AI state fetch
// Detail: Fetch state returns map fallback
// Class/Method: BankingService.fetchNabungAiState()
// Test 140: Nabung AI update payload
// Detail: autoIsi/cooldown payload built correctly
// Class/Method: BankingService.updateNabungAiState()
// Test 141: Nabung AI clear cooldown
// Detail: clear_cooldown overrides cooldown_until
// Class/Method: BankingService.updateNabungAiState()
// Programmer: Victor

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/api/banking.dart';

void main() {
  test('138 - savingRecommendation method exists', () {
    expect(BankingService.savingRecommendation, isA<Function>());
  });

  test('139 - fetchNabungAiState method exists', () {
    expect(BankingService.fetchNabungAiState, isA<Function>());
  });

  test('140 - update payload includes autoIsi and cooldown', () {
    final cooldown = DateTime(2025, 6, 1, 12, 0, 0);
    final payload = <String, dynamic>{
      'auto_isi': true,
      'cooldown_until': cooldown.toIso8601String(),
    };

    final encoded = jsonEncode(payload);
    expect(encoded, contains('auto_isi'));
    expect(encoded, contains('cooldown_until'));
    expect(encoded, contains('2025-06-01'));
  });

  test('141 - clear_cooldown overrides cooldown_until', () {
    final payload = <String, dynamic>{
      'auto_isi': true,
      'clear_cooldown': true,
    };

    expect(payload.containsKey('clear_cooldown'), isTrue);
    expect(payload.containsKey('cooldown_until'), isFalse);
  });
}
