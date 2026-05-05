import 'package:intl/intl.dart';

String toApiDate(String value) {
  try {
    final parsed = DateFormat('dd-MM-yyyy').parseStrict(value);
    return DateFormat('yyyy-MM-dd').format(parsed);
  } catch (_) {
    return value;
  }
}

String toApiGender(String? value) {
  final normalized = (value ?? '').toLowerCase();
  if (normalized.contains('laki')) return 'MALE';
  if (normalized.contains('perempuan')) return 'FEMALE';
  return 'OTHER';
}

String? validatePassword(String? value) {
  final text = (value ?? '').trim();
  if (text.isEmpty) return 'Password wajib diisi';
  if (text.length < 8) return 'Password minimal 8 karakter';
  if (!RegExp(r'[A-Z]').hasMatch(text)) {
    return 'Password harus punya huruf besar';
  }
  if (!RegExp(r'[a-z]').hasMatch(text)) {
    return 'Password harus punya huruf kecil';
  }
  if (!RegExp(r'\d').hasMatch(text)) return 'Password harus punya angka';
  return null;
}

String? validateConfirmPassword(String? value, String password) {
  final text = (value ?? '').trim();
  if (text.isEmpty) return 'Konfirmasi password wajib diisi';
  if (text != password.trim()) return 'Konfirmasi password tidak sama';
  return null;
}
