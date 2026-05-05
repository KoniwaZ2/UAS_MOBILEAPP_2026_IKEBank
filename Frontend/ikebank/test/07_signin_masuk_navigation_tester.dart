import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/screens/auth/signin.dart';
import 'package:ikebank/screens/auth/login/masuk_screen.dart';

void main() {
  testWidgets('07 - Tap Masuk button navigates to MasukScreen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SignIn()));

    final masukButton = find.widgetWithText(TextButton, 'Masuk');
    expect(masukButton, findsOneWidget);
    await tester.ensureVisible(masukButton);
    await tester.tap(masukButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(MasukScreen), findsOneWidget);
  });
}
