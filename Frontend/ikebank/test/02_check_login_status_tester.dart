// Test 02: App startup loading gate (part 2)
// Detail: MyApp shows loader before auth check
// Class/Method: _MyAppState._checkLoginStatus()
// Programmer: Victor

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/main.dart';

void main() {
  testWidgets(
      '02 - _checkLoginStatus() shows CircularProgressIndicator while loading',
      (WidgetTester tester) async {
    // Arrange & Act: pump MyApp – initially _isLoading is true
    await tester.pumpWidget(const MyApp());

    // Assert: while _checkLoginStatus runs, a loader should be visible
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
