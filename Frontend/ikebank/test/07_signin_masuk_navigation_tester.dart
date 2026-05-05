// Test 07: SignIn to Masuk navigation
// Detail: Tap Masuk opens MasukScreen
// Class/Method: SignIn CTA onPressed Masuk
// Programmer: Victor

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/screens/auth/signin.dart';
import 'package:ikebank/screens/auth/login/masuk_screen.dart';

void main() {
  testWidgets('07 - Tap Masuk button navigates to MasukScreen',
      (WidgetTester tester) async {
    // Arrange: pump SignIn inside a MaterialApp
    await tester.pumpWidget(
      const MaterialApp(home: SignIn()),
    );

    // Act: find the TextButton containing 'Masuk' and tap it
    final masukButton = find.widgetWithText(TextButton, 'Masuk');
    expect(masukButton, findsOneWidget);
    await tester.ensureVisible(masukButton);
    await tester.tap(masukButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Assert: MasukScreen should now be visible
    expect(find.byType(MasukScreen), findsOneWidget);
  });
}
