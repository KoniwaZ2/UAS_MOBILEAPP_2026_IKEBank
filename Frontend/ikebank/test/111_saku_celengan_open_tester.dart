import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/screens/home/home_screen.dart';

void main() {
  testWidgets('111 - Saku Celengan open: Card Celengan ditekan', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    final celenganBtn = find.text('Saku Celengan');
    await tester.ensureVisible(celenganBtn);
    await tester.tap(celenganBtn);
    
    // Karena Saku Celengan punya Timer Countdown yang berjalan terus (infinite loop),
    // Kita gabisa pake pumpAndSettle() karena test akan nge-hang.
    // Kita akan pakai pump biasa beberapa kali agar layarnya pindah tanpa menunggu timer berhenti.
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    // Ekspektasi: Kita cari teks "Nabung AI" yang khas di halaman Celengan
    expect(find.text('Nabung AI'), findsOneWidget);
  });
}