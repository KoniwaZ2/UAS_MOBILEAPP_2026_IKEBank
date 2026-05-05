import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/screens/auth/register/verifikasi_kode_screen.dart';

void main() {
  testWidgets('21 - Kirim ulang kode button exists and is tappable', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: VerifikasiKodeScreen(
          email: 'test@example.com',
          phone: '081234567890',
          reference: 'test-ref-123',
        ),
      ),
    );

    final resendButton = find.text('Kirim ulang kode');
    expect(resendButton, findsOneWidget);

    await tester.tap(resendButton);
    await tester.pump();

    expect(find.byType(VerifikasiKodeScreen), findsOneWidget);
  });
}
