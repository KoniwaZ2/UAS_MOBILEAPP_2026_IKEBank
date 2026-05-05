import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/main.dart';
import 'package:ikebank/screens/auth/register/buat_pass_screen.dart';

void main() {
  testWidgets('05 - Route /buat_password resolves to BuatPassScreen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    final NavigatorState navigator = tester.state(find.byType(Navigator));
    navigator.pushNamed('/buat_password');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(BuatPassScreen), findsOneWidget);
  });
}
