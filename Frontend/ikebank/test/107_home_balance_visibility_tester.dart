import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/screens/home/home_screen.dart';

void main() {
  testWidgets('107 - Home balance visibility: Mata menyembunyikan saldo', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    // 1. Kondisi awal: Saldo terlihat karena di kode default _isBalanceVisible = true
    // Walau saldonya 0, harusnya memunculkan 'Rp 0' karena _formatRupiah
    expect(find.text('Rp 0'), findsOneWidget); 

    // 2. Cari Icon Mata yang terbuka dan di-Tap
    await tester.tap(find.byIcon(Icons.visibility_outlined));
    
    // 3. Render ulang layar setelah di-tap
    await tester.pump();

    // 4. Ekspektasi: Saldo berubah jadi bintang-bintang
    expect(find.text('Rp •••••••••'), findsOneWidget); 

    // 5. Ikonnya harusnya berubah jadi tertutup
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
  });
}