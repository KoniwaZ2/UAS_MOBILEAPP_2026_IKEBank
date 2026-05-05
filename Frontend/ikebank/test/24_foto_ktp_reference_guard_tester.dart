import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/screens/auth/register/foto_ktp_screen.dart';

void main() {
  testWidgets('24 - Missing reference shows error and blocks camera', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: FotoKtpScreen(
          phone: '081234567890',
          email: 'test@example.com',
          reference: null,
        ),
      ),
    );

    final cameraArea = find.text('Klik untuk mengambil gambar');
    expect(cameraArea, findsOneWidget);
    await tester.tap(cameraArea);
    await tester.pump();

    expect(
      find.text('Reference OTP tidak tersedia. Ulangi verifikasi OTP.'),
      findsOneWidget,
    );
  });

  testWidgets('24b - Empty reference also blocks capture step', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: FotoKtpScreen(
          phone: '081234567890',
          email: 'test@example.com',
          reference: '',
        ),
      ),
    );

    final cameraArea = find.text('Klik untuk mengambil gambar');
    await tester.tap(cameraArea);
    await tester.pump();

    expect(
      find.text('Reference OTP tidak tersedia. Ulangi verifikasi OTP.'),
      findsOneWidget,
    );
  });
}
