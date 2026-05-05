import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/screens/auth/signin.dart';
import 'package:ikebank/screens/auth/riplay.dart';

void main() {
  testWidgets('09 - Tap RIPLAY text navigates to RiplayScreen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SignIn()));
    final riplayText = find.textContaining('RIPLAY');
    expect(riplayText, findsOneWidget);
    await tester.ensureVisible(riplayText);
    await tester.tap(riplayText, warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(RiplayScreen), findsOneWidget);
  });
}
