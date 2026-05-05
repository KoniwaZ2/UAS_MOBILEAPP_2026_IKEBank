import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ikebank/api/auth.dart';

File _createTempFile() {
  final directory = Directory.systemTemp.createTempSync('ikebank_51_');
  final file = File('${directory.path}/ktp.jpg');
  file.writeAsStringSync('ktp');
  return file;
}

void main() {
  test('51 - register success returns parsed payload', () async {
    final file = _createTempFile();

    await http.runWithClient(
      () async {
        final result = await AuthService.register(
          otpReference: 'ref-123',
          phoneNumber: '081234567890',
          email: 'test@example.com',
          password: 'ValidPass1',
          name: 'Victor',
          nik: '1234567890123456',
          bornPlace: 'Jakarta',
          bornDate: '2007-02-26',
          gender: 'MALE',
          address: 'Address',
          religion: 'ISLAM',
          motherName: 'Mother',
          pin: '123456',
          ktpFile: file,
        );

        expect(result['status'], 'ok');
      },
      () => MockClient.streaming((request, bodyStream) async {
        return http.StreamedResponse(
          Stream.value(
            utf8.encode(jsonEncode(<String, dynamic>{'status': 'ok'})),
          ),
          201,
          request: request,
        );
      }),
    );
  });

  test('52 - register request carries account data', () async {
    final file = _createTempFile();

    await http.runWithClient(
      () async {
        await AuthService.register(
          otpReference: 'ref-123',
          phoneNumber: '081234567890',
          email: 'test@example.com',
          password: 'ValidPass1',
          name: 'Victor',
          nik: '1234567890123456',
          bornPlace: 'Jakarta',
          bornDate: '2007-02-26',
          gender: 'MALE',
          address: 'Address',
          religion: 'ISLAM',
          motherName: 'Mother',
          pin: '123456',
          ktpFile: file,
        );
      },
      () => MockClient.streaming((request, bodyStream) async {
        final body = utf8.decode(await bodyStream.toBytes());
        expect(body, contains('name="otp_reference"'));
        expect(body, contains('ref-123'));
        expect(body, contains('name="pin_confirmation"'));
        expect(body, contains('123456'));
        expect(body, contains('name="ktp"'));
        return http.StreamedResponse(
          Stream.value(
            utf8.encode(jsonEncode(<String, dynamic>{'status': 'ok'})),
          ),
          201,
          request: request,
        );
      }),
    );
  });
}
