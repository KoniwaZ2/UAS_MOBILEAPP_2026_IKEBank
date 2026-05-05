// Test 05: App routes registration
// Detail: Route /buat_password resolves correctly
// Class/Method: MaterialApp routes map in main.dart
// Programmer: Victor

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/main.dart';
import 'package:ikebank/screens/auth/register/buat_pass_screen.dart';

void main() {
  testWidgets('05 - Route /buat_password resolves to BuatPassScreen',
      (WidgetTester tester) async {
    // Arrange: pump MyApp and wait for loading to complete
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    // Act: navigate to /buat_password route
    final NavigatorState navigator = tester.state(find.byType(Navigator));
    navigator.pushNamed('/buat_password');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Assert: BuatPassScreen should be rendered
    expect(find.byType(BuatPassScreen), findsOneWidget);
  });
}
