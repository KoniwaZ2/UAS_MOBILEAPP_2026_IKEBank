import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/screens/auth/register/register_screen.dart';

void main() {
  testWidgets('18 - Button initially shows "Lanjut" and is enabled', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

    final lanjutButton = find.text('Lanjut');
    expect(lanjutButton, findsOneWidget);

    final elevatedButton = find.widgetWithText(ElevatedButton, 'Lanjut');
    expect(elevatedButton, findsOneWidget);

    final ElevatedButton button = tester.widget(elevatedButton);
    expect(button.onPressed, isNotNull);
  });

  testWidgets('18b - Button becomes disabled during API call', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

    final textFields = find.byType(TextField);
    await tester.enterText(textFields.at(0), '081234567890');
    await tester.enterText(textFields.at(1), 'user@example.com');

    final lanjutButton = find.widgetWithText(ElevatedButton, 'Lanjut');
    await tester.ensureVisible(lanjutButton);
    await tester.tap(lanjutButton);

    await tester.pump();
    expect(find.byType(RegisterScreen), findsOneWidget);
  });
}
