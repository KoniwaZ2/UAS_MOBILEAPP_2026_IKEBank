import 'dart:convert';
import 'auth.dart';
import '../models/account_detail.dart';
import '../models/wallet_source.dart';

class BankingService {
  static String baseUrl = 'http://192.168.1.12:8000/api/banking';

  static Future<Map<String, dynamic>> registerAccount() async {
    final url = Uri.parse('$baseUrl/register/');
    final response = await AuthService.authorizedPost(
      url,
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
    final response = await AuthService.authorizedGet(url);

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

  static Future<Map<String, dynamic>> checkQris({
    required String qrisNumber,
  }) async {
    final url = Uri.parse("$baseUrl/qris-check/");
    final response = await AuthService.authorizedPost(
      url,
      body: jsonEncode({'qris_number': qrisNumber}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to check QRIS');
    }
  }

  static Future<Map<String, dynamic>> bayarQris({
    required String pin,
    required String qrisNumber,
    required String category,
    required String amount,
    required String description,
  }) async {
    final url = Uri.parse("$baseUrl/transactions/");
    final dynamic parsedAmount = int.tryParse(amount) ?? double.tryParse(amount) ?? amount;
    final response = await AuthService.authorizedPost(
      url,
      body: jsonEncode({
        'pin': pin,
        'merchant_qris': qrisNumber,
        'category': category,
        'amount': parsedAmount,
        'description': description,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Failed to process QRIS payment (HTTP ${response.statusCode}): ${response.body}',
      );
    }
  }

  static Future<dynamic> sakuList() async {
    final url = Uri.parse("$baseUrl/saku-list/");
    final response = await AuthService.authorizedGet(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get Saku List');
    }
  }

  static Future<List<WalletSource>> fetchQrisFundingSources() async {
    try {
      final raw = await sakuList();

      // Handle case where API returns list directly
      if (raw is List) {
        return raw
            .whereType<Map<String, dynamic>>()
            .map(WalletSource.fromJson)
            .where(
              (source) =>
                  source.category == WalletCategory.utama ||
                  source.category == WalletCategory.transaksi,
            )
            .where((source) => source.name.isNotEmpty)
            .toList();
      }

      // Handle case where API returns map with nested list
      final dynamic payload =
          raw['data'] ?? raw['results'] ?? raw['sakus'] ?? raw;

      if (payload is! List) {
        return <WalletSource>[];
      }

      return payload
          .whereType<Map<String, dynamic>>()
          .map(WalletSource.fromJson)
          .where(
            (source) =>
                source.category == WalletCategory.utama ||
                source.category == WalletCategory.transaksi,
          )
          .where((source) => source.name.isNotEmpty)
          .toList();
    } catch (e) {
      print('[Banking Service] fetchQrisFundingSources error: $e');
      return <WalletSource>[];
    }
  }
}
