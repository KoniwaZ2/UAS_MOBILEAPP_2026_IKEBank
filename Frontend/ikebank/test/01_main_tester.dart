import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/main.dart';

void main() {
  testWidgets('01 - main() can be invoked and MyApp widget is created', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(MyApp), findsOneWidget);
  });
}
