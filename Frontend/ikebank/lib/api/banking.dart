import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth.dart';

class BankingService {
  static String baseUrl = 'http://192.168.1.29:8000/api/banking';

  static Future<Map<String, dynamic>> registerAccount() async {
    final url = Uri.parse('$baseUrl/register/');
    final headers = await AuthService.buildAuthHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to register account');
    }
  }

  static Future<void> fetchHomeAfterLogin() async {
    // Placeholder API for login entry flow. Implement endpoint later.
    return;
  }
}
