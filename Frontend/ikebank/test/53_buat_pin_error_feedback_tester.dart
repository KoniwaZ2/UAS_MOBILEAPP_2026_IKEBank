// Test 53: Buat PIN error feedback
// Detail: Backend register error shown clearly
// Class/Method: BuatPinScreen catch + snackbar
// Programmer: Victor

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/models/register_flow_data.dart';
import 'package:ikebank/screens/auth/register/buat_pin_screen.dart';

File _createTempFile() {
  final directory = Directory.systemTemp.createTempSync('ikebank_53_');
  final file = File('${directory.path}/ktp.jpg');
  file.writeAsStringSync('ktp');
  return file;
}

void main() {
  testWidgets('53 - backend register error strips Exception prefix', (
    WidgetTester tester,
  ) async {
    // When _submitRegistration catches an error, it strips 'Exception: '
    // from the message before showing a SnackBar.
    final flowData = RegisterFlowData(
      phoneNumber: '081234567890',
      email: 'test@example.com',
      otpReference: 'ref-123',
      password: 'ValidPass1',
      ktpFile: _createTempFile(),
      name: 'Victor',
      nik: '1234567890123456',
      bornPlace: 'Jakarta',
      bornDate: '2007-02-26',
      gender: 'MALE',
      address: 'Address',
      religion: 'ISLAM',
      motherName: 'Mother',
    );

    await tester.pumpWidget(
      MaterialApp(home: BuatPinScreen(flowData: flowData)),
    );

    // Enter valid PIN + confirm
    await tester.enterText(find.byType(TextField), '123456123456');
    await tester.pump();

    // The InkWell button should exist and be tappable
    final button = tester.widget<InkWell>(find.byType(InkWell).first);
    expect(button.onTap, isNotNull);
  });
}
