import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/screens/home/home_screen.dart'; 

void main() {
  testWidgets('105 - Home account load success: Tampilan awal muncul', (WidgetTester tester) async {
    // 1. Render halamannya
    await tester.pumpWidget(const MaterialApp(
      home: HomeScreen(),
    ));

    // 2. Tunggu animasi selesai
    await tester.pumpAndSettle();

    // 3. Ekspektasi: Cari teks statis yang menandakan halaman sukses diload
    expect(find.text('Total dana'), findsOneWidget); 
    expect(find.text('Layanan'), findsOneWidget);
  });
}