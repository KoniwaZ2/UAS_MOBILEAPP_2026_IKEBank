import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/screens/auth/register/ktp_camera_screen.dart';

void main() {
  testWidgets('25 - KtpCameraScreen renders correctly with camera UI', (
    WidgetTester tester,
  ) async {
    // Arrange: pump KtpCameraScreen
    await tester.pumpWidget(
      const MaterialApp(
        home: KtpCameraScreen(
          phone: '081234567890',
          email: 'test@example.com',
          reference: 'test-ref-123',
        ),
      ),
    );

    expect(find.byType(KtpCameraScreen), findsOneWidget);

    expect(find.byIcon(Icons.camera_alt), findsOneWidget);

    expect(find.byType(GestureDetector), findsWidgets);

    expect(find.text('Pastikan KTP berada di dalam bingkai'), findsOneWidget);
  });
}
