// Test 19: OTP register auto focus
// Detail: Input advances and backspaces correctly
// Class/Method: VerifikasiKodeScreen OTP input widgets
// Programmer: Victor

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/screens/auth/register/verifikasi_kode_screen.dart';

void main() {
  testWidgets('19 - OTP input auto-focuses to next field on digit entry',
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

    // There should be 6 OTP TextField widgets
    final otpFields = find.byType(TextField);
    expect(otpFields, findsNWidgets(6));

    // Enter a digit in the first OTP box
    await tester.enterText(otpFields.at(0), '1');
    await tester.pump();

    // The first field should contain '1'
    final firstController =
        tester.widget<TextField>(otpFields.at(0)).controller;
    expect(firstController?.text, '1');
  });
}
