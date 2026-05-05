// Test 06: App routes home
// Detail: Route /home resolves correctly
// Class/Method: MaterialApp routes map in main.dart
// Programmer: Victor

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/main.dart';
import 'package:ikebank/screens/home/home_screen.dart';

void main() {
  testWidgets('06 - Route /home resolves to HomeScreen',
      (WidgetTester tester) async {
    // Arrange: pump MyApp and wait for loading
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    // Act: navigate to /home route
    final NavigatorState navigator = tester.state(find.byType(Navigator));
    navigator.pushNamed('/home');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Assert: HomeScreen should be rendered
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
