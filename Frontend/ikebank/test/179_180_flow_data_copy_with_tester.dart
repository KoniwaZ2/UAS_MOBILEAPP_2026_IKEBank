// Test 179: RegisterFlowData copyWith
// Detail: CopyWith preserves existing nullables
// Class/Method: RegisterFlowData.copyWith()
// Test 180: RequestCardFlowData copyWith
// Detail: CopyWith updates partial fields safely
// Class/Method: RequestCardFlowData.copyWith()
// Programmer: Victor

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/models/register_flow_data.dart';
import 'package:ikebank/models/request_card_flow_data.dart';

void main() {
  test('179 - RegisterFlowData copyWith preserves existing nullables', () {
    final original = RegisterFlowData(
      phoneNumber: '081234567890',
      email: 'test@example.com',
      otpReference: 'ref-123',
      name: 'Victor',
      nik: '1234567890123456',
    );

    final copied = original.copyWith(password: 'ValidPass1');

    expect(copied.phoneNumber, '081234567890');
    expect(copied.email, 'test@example.com');
    expect(copied.otpReference, 'ref-123');
    expect(copied.name, 'Victor');
    expect(copied.nik, '1234567890123456');
    expect(copied.password, 'ValidPass1');
    // Fields not set should remain null
    expect(copied.bornPlace, isNull);
    expect(copied.bornDate, isNull);
    expect(copied.gender, isNull);
  });

  test('179b - RegisterFlowData copyWith overrides existing', () {
    final original = RegisterFlowData(
      phoneNumber: '081234567890',
      email: 'old@example.com',
      otpReference: 'ref-123',
    );

    final copied = original.copyWith(email: 'new@example.com');
    expect(copied.email, 'new@example.com');
    expect(copied.phoneNumber, '081234567890');
  });

  test('180 - RequestCardFlowData copyWith updates partial fields', () {
    final directory = Directory.systemTemp.createTempSync('ikebank_180_');
    final file = File('${directory.path}/ktp.jpg');
    file.writeAsStringSync('ktp');

    final original = RequestCardFlowData(
      phoneNumber: '081234567890',
      email: 'test@example.com',
      otpReference: 'ref-123',
    );

    final copied = original.copyWith(ktpFile: file);

    expect(copied.phoneNumber, '081234567890');
    expect(copied.email, 'test@example.com');
    expect(copied.otpReference, 'ref-123');
    expect(copied.ktpFile, isNotNull);
    expect(copied.ktpFile!.path, file.path);
  });

  test('180b - RequestCardFlowData copyWith overrides existing', () {
    final original = RequestCardFlowData(
      phoneNumber: '081234567890',
      email: 'old@example.com',
      otpReference: 'ref-old',
    );

    final copied = original.copyWith(
      email: 'new@example.com',
      otpReference: 'ref-new',
    );

    expect(copied.email, 'new@example.com');
    expect(copied.otpReference, 'ref-new');
    expect(copied.phoneNumber, '081234567890');
  });
}
