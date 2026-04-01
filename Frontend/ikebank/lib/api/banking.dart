import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth.dart';
import '../models/account_detail.dart';

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

  static Future<List<AccountDetail>> fetchAccountDetails() async {
    final url = Uri.parse('$baseUrl/account-details/');
    final headers = await AuthService.buildAuthHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(AccountDetail.fromJson)
            .toList();
      }
      return <AccountDetail>[];
    } else {
      throw Exception('Failed to fetch account details');
    }
  }
}
