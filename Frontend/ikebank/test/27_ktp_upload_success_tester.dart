import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/screens/auth/register/isi_data_screen.dart';
import 'package:ikebank/screens/auth/register/review_foto_ktp_screen.dart';

File _createTempFile() {
  final directory = Directory.systemTemp.createTempSync('ikebank_27_');
  final file = File('${directory.path}/ktp.jpg');
  file.writeAsStringSync('ktp');
  return file;
}

void main() {
  testWidgets('27 - upload KTP success navigates to isi data screen', (
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
            expect(file.path, imageFile.path);
            expect(reference, 'test-ref-123');
            return <String, dynamic>{
              'prefill_identity': <String, dynamic>{'name': 'Victor'},
            };
          },
        ),
      ),
    );

    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();

    expect(find.byType(IsiDataScreen), findsOneWidget);

    final isiDataScreen = tester.widget<IsiDataScreen>(
      find.byType(IsiDataScreen),
    );
    expect(isiDataScreen.prefillIdentity['name'], 'Victor');
  });
}
