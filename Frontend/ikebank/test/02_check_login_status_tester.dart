import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/main.dart';

void main() {
  testWidgets(
    '02 - _checkLoginStatus() shows CircularProgressIndicator while loading',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    },
  );
}
