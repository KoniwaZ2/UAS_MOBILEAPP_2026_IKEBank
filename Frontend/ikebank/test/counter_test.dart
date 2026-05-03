import 'package:flutter_test/flutter_test.dart';
import 'counter.dart';

void main() {
  group('Counter', () {
    late Counter counter;

    setUp(() {
      counter = Counter();
    });

    test('initial value should be 0', () {
      expect(counter.value, 0);
    });

    test('increment should increase value by 1', () {
      counter.increment();
      expect(counter.value, 1);
    });

    test('decrement should decrease value by 1 but not below 0', () {
      counter.decrement();
      expect(counter.value, 0);
    });

    test('setting value directly should update count', () {
      counter.value = 5;
      expect(counter.value, 5);
    });

    test('setting value to negative should reset to 0', () {
      counter.value = -3;
      expect(counter.value, 0);
    });
  });
}
