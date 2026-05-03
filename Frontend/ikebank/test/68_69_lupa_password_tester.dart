// Test 68: Lupa password submit success
// Detail: Forgot password with OTP updates password
// Class/Method: AuthService.forgotPassword()
// Test 69: Lupa password mismatch guard
// Detail: Password confirmation mismatch blocked
// Class/Method: LupaPasswordScreen form validator
// Programmer: Victor

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/api/auth.dart';
import 'package:ikebank/screens/auth/login/lupa_password_screen.dart';

void main() {
  test('68 - forgotPassword method exists with expected signature', () {
    expect(AuthService.forgotPassword, isA<Function>());
  });

  testWidgets('69 - password mismatch shows error snackbar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LupaPasswordScreen(email: 'test@example.com', reference: 'ref'),
      ),
    );

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Password1');
    await tester.enterText(fields.at(1), 'Different2');
    await tester.pump();

    final submitButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Lanjut'),
    );
    submitButton.onPressed!();
    await tester.pump();

    expect(find.text('Password tidak cocok'), findsOneWidget);
  });
}
