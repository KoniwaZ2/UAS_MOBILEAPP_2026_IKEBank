import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/screens/auth/register/register_screen.dart';

void main() {
  testWidgets(
    '11 - Empty email blocks next step and shows validation SnackBar',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

      final phoneField = find.byType(TextField).first;
      await tester.enterText(phoneField, '081234567890');

      final lanjutButton = find.text('Lanjut');
      await tester.ensureVisible(lanjutButton);
      await tester.tap(lanjutButton);
      await tester.pump();

      expect(find.text('Nomor ponsel dan email wajib diisi!'), findsOneWidget);
    },
  );
}
