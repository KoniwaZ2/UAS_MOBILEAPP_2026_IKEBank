// Test 12: Register email format
// Detail: Invalid email shows specific validation
// Class/Method: RegisterScreen _isValidEmail()
// Programmer: Victor

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/screens/auth/register/register_screen.dart';

void main() {
  testWidgets(
      '12 - Invalid email format shows format validation SnackBar',
      (WidgetTester tester) async {
    // Arrange: pump RegisterScreen
    await tester.pumpWidget(
      const MaterialApp(home: RegisterScreen()),
    );

    // Act: enter phone and an invalid email, then tap Lanjut
    final textFields = find.byType(TextField);
    // First TextField = phone, Second = email
    await tester.enterText(textFields.at(0), '081234567890');
    await tester.enterText(textFields.at(1), 'invalid-email');

    final lanjutButton = find.text('Lanjut');
    await tester.ensureVisible(lanjutButton);
    await tester.tap(lanjutButton);
    await tester.pump();

    // Assert: SnackBar with email format validation should appear
    expect(
      find.text('Format email tidak valid.'),
      findsOneWidget,
    );
  });
}
