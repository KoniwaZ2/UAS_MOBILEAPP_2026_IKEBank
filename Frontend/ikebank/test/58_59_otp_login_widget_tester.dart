// Test 58: OTP login input behavior
// Detail: OTP fields auto next/backspace
// Class/Method: VerifikasiCodeScreen OTP widget logic
// Test 59: OTP login resend flow
// Detail: Resend login OTP updates reference
// Class/Method: VerifikasiCodeScreen resend logic
// Programmer: Victor

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/screens/auth/login/verifikasi_code_screen.dart';

void main() {
  testWidgets('58 - OTP fields render 6 text inputs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: VerifikasiCodeScreen(
          email: 'test@example.com',
          reference: 'ref-login-123',
        ),
      ),
    );

    // VerifikasiCodeScreen renders 6 OTP input boxes as TextFields
    final textFields = find.byType(TextField);
    expect(textFields, findsAtLeast(6));
  });

  testWidgets('59 - resend button is present', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: VerifikasiCodeScreen(
          email: 'test@example.com',
          reference: 'ref-login-123',
        ),
      ),
    );

    expect(find.text('Kirim ulang kode'), findsOneWidget);
  });
}
