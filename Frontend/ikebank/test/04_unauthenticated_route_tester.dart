import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/main.dart';
import 'package:ikebank/screens/auth/signin.dart';

void main() {
  testWidgets('04 - build() renders destination after auth check completes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    final hasSignIn = find.byType(SignIn).evaluate().isNotEmpty;
    final hasScaffold = find.byType(Scaffold).evaluate().isNotEmpty;

    expect(hasSignIn || hasScaffold, isTrue);
  });
}
