import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/main.dart' as app;

void main() {
  testWidgets('main can run without error', (WidgetTester tester) async {
    await app.main();
    await tester.pump();
    expect(find.byType(app.MyApp), findsOneWidget);
  });
}
