import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/screens/home/home_screen.dart'; 

void main() {
  testWidgets('108 - Home quick action routes: Tombol Tambah dana', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    // 1. Cari tombol "Tambah dana"
    final tambahDanaBtn = find.text('Tambah dana');
    await tester.ensureVisible(tambahDanaBtn); 
    await tester.tap(tambahDanaBtn);
    
    // 2. Tunggu transisi pindah layar
    await tester.pumpAndSettle();

    // 3. Ekspektasi Level Pro: Layar sudah pindah ke TambahDanaScreen.
    expect(find.text('Cara top up'), findsOneWidget);
  });
}