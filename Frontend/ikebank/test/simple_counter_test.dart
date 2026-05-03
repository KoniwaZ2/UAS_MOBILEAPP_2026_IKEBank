import 'package:flutter_test/flutter_test.dart';
import 'counter.dart';

void main() {
  test('increment increases count from 0 to 1', () {
    final counter = Counter();
    expect(counter.value, 0);
    counter.increment();
    expect(counter.value, 1);
  });
}
