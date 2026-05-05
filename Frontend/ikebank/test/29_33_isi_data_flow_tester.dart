import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/models/register_flow_data.dart';
import 'package:ikebank/screens/auth/login/verifikasi_wajah_screen.dart';
import 'package:ikebank/screens/auth/register/isi_data_screen.dart';

File _createTempFile() {
  final directory = Directory.systemTemp.createTempSync('ikebank_29_');
  final file = File('${directory.path}/ktp.jpg');
  file.writeAsStringSync('ktp');
  return file;
}

Future<void> _fillIsiDataForm(WidgetTester tester) async {
  final fields = find.byType(TextFormField);
  final scrollable = find.byType(Scrollable).first;

  await tester.scrollUntilVisible(fields.at(0), 200, scrollable: scrollable);
  await tester.enterText(fields.at(0), 'Victor Marlino');

  await tester.scrollUntilVisible(fields.at(1), 200, scrollable: scrollable);
  await tester.enterText(fields.at(1), '1234567890123456');

  await tester.scrollUntilVisible(fields.at(2), 200, scrollable: scrollable);
  await tester.enterText(fields.at(2), '26-02-2007');

  await tester.scrollUntilVisible(fields.at(3), 200, scrollable: scrollable);
  await tester.enterText(fields.at(3), 'Jakarta');

  await tester.scrollUntilVisible(fields.at(4), 200, scrollable: scrollable);
  await tester.enterText(fields.at(4), 'Ibu');
}

void main() {
  testWidgets('29 - prefill correctness maps server data into controllers', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: IsiDataScreen(
          phone: '081234567890',
          email: 'test@example.com',
          ktpImageFile: _createTempFile(),
          reference: 'test-ref-123',
          prefillIdentity: const <String, dynamic>{
            'name': 'Prefilled Name',
            'nik': '1234567890123456',
            'born_date': '26-02-2007',
            'gender': 'male',
            'address': 'Prefilled Address',
            'religion': 'Islam',
            'mother_name': 'Prefilled Mother',
          },
        ),
      ),
    );

    expect(find.text('Prefilled Name'), findsOneWidget);
    expect(find.text('1234567890123456'), findsOneWidget);
    expect(find.text('26-02-2007'), findsOneWidget);
    expect(find.text('Prefilled Address'), findsOneWidget);
    expect(find.text('Prefilled Mother'), findsOneWidget);
  });

  testWidgets('30 - mandatory fields block submit', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: IsiDataScreen(
          phone: '081234567890',
          email: 'test@example.com',
          ktpImageFile: _createTempFile(),
          reference: 'test-ref-123',
          prefillIdentity: const <String, dynamic>{
            'gender': 'male',
            'religion': 'Islam',
          },
        ),
      ),
    );

    final submitButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Lanjut'),
    );
    submitButton.onPressed!();
    await tester.pump();

    expect(find.text('Bagian ini harus diisi'), findsWidgets);
  });

  testWidgets('31 - date formatting is passed to next screen', (
    WidgetTester tester,
  ) async {
    RegisterFlowData? capturedFlowData;

    await tester.pumpWidget(
      MaterialApp(
        home: IsiDataScreen(
          phone: '081234567890',
          email: 'test@example.com',
          ktpImageFile: _createTempFile(),
          reference: 'test-ref-123',
          prefillIdentity: const <String, dynamic>{
            'name': 'Victor Marlino',
            'nik': '1234567890123456',
            'born_date': '26-02-2007',
            'gender': 'male',
            'religion': 'Islam',
            'address': 'Jakarta',
            'mother_name': 'Ibu',
          },
          onContinue: (flowData) {
            capturedFlowData = flowData;
          },
        ),
      ),
    );

    final submitButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Lanjut'),
    );
    submitButton.onPressed!();
    await tester.pump();

    expect(capturedFlowData?.bornDate, '2007-02-26');
  });

  testWidgets('32 - gender mapping is passed to next screen', (
    WidgetTester tester,
  ) async {
    RegisterFlowData? capturedFlowData;

    await tester.pumpWidget(
      MaterialApp(
        home: IsiDataScreen(
          phone: '081234567890',
          email: 'test@example.com',
          ktpImageFile: _createTempFile(),
          reference: 'test-ref-123',
          prefillIdentity: const <String, dynamic>{
            'name': 'Victor Marlino',
            'nik': '1234567890123456',
            'born_date': '26-02-2007',
            'gender': 'male',
            'religion': 'Islam',
            'address': 'Jakarta',
            'mother_name': 'Ibu',
          },
          onContinue: (flowData) {
            capturedFlowData = flowData;
          },
        ),
      ),
    );

    final submitButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Lanjut'),
    );
    submitButton.onPressed!();
    await tester.pump();

    expect(capturedFlowData?.gender, 'MALE');
  });

  testWidgets('33 - valid submit forwards to face verification', (
    WidgetTester tester,
  ) async {
    RegisterFlowData? capturedFlowData;

    await tester.pumpWidget(
      MaterialApp(
        home: IsiDataScreen(
          phone: '081234567890',
          email: 'test@example.com',
          ktpImageFile: _createTempFile(),
          reference: 'test-ref-123',
          prefillIdentity: const <String, dynamic>{
            'name': 'Victor Marlino',
            'nik': '1234567890123456',
            'born_date': '26-02-2007',
            'gender': 'male',
            'religion': 'Islam',
            'address': 'Jakarta',
            'mother_name': 'Ibu',
          },
          onContinue: (flowData) {
            capturedFlowData = flowData;
          },
        ),
      ),
    );

    final submitButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Lanjut'),
    );
    submitButton.onPressed!();
    await tester.pump();

    expect(capturedFlowData, isNotNull);
  });
}
