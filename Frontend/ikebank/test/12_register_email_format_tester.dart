import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/screens/auth/register/register_screen.dart';

void main() {
  testWidgets('12 - Invalid email format shows format validation SnackBar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

    final textFields = find.byType(TextField);
    await tester.enterText(textFields.at(0), '081234567890');
    await tester.enterText(textFields.at(1), 'invalid-email');

    final lanjutButton = find.text('Lanjut');
    await tester.ensureVisible(lanjutButton);
    await tester.tap(lanjutButton);
    await tester.pump();

    expect(find.text('Format email tidak valid.'), findsOneWidget);
  });
}
