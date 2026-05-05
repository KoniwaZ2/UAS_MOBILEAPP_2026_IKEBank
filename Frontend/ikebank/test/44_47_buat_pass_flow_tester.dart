import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/models/register_flow_data.dart';
import 'package:ikebank/screens/auth/register/buat_pass_screen.dart';
import 'package:ikebank/screens/auth/register/buat_pin_screen.dart';
import 'package:ikebank/utils/registration_rules.dart';

File _createTempFile() {
  final directory = Directory.systemTemp.createTempSync('ikebank_44_');
  final file = File('${directory.path}/ktp.jpg');
  file.writeAsStringSync('ktp');
  return file;
}

RegisterFlowData _flowData() {
  return RegisterFlowData(
    phoneNumber: '081234567890',
    email: 'test@example.com',
    otpReference: 'ref-123',
    ktpFile: _createTempFile(),
  );
}

void main() {
  test('44 - password complexity rules', () {
    expect(validatePassword(''), 'Password wajib diisi');
    expect(validatePassword('short'), 'Password minimal 8 karakter');
    expect(validatePassword('lowercase1'), 'Password harus punya huruf besar');
    expect(validatePassword('UPPERCASE1'), 'Password harus punya huruf kecil');
    expect(validatePassword('NoNumber'), 'Password harus punya angka');
    expect(validatePassword('ValidPass1'), isNull);
  });

  test('45 - confirm password mismatch is rejected', () {
    expect(
      validateConfirmPassword('different', 'ValidPass1'),
      'Konfirmasi password tidak sama',
    );
  });

  testWidgets('46 - visibility toggle changes obscure state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: BuatPassScreen(flowData: _flowData())),
    );

    expect(find.byIcon(Icons.visibility_off_outlined), findsWidgets);

    await tester.tap(find.byIcon(Icons.visibility_off_outlined).first);
    await tester.pump();

    expect(find.byIcon(Icons.visibility_outlined), findsWidgets);
  });

  testWidgets('47 - password is passed through flowData', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: BuatPassScreen(flowData: _flowData())),
    );

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'ValidPass1');
    await tester.enterText(fields.at(1), 'ValidPass1');
    final submitButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Lanjut'),
    );
    submitButton.onPressed!();
    await tester.pumpAndSettle();

    expect(find.byType(BuatPinScreen), findsOneWidget);

    final nextScreen = tester.widget<BuatPinScreen>(find.byType(BuatPinScreen));
    expect(nextScreen.flowData?.password, 'ValidPass1');
  });
}
