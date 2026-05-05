import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/screens/home/home_screen.dart';

void main() {
  testWidgets('110 - Saku Utama open: Card Saku Utama ditekan', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    // 1. Scroll dan Tap "Saku Utama" di bagian layanan
    final sakuUtamaBtn = find.text('Saku Utama');
    await tester.ensureVisible(sakuUtamaBtn);
    await tester.tap(sakuUtamaBtn);
    
    await tester.pumpAndSettle();

    // 2. Ekspektasi: Teks "Dana tersedia" dari halaman Saku Utama muncul
    expect(find.text('Dana tersedia'), findsOneWidget);
  });
}