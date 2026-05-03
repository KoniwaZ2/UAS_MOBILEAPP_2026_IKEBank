// Test 54: Masuk email required
// Detail: Empty email shows inline error
// Class/Method: MasukScreen validation
// Test 55: Masuk invalid format
// Detail: Bad email format blocked
// Class/Method: MasukScreen _validasiDanLanjut
// Programmer: Victor

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/screens/auth/login/masuk_screen.dart';

void main() {
  testWidgets('54 - empty email shows inline error', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: MasukScreen()));

    // Tap the submit button without entering email
    final submitButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Lanjut'),
    );
    submitButton.onPressed!();
    await tester.pump();

    expect(find.text('Email tidak boleh kosong'), findsOneWidget);
  });

  testWidgets('55 - bad email format is blocked', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: MasukScreen()));

    await tester.enterText(find.byType(TextField), 'notanemail');
    await tester.pump();

    final submitButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Lanjut'),
    );
    submitButton.onPressed!();
    await tester.pump();

    expect(
      find.text('Format email tidak valid (contoh: nama@gmail.com)'),
      findsOneWidget,
    );
  });
}
