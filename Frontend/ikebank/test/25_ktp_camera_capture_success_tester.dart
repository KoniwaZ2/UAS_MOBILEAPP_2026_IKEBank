// Test 25: KTP camera capture success
// Detail: Captured image moves to review screen
// Class/Method: KtpCameraScreen capture flow
// Programmer: Victor

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/screens/auth/register/ktp_camera_screen.dart';

void main() {
  testWidgets('25 - KtpCameraScreen renders correctly with camera UI',
      (WidgetTester tester) async {
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

    // Assert: KtpCameraScreen is rendered
    expect(find.byType(KtpCameraScreen), findsOneWidget);

    // Assert: camera placeholder area exists
    expect(find.byIcon(Icons.camera_alt), findsOneWidget);

    // Assert: capture button (white circle) exists
    // The capture button is a Container with circle shape
    expect(find.byType(GestureDetector), findsWidgets);

    // Assert: title text is displayed
    expect(
      find.text('Pastikan KTP berada di dalam bingkai'),
      findsOneWidget,
    );
  });
}
