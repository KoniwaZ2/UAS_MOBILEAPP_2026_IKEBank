import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/screens/home/home_screen.dart';

void main() {
  testWidgets('112 - Saku Deposito open: Card Deposito ditekan', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    final depositoBtn = find.text('Saku Deposito');
    await tester.ensureVisible(depositoBtn);
    await tester.tap(depositoBtn);
    
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    // Ekspektasi: Muncul teks 'Penawaran Deposito' dari halaman Saku Deposito
    expect(find.text('Penawaran Deposito'), findsOneWidget);
  });
}