import 'dart:convert';
import 'package:flutter/foundation.dart';
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
    final dynamic parsedAmount =
        int.tryParse(amount) ?? double.tryParse(amount) ?? amount;
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

  static Future<Map<String, dynamic>> sakuDetail({String? sakuId}) async {
    final url = Uri.parse('$baseUrl/saku-detail/');
    final response = await AuthService.authorizedPost(
      url,
      body: jsonEncode({
        if (sakuId != null && sakuId.trim().isNotEmpty) 'pk': sakuId.trim(),
      }),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    }

    throw Exception(
      'Failed to get Saku Detail (HTTP ${response.statusCode}): ${response.body}',
    );
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
      return <WalletSource>[];
    }
  }

  static Future<List<Map<String, dynamic>>> transactionHistory({
    String? sakuId,
    String? sakuName,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    String formatDate(DateTime date) {
      final y = date.year.toString().padLeft(4, '0');
      final m = date.month.toString().padLeft(2, '0');
      final d = date.day.toString().padLeft(2, '0');
      return '$y-$m-$d';
    }

    final queryParams = <String, String>{
      if (sakuId != null && sakuId.trim().isNotEmpty) 'saku_id': sakuId.trim(),
      if (sakuName != null && sakuName.trim().isNotEmpty)
        'saku_name': sakuName.trim(),
      if (category != null && category.trim().isNotEmpty)
        'category': category.trim(),
      if (startDate != null) 'start_date': formatDate(startDate),
      if (endDate != null) 'end_date': formatDate(endDate),
      if (limit != null) 'limit': limit.toString(),
      if (offset != null) 'offset': offset.toString(),
    };

    final url = Uri.parse(
      '$baseUrl/transactions-history/',
    ).replace(queryParameters: queryParams.isEmpty ? null : queryParams);
    final response = await AuthService.authorizedGet(url);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to get Transaction History (HTTP ${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      return <Map<String, dynamic>>[];
    }

    return decoded.whereType<Map<String, dynamic>>().toList();
  }

  static Future<Map<String, dynamic>> internalTransfer({
    required String sourceSakuId,
    required String destinationSakuId,
    required String amount,
    required String description,
  }) async {
    final url = Uri.parse('$baseUrl/internal-transfer/');
    final dynamic parsedAmount =
        int.tryParse(amount) ?? double.tryParse(amount) ?? amount;
    final response = await AuthService.authorizedPost(
      url,
      body: jsonEncode({
        'source_saku_id': sourceSakuId,
        'destination_saku_id': destinationSakuId,
        'amount': parsedAmount,
        'description': description,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(response.body);
  }

  static Future<Map<String, dynamic>> tambahSaku({
    required String sakuName,
    required String category,
    required bool isPrimary,
  }) async {
    String normalizeCategory(String raw) {
      final value = raw.trim().toLowerCase();
      if (value.contains('nabung')) return 'nabung';
      if (value.contains('transaksi')) return 'transaksi';
      return 'lainnya';
    }

    final url = Uri.parse('$baseUrl/tambah-saku/');
    final payload = {
      'saku_name': sakuName,
      'category_name': normalizeCategory(category),
      'is_primary': isPrimary,
    };

    final response = await AuthService.authorizedPost(
      url,
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    debugPrint('tambahSaku failed with status ${response.statusCode}: ${response.body}');
    throw Exception('Gagal membuat saku. Silakan coba lagi.');
  }
}
