import 'package:flutter_test/flutter_test.dart';

String normalizePhone(String value) {
  var cleaned = value.trim();
  cleaned = cleaned.replaceAll(RegExp(r'[^0-9+]'), '');

  if (cleaned.startsWith('8')) {
    return '0$cleaned';
  }

  return cleaned;
}

void main() {
  group('13 - _normalizePhone() normalization tests', () {
    test('Prepends 0 when phone starts with 8', () {
      expect(normalizePhone('81234567890'), '081234567890');
    });

    test('Keeps phone starting with 0 unchanged', () {
      expect(normalizePhone('081234567890'), '081234567890');
    });

    test('Keeps phone starting with +62 unchanged', () {
      expect(normalizePhone('+6281234567890'), '+6281234567890');
    });

    test('Strips non-digit characters except +', () {
      expect(normalizePhone('0812-3456-7890'), '081234567890');
    });

    test('Trims whitespace', () {
      expect(normalizePhone('  81234567890  '), '081234567890');
    });

    test('Handles phone with spaces and dashes', () {
      expect(normalizePhone('8 123 456 7890'), '081234567890');
    });
  });
}
