import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/models/register_flow_data.dart';
import 'package:ikebank/screens/auth/register/buat_pin_screen.dart';
import 'package:ikebank/utils/pin_rules.dart';

File _createTempFile() {
  final directory = Directory.systemTemp.createTempSync('ikebank_48_');
  final file = File('${directory.path}/ktp.jpg');
  file.writeAsStringSync('ktp');
  return file;
}

RegisterFlowData _flowData({String? password}) {
  return RegisterFlowData(
    phoneNumber: '081234567890',
    email: 'test@example.com',
    otpReference: 'ref-123',
    password: password,
    ktpFile: _createTempFile(),
  );
}

void main() {
  test('48 - PIN length validation rejects short values', () {
    expect(
      validatePinEntry('123', '123'),
      'PIN harus terdiri dari 6 digit angka!',
    );
  });

  test('49 - PIN match validation rejects mismatch', () {
    expect(validatePinEntry('123456', '654321'), 'Konfirmasi PIN tidak cocok!');
  });

  testWidgets('50 - incomplete registration flow is blocked', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: BuatPinScreen()));

    await tester.enterText(find.byType(TextField), '123456123456');
    await tester.pump();
    final submitButton = tester.widget<InkWell>(find.byType(InkWell).first);
    submitButton.onTap!();
    await tester.pump();

    expect(
      find.text('Data registrasi belum lengkap. Ulangi dari awal.'),
      findsOneWidget,
    );
  });

  testWidgets('50b - valid flow data enables registration submit path', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BuatPinScreen(flowData: _flowData(password: 'ValidPass1')),
      ),
    );

    await tester.enterText(find.byType(TextField), '123456123456');
    await tester.pump();

    final button = tester.widget<InkWell>(find.byType(InkWell).first);
    expect(button.onTap, isNotNull);
  });
}
