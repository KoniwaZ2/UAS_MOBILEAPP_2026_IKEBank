// Test 08: SignIn to Buat Akun navigation
// Detail: Tap Buat Akun opens BuatAkunScreen
// Class/Method: SignIn CTA onPressed Buat Akun
// Programmer: Victor

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/screens/auth/signin.dart';
import 'package:ikebank/screens/auth/register/buat_akun_screen.dart';

void main() {
  testWidgets('08 - Tap Buat Akun button navigates to BuatAkunScreen',
      (WidgetTester tester) async {
    // Arrange: pump SignIn inside a MaterialApp
    await tester.pumpWidget(
      const MaterialApp(home: SignIn()),
    );

    // Act: find the ElevatedButton containing 'Buat Akun' and tap it
    final buatAkunButton = find.widgetWithText(ElevatedButton, 'Buat Akun');
    expect(buatAkunButton, findsOneWidget);
    await tester.ensureVisible(buatAkunButton);
    await tester.tap(buatAkunButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Assert: BuatAkunScreen should now be visible
    expect(find.byType(BuatAkunScreen), findsOneWidget);
  });
}
