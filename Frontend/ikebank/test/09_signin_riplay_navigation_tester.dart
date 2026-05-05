// Test 09: SignIn to RIPLAY navigation
// Detail: Tap RIPLAY opens RiplayScreen
// Class/Method: SignIn tap handler RIPLAY
// Programmer: Victor

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/screens/auth/signin.dart';
import 'package:ikebank/screens/auth/riplay.dart';

void main() {
  testWidgets('09 - Tap RIPLAY text navigates to RiplayScreen',
      (WidgetTester tester) async {
    // Arrange: pump SignIn inside a MaterialApp
    await tester.pumpWidget(
      const MaterialApp(home: SignIn()),
    );

    // Act: find the RIPLAY link text via GestureDetector and tap it
    final riplayText = find.textContaining('RIPLAY');
    expect(riplayText, findsOneWidget);
    await tester.ensureVisible(riplayText);
    await tester.tap(riplayText, warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Assert: RiplayScreen should now be visible
    expect(find.byType(RiplayScreen), findsOneWidget);
  });
}
