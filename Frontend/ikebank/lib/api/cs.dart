import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'auth.dart';

class CsService {
  static const String baseUrl = 'http://10.10.161.245:8000/api/cs';
  // static const String baseUrl = 'http://192.168.1.12:8000/api/cs';

  /// Kirim pesan ke CS dan dapatkan respons
  static Future<Map<String, dynamic>> sendMessage(String message) async {
    final url = Uri.parse('$baseUrl/chat/message/');
    final response = await AuthService.authorizedPost(
      url,
      body: jsonEncode({'message': message}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        _extractErrorMessage(response, 'Gagal mengirim pesan ke CS'),
      );
    }
  }

  /// Helper untuk ekstrak pesan error dari response
  static String _extractErrorMessage(http.Response response, String fallback) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final detail = decoded['detail']?.toString();
        if (detail != null && detail.isNotEmpty) {
          return detail;
        }
        for (final entry in decoded.entries) {
          final value = entry.value;
          if (value is List && value.isNotEmpty) {
            return value.first.toString();
          }
          if (value is String && value.isNotEmpty) {
            return value;
          }
        }
      }
    } catch (_) {}
    return '$fallback (HTTP ${response.statusCode})';
  }

  static Future<dynamic> closeChat() async {
    final url = Uri.parse('$baseUrl/chat/close/');
    final response = await AuthService.authorizedPost(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        _extractErrorMessage(response, 'Gagal menutup chat dengan CS'),
      );
    }
  }

  static Future<dynamic> submitReport({required String reportId}) async {
    final url = Uri.parse('$baseUrl/report/');
    final response = await AuthService.authorizedPost(
      url,
      body: jsonEncode({'report_number': reportId}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        _extractErrorMessage(
          response,
          'Gagal mengambil riwayat chat dengan CS',
        ),
      );
    }
  }
}
