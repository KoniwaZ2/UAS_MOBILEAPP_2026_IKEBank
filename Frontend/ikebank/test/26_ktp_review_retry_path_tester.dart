import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/screens/auth/register/ktp_camera_screen.dart';
import 'package:ikebank/screens/auth/register/review_foto_ktp_screen.dart';

void main() {
  testWidgets('26 - Ambil Foto Ulang returns to camera', (
    WidgetTester tester,
  ) async {
    final navigatorKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: const KtpCameraScreen(
          phone: '081234567890',
          email: 'test@example.com',
          reference: 'test-ref-123',
        ),
      ),
    );

    navigatorKey.currentState!.push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const ReviewFotoKtpScreen(
          phone: '081234567890',
          email: 'test@example.com',
          reference: 'test-ref-123',
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(ReviewFotoKtpScreen), findsOneWidget);
    expect(find.text('Ambil Foto Ulang'), findsOneWidget);

    await tester.tap(find.text('Ambil Foto Ulang'));
    await tester.pumpAndSettle();

    expect(find.byType(ReviewFotoKtpScreen), findsNothing);
    expect(find.byType(KtpCameraScreen), findsOneWidget);
  });
}
