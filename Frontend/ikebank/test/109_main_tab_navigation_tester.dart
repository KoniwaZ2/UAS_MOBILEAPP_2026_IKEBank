import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/screens/bottomnav/main_tab_screen.dart'; // Sesuaikan path

void main() {
  testWidgets('109 - Main tab navigation: Pindah tab mengubah tampilan', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: MainTabScreen()));
    await tester.pumpAndSettle();

    // 1. Kondisi awal: Tab Beranda aktif (Teks 'Layanan' dari HomeScreen terlihat)
    expect(find.text('Layanan'), findsWidgets);

    // 2. Cari tab "Lainnya" di Bottom Navigation dan tap
    final tabLainnya = find.text('Lainnya');
    await tester.tap(tabLainnya);
    
    // 3. Render ulang untuk mengganti halaman tab
    await tester.pumpAndSettle();

    // 4. Ekspektasi: Karena sudah pindah tab, teks 'Layanan' dari HomeScreen
    expect(find.text('Layanan'), findsNothing);
  });
}