// Test 23: OTP register verify fail
// Detail: Wrong OTP shows backend message
// Class/Method: VerifikasiKodeScreen catch verify
// Programmer: Victor

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/screens/auth/register/verifikasi_kode_screen.dart';

void main() {
  testWidgets('23 - Wrong OTP shows error SnackBar from catch block',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: VerifikasiKodeScreen(
          email: 'test@example.com',
          phone: '081234567890',
          reference: 'test-ref-123',
        ),
      ),
    );

    // Enter all 6 digits
    final otpFields = find.byType(TextField);
    await tester.enterText(otpFields.at(0), '1');
    await tester.enterText(otpFields.at(1), '2');
    await tester.enterText(otpFields.at(2), '3');
    await tester.enterText(otpFields.at(3), '4');
    await tester.enterText(otpFields.at(4), '5');
    await tester.enterText(otpFields.at(5), '6');
    await tester.pump();

    // Tap Lanjut to submit OTP (will fail – no server in test env)
    final lanjutButton = find.text('Lanjut');
    await tester.ensureVisible(lanjutButton);
    await tester.tap(lanjutButton);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 5));

    // Assert: SnackBar should appear with error message
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
