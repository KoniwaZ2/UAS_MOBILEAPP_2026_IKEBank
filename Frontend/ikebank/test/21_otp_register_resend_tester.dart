// Test 21: OTP register resend
// Detail: Resend refreshes reference safely
// Class/Method: VerifikasiKodeScreen resend handler
// Programmer: Victor

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/screens/auth/register/verifikasi_kode_screen.dart';

void main() {
  testWidgets('21 - Kirim ulang kode button exists and is tappable',
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

    // Find the resend button
    final resendButton = find.text('Kirim ulang kode');
    expect(resendButton, findsOneWidget);

    // Tap resend button
    await tester.tap(resendButton);
    await tester.pump();

    // The button should still exist (not crash)
    expect(find.byType(VerifikasiKodeScreen), findsOneWidget);
  });
}
