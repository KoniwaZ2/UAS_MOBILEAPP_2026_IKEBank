import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/screens/home/home_screen.dart';

void main() {
  testWidgets('106 - Home account load fallback: Menampilkan default jika kosong', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: HomeScreen(),
    ));
    await tester.pumpAndSettle();

    // Ekspektasi: Karena di test ini API tidak dipanggil (kosong), 
    expect(find.text('Pengguna'), findsOneWidget);
    expect(find.text('-'), findsOneWidget);
  });
}