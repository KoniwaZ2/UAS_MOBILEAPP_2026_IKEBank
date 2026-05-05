import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/main.dart';

void main() {
  testWidgets(
    '03 - build() renders a destination after _checkLoginStatus completes',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(Scaffold), findsWidgets);
    },
  );
}
