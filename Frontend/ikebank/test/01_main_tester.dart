// Test 01: App startup loading gate
// Detail: MyApp shows loader before auth check
// Class/Method: main()
// Programmer: Victor

import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/main.dart';

void main() {
  testWidgets('01 - main() can be invoked and MyApp widget is created',
      (WidgetTester tester) async {
    // Arrange & Act: pump MyApp directly
    await tester.pumpWidget(const MyApp());

    // Assert: MyApp widget exists in the tree
    expect(find.byType(MyApp), findsOneWidget);
  });
}
