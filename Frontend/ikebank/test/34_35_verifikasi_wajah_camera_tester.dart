import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/screens/auth/login/face_recog_screen.dart';
import 'package:ikebank/screens/auth/login/verifikasi_wajah_screen.dart';

void main() {
  testWidgets('34 - guide CTA opens face recognition', (
    WidgetTester tester,
  ) async {
    var openedFaceRecog = false;

    await tester.pumpWidget(
      MaterialApp(
        home: VerifikasiWajahScreen(
          isFromRegister: true,
          onOpenFaceRecog: () {
            openedFaceRecog = true;
          },
        ),
      ),
    );

    final submitButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Ambil selfie'),
    );
    submitButton.onPressed!();

    expect(openedFaceRecog, isTrue);
  });

  testWidgets('35 - camera unavailable shows graceful error', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1600));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      MaterialApp(
        home: FaceRecogScreen(availableCamerasOverride: () async => []),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Kamera tidak tersedia'), findsOneWidget);
  });
}
