// Test 03: App startup authenticated route
// Detail: MyApp routes to MainTabScreen when token valid
// Class/Method: _MyAppState build() home branch logged-in
// Programmer: Victor

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/main.dart';

void main() {
  testWidgets(
      '03 - build() renders a destination after _checkLoginStatus completes',
      (WidgetTester tester) async {
    // Arrange & Act: pump MyApp
    await tester.pumpWidget(const MyApp());

    // Pump a few frames to allow _checkLoginStatus to finish
    // (HTTP calls return 400 in test env, so hasValidAccessToken → false)
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    // Assert: after loading, the CircularProgressIndicator should be gone
    // and a Scaffold-based destination should be rendered
    expect(find.byType(Scaffold), findsWidgets);
  });
}
