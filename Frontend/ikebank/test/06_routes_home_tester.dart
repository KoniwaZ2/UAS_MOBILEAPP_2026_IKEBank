import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/main.dart';
import 'package:ikebank/screens/home/home_screen.dart';

void main() {
  testWidgets('06 - Route /home resolves to HomeScreen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    final NavigatorState navigator = tester.state(find.byType(Navigator));
    navigator.pushNamed('/home');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
