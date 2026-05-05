import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/screens/auth/signin.dart';
import 'package:ikebank/screens/auth/register/buat_akun_screen.dart';

void main() {
  testWidgets('08 - Tap Buat Akun button navigates to BuatAkunScreen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SignIn()));
    final buatAkunButton = find.widgetWithText(ElevatedButton, 'Buat Akun');
    expect(buatAkunButton, findsOneWidget);
    await tester.ensureVisible(buatAkunButton);
    await tester.tap(buatAkunButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(BuatAkunScreen), findsOneWidget);
  });
}
