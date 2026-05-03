// Test 15: Register check endpoint error
// Detail: Backend check error shown to user
// Class/Method: RegisterScreen try/catch check()
// Programmer: Victor

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/screens/auth/register/register_screen.dart';

void main() {
  testWidgets(
      '15 - Backend check error is displayed via SnackBar when API fails',
      (WidgetTester tester) async {
    // Arrange: pump RegisterScreen
    await tester.pumpWidget(
      const MaterialApp(home: RegisterScreen()),
    );

    // Act: enter valid phone and email, then tap Lanjut
    // The API call will fail in test environment (no server), triggering the catch block
    final textFields = find.byType(TextField);
    await tester.enterText(textFields.at(0), '081234567890');
    await tester.enterText(textFields.at(1), 'test@example.com');

    final lanjutButton = find.text('Lanjut');
    await tester.ensureVisible(lanjutButton);
    await tester.tap(lanjutButton);

    // Wait for async operation to complete (API call will fail)
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 5));

    // Assert: A SnackBar should appear with the error message from catch block
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
