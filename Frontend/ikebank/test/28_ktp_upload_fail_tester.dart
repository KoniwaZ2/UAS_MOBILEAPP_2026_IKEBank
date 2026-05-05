import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/screens/auth/register/review_foto_ktp_screen.dart';

File _createTempFile() {
  final directory = Directory.systemTemp.createTempSync('ikebank_28_');
  final file = File('${directory.path}/ktp.jpg');
  file.writeAsStringSync('ktp');
  return file;
}

void main() {
  testWidgets('28 - upload KTP failure shows snackbar', (
    WidgetTester tester,
  ) async {
    final imageFile = _createTempFile();

    await tester.pumpWidget(
      MaterialApp(
        home: ReviewFotoKtpScreen(
          imageFile: imageFile,
          phone: '081234567890',
          email: 'test@example.com',
          reference: 'test-ref-123',
          uploadKtpOverride: (file, reference) async {
            throw Exception('Upload gagal: server down');
          },
        ),
      ),
    );

    await tester.tap(find.text('Lanjut'));
    await tester.pump();

    expect(find.text('Upload gagal: server down'), findsOneWidget);
  });
}
