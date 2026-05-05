// Test 10: Register onboarding transition
// Detail: BuatAkunScreen lanjut opens RegisterScreen
// Class/Method: BuatAkunScreen submit action
// Programmer: Victor

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/screens/auth/register/buat_akun_screen.dart';
import 'package:ikebank/screens/auth/register/register_screen.dart';

void main() {
  testWidgets(
      '10 - Tap Lanjut on BuatAkunScreen navigates to RegisterScreen',
      (WidgetTester tester) async {
    // Arrange: pump BuatAkunScreen inside a MaterialApp
    await tester.pumpWidget(
      const MaterialApp(home: BuatAkunScreen()),
    );

    // Act: find and tap the 'Lanjut' button
    final lanjutButton = find.text('Lanjut');
    expect(lanjutButton, findsOneWidget);
    await tester.ensureVisible(lanjutButton);
    await tester.tap(lanjutButton);
    await tester.pumpAndSettle();

    // Assert: RegisterScreen should now be visible
    expect(find.byType(RegisterScreen), findsOneWidget);
  });
}
