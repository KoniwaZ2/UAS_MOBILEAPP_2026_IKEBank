import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ikebank/api/auth.dart';

File _createTempFile(String prefix) {
  final directory = Directory.systemTemp.createTempSync(prefix);
  final file = File('${directory.path}/face.jpg');
  file.writeAsStringSync('face');
  return file;
}

void main() {
  test('41 - face registration upload completes', () async {
    final file = _createTempFile('ikebank_41_');

    await http.runWithClient(
      () async {
        await AuthService.uploadFaceImage(
          file,
          reference: 'ref-123',
          purpose: 'registration',
        );
      },
      () => MockClient.streaming((request, bodyStream) async {
        final body = utf8.decode(await bodyStream.toBytes());
        expect(body, contains('name="purpose"'));
        expect(body, contains('registration'));
        expect(body, contains('name="reference"'));
        expect(body, contains('ref-123'));
        return http.StreamedResponse(
          const Stream<List<int>>.empty(),
          200,
          request: request,
        );
      }),
    );
  });

  test('42 - face login upload completes', () async {
    final file = _createTempFile('ikebank_42_');

    await http.runWithClient(
      () async {
        await AuthService.checkFaceLogin(
          file,
          reference: 'login-ref-123',
          purpose: 'login',
        );
      },
      () => MockClient.streaming((request, bodyStream) async {
        final body = utf8.decode(await bodyStream.toBytes());
        expect(body, contains('name="purpose"'));
        expect(body, contains('login'));
        expect(body, contains('name="reference"'));
        expect(body, contains('login-ref-123'));
        return http.StreamedResponse(
          const Stream<List<int>>.empty(),
          200,
          request: request,
        );
      }),
    );
  });

  test('43 - face upload recovery throws on failure', () async {
    final file = _createTempFile('ikebank_43_');

    await http.runWithClient(
      () async {
        expect(
          () => AuthService.uploadFaceImage(
            file,
            reference: 'ref-123',
            purpose: 'registration',
          ),
          throwsA(isA<Exception>()),
        );
      },
      () => MockClient.streaming((request, bodyStream) async {
        return http.StreamedResponse(
          const Stream<List<int>>.empty(),
          500,
          request: request,
        );
      }),
    );
  });
}
