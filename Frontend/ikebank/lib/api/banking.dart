import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'auth.dart';
import '../models/account_detail.dart';
import '../models/beneficial_account.dart';
import '../models/wallet_source.dart';
import 'package:http/http.dart' as http;

class BankingService {
  // static const String baseUrl = 'http://192.168.0.113:8000/api/banking';
  // static const String baseUrl = 'http://192.168.1.12:8000/api/banking';
  // static const String baseUrl = 'http://10.10.161.245:8000/api/banking';
  static const String baseUrl = 'http://10.10.155.66:8000/api/banking';

  static final ValueNotifier<int> accountDataRevision = ValueNotifier<int>(0);

  static void notifyAccountDataChanged() {
    accountDataRevision.value++;
  }

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
      final result = jsonDecode(response.body);
      notifyAccountDataChanged();
      return result;
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

    final normalizedSakuId = sakuId?.trim() ?? '';
    final parsedSakuId = int.tryParse(normalizedSakuId);

    final queryParams = <String, String>{
      if (parsedSakuId != null) 'saku_id': parsedSakuId.toString(),
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
      final result = jsonDecode(response.body);
      notifyAccountDataChanged();
      return result;
    }

    throw Exception(response.body);
  }

  static Future<Map<String, dynamic>> transferOut({
    required String pin,
    required String destinationAccount,
    required String amount,
    String description = '',
  }) async {
    final url = Uri.parse('$baseUrl/transactions/');
    final dynamic parsedAmount =
        int.tryParse(amount) ?? double.tryParse(amount) ?? amount;

    if (kDebugMode) {
      final destinationTail = destinationAccount.length >= 4
          ? destinationAccount.substring(destinationAccount.length - 4)
          : destinationAccount;
      debugPrint(
        'transferOut -> POST $url | amount=$parsedAmount | destination=***$destinationTail',
      );
    }

    final response = await AuthService.authorizedPost(
      url,
      body: jsonEncode({
        'pin': pin,
        'category': 'transfer_out',
        'destination_account': destinationAccount,
        'amount': parsedAmount,
        if (description.trim().isNotEmpty) 'description': description.trim(),
      }),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        if (kDebugMode) {
          debugPrint('transferOut <- success HTTP 200');
        }
        notifyAccountDataChanged();
        return decoded;
      }
      notifyAccountDataChanged();
      return <String, dynamic>{};
    }

    if (kDebugMode) {
      debugPrint(
        'transferOut <- failed HTTP ${response.statusCode}: ${response.body}',
      );
    }

    throw Exception(
      'Failed to transfer out (HTTP ${response.statusCode}): ${response.body}',
    );
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

    debugPrint(
      'tambahSaku failed with status ${response.statusCode}: ${response.body}',
    );
    throw Exception('Gagal membuat saku. Silakan coba lagi.');
  }

  static Future<dynamic> rekeningList() async {
    final url = Uri.parse("$baseUrl/rekening-list/");
    final response = await AuthService.authorizedGet(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get Account List');
    }
  }

  static Future<List<BeneficialAccount>> fetchRekeningList() async {
    final raw = await rekeningList();
    final dynamic payload = raw is Map<String, dynamic>
        ? (raw['data'] ?? raw['results'] ?? raw['beneficiaries'] ?? raw)
        : raw;

    if (payload is! List) {
      return <BeneficialAccount>[];
    }

    return payload
        .whereType<Map<String, dynamic>>()
        .map(BeneficialAccount.fromJson)
        .where((account) => account.accountNumber.trim().isNotEmpty)
        .toList();
  }

  static Future<dynamic> tambahRekening({required String accountNumber}) async {
    final url = Uri.parse("$baseUrl/tambah-rekening/");
    final response = await AuthService.authorizedPost(
      url,
      body: jsonEncode({
        'bank_name': 'IKE Bank',
        'account_number': accountNumber,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Failed to add new account (HTTP ${response.statusCode}): ${response.body}',
      );
    }
  }

  static Future<dynamic> savingRecommendation() async {
    final url = Uri.parse("$baseUrl/savings-recommendation/");
    final response = await AuthService.authorizedGet(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get saving recommendation');
    }
  }

  static Future<Map<String, dynamic>> fetchNabungAiState() async {
    final url = Uri.parse('$baseUrl/nabung-ai-state/');
    final response = await AuthService.authorizedGet(url);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return <String, dynamic>{};
    }

    throw Exception(
      'Failed to get Nabung AI state (HTTP ${response.statusCode}): ${response.body}',
    );
  }

  static Future<Map<String, dynamic>> updateNabungAiState({
    bool? autoIsi,
    DateTime? cooldownUntil,
    bool clearCooldown = false,
  }) async {
    final url = Uri.parse('$baseUrl/nabung-ai-state/');
    final payload = <String, dynamic>{
      if (autoIsi != null) 'auto_isi': autoIsi,
      if (clearCooldown) 'clear_cooldown': true,
      if (!clearCooldown && cooldownUntil != null)
        'cooldown_until': cooldownUntil.toIso8601String(),
    };

    final response = await AuthService.authorizedPost(
      url,
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return <String, dynamic>{};
    }

    throw Exception(
      'Failed to update Nabung AI state (HTTP ${response.statusCode}): ${response.body}',
    );
  }

  // ini untuk liat offer atau jenis deposito apa saja yang tersedia
  static Future<dynamic> DepositoList() {
    final url = Uri.parse("$baseUrl/deposito-list/");
    return AuthService.authorizedGet(url).then((response) {
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get Deposito List');
      }
    });
  }

  static Future<dynamic> buatDeposito({
    required int depositoId,
    required int sourceSakuId,
    required int amount,
  }) {
    final url = Uri.parse("$baseUrl/deposito-create/");
    return AuthService.authorizedPost(
      url,
      body: jsonEncode({
        'deposito_id': depositoId,
        'source_saku_id': sourceSakuId,
        'amount': amount,
      }),
    ).then((response) {
      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = jsonDecode(response.body);
        notifyAccountDataChanged();
        return result;
      } else {
        throw Exception(
          'Failed to create deposito (HTTP ${response.statusCode}): ${response.body}',
        );
      }
    });
  }

  static Future<dynamic> depositoDetail({required String depositoId}) {
    final url = Uri.parse("$baseUrl/deposito-detail/");
    return AuthService.authorizedPost(
      url,
      body: jsonEncode({'pk': depositoId}),
    ).then((response) {
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Failed to get deposito detail (HTTP ${response.statusCode}): ${response.body}',
        );
      }
    });
  }

  static Future<dynamic> depositoUser() {
    final url = Uri.parse("$baseUrl/deposito-user/");
    return AuthService.authorizedGet(url).then((response) {
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get user deposito list');
      }
    });
  }

  static Future<dynamic> estimasiDeposito({
    required int depositoId,
    required int sourceSakuId,
    required int amount,
  }) {
    final url = Uri.parse("$baseUrl/deposito-estimate/");
    return AuthService.authorizedPost(
      url,
      body: jsonEncode({
        'amount': amount,
        'source_saku_id': sourceSakuId,
        'deposito_id': depositoId,
      }),
    ).then((response) {
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Failed to get deposito estimation (HTTP ${response.statusCode}): ${response.body}',
        );
      }
    });
  }

  static Future<dynamic> cashflowCalculate({
    required int month,
    required int year,
  }) {
    final url = Uri.parse("$baseUrl/cashflow-calculate/");
    return AuthService.authorizedPost(
      url,
      body: jsonEncode({'month': month, 'year': year}),
    ).then((response) {
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Failed to calculate cashflow (HTTP ${response.statusCode}): ${response.body}',
        );
      }
    });
  }

  static Future<dynamic> editDeposito({
    required String depositoUUID,
    required String nama,
  }) {
    final url = Uri.parse("$baseUrl/deposito-edit/");
    final payload = <String, dynamic>{
      'deposito_account_id': depositoUUID,
      'nama_deposito': nama,
    };

    return AuthService.authorizedPost(url, body: jsonEncode(payload)).then((
      response,
    ) {
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        notifyAccountDataChanged();
        return result;
      } else {
        throw Exception(
          'Failed to edit deposito (HTTP ${response.statusCode}): ${response.body}',
        );
      }
    });
  }

  static Future<dynamic> cardRequest({
    required String userPin,
    required String sourceFundsId,
  }) {
    final url = Uri.parse("$baseUrl/card-request/");
    return AuthService.authorizedPost(
      url,
      body: jsonEncode({'pin': userPin, 'source_funds_id': sourceFundsId}),
    ).then((response) {
      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = jsonDecode(response.body);
        notifyAccountDataChanged();
        return result;
      } else {
        throw Exception(
          'Failed to request card (HTTP ${response.statusCode}): ${response.body}',
        );
      }
    });
  }

  static Future<dynamic> cardDetails() {
    final url = Uri.parse("$baseUrl/card-details/");
    return AuthService.authorizedGet(url).then((response) {
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> &&
            !decoded.containsKey('card_status')) {
          return <String, dynamic>{...decoded, 'card_status': 'active'};
        }
        return decoded;
      }

      throw Exception(
        'Failed to get card details (HTTP ${response.statusCode}): ${response.body}',
      );
    });
  }

  static Future<dynamic> cardGetDetails({required String userPin}) {
    final url = Uri.parse("$baseUrl/card-details/");
    return AuthService.authorizedPost(
      url,
      body: jsonEncode({'pin': userPin}),
    ).then((response) {
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        notifyAccountDataChanged();
        return result;
      } else {
        throw Exception(
          'Failed to get card details (HTTP ${response.statusCode}): ${response.body}',
        );
      }
    });
  }

  static Future<dynamic> cardActivate({
    required String cardLast6Digits,
    required String newPIN,
  }) {
    final url = Uri.parse("$baseUrl/card-edit/");
    final String action = 'ACTIVATE_CARD';

    return AuthService.authorizedPost(
      url,
      body: jsonEncode({
        'action': action,
        'card_last6_digits': cardLast6Digits,
        'new_pin': newPIN,
      }),
    ).then((response) {
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        notifyAccountDataChanged();
        return result;
      } else {
        throw Exception(
          'Failed to activate card (HTTP ${response.statusCode}): ${response.body}',
        );
      }
    });
  }

  static Future<dynamic> cardVerify({required String cardLast6Digits}) {
    final url = Uri.parse("$baseUrl/card-edit/");
    final String status = 'active';
    final String action = 'VERIFY_CARD';

    return AuthService.authorizedPost(
      url,
      body: jsonEncode({
        'action': action,
        'card_last6_digits': cardLast6Digits,
        'status': status,
      }),
    ).then((response) {
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        notifyAccountDataChanged();
        return result;
      } else {
        throw Exception(
          'Failed to verify card (HTTP ${response.statusCode}): ${response.body}',
        );
      }
    });
  }

  static Future<dynamic> cardBlockTemp({required String pinUser}) {
    final url = Uri.parse("$baseUrl/card-edit/");
    final String action = 'BLOCK_TEMPORARY';

    return AuthService.authorizedPost(
      url,
      body: jsonEncode({'action': action, 'pin': pinUser}),
    ).then((response) {
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        notifyAccountDataChanged();
        return result;
      } else {
        throw Exception(
          'Failed to block card (HTTP ${response.statusCode}): ${response.body}',
        );
      }
    });
  }

  static Future<dynamic> cardOpenBlockTemp({required String pinUser}) {
    final url = Uri.parse("$baseUrl/card-edit/");
    final String action = 'UNBLOCK_TEMPORARY';

    return AuthService.authorizedPost(
      url,
      body: jsonEncode({'action': action, 'pin': pinUser}),
    ).then((response) {
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        notifyAccountDataChanged();
        return result;
      } else {
        throw Exception(
          'Failed to unblock card (HTTP ${response.statusCode}): ${response.body}',
        );
      }
    });
  }

  static Future<dynamic> cardBlockPerm({required String pinUser}) {
    final url = Uri.parse("$baseUrl/card-edit/");
    final String action = 'BLOCK_PERMANENT';

    return AuthService.authorizedPost(
      url,
      body: jsonEncode({'action': action, 'pin': pinUser}),
    ).then((response) {
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        notifyAccountDataChanged();
        return result;
      } else {
        throw Exception(
          'Failed to block card (HTTP ${response.statusCode}): ${response.body}',
        );
      }
    });
  }

  static Future<dynamic> cardBlockUblockTemp({required String pinUser}) {
    final url = Uri.parse("$baseUrl/card-edit/");
    final String action = 'UNBLOCK_TEMPORARY';

    return AuthService.authorizedPost(
      url,
      body: jsonEncode({'action': action, 'pin': pinUser}),
    ).then((response) {
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        notifyAccountDataChanged();
        return result;
      } else {
        throw Exception(
          'Failed to unblock card (HTTP ${response.statusCode}): ${response.body}',
        );
      }
    });
  }

  static Future<dynamic> setDailyLimit({
    required String pinUser,
    required int dailyWithdrawalLimit,
    required int dailyTransactionLimit,
    required int dailySingleTransactionLimit,
  }) {
    final url = Uri.parse("$baseUrl/card-edit/");
    final String action = 'SET_DAILY_LIMIT';

    return AuthService.authorizedPost(
      url,
      body: jsonEncode({
        'action': action,
        'pin': pinUser,
        'daily_withdrawal_limit': dailyWithdrawalLimit,
        'daily_transaction_limit': dailyTransactionLimit,
        'daily_single_transaction_limit': dailySingleTransactionLimit,
      }),
    ).then((response) {
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        notifyAccountDataChanged();
        return result;
      } else {
        throw Exception(
          'Failed to set daily limit (HTTP ${response.statusCode}): ${response.body}',
        );
      }
    });
  }

  static Future<dynamic> getDailyLimit() {
    final url = Uri.parse("$baseUrl/daily-limit/");
    return AuthService.authorizedGet(url).then((response) {
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> &&
            !decoded.containsKey('card_status')) {
          return <String, dynamic>{...decoded, 'card_status': 'active'};
        }
        return decoded;
      }

      throw Exception(
        'Failed to get daily limit (HTTP ${response.statusCode}): ${response.body}',
      );
    });
  }

  static Future<dynamic> cardChangePin({
    required String oldPin,
    required String newPin,
  }) {
    final url = Uri.parse("$baseUrl/card-edit/");
    final String action = 'CHANGE_CARD_PIN';

    return AuthService.authorizedPost(
      url,
      body: jsonEncode({
        'action': action,
        'old_pin': oldPin,
        'new_pin': newPin,
      }),
    ).then((response) {
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        notifyAccountDataChanged();
        return result;
      } else {
        throw Exception(
          'Failed to change card PIN (HTTP ${response.statusCode}): ${response.body}',
        );
      }
    });
  }

  static Future<dynamic> cardBlock() {
    final url = Uri.parse("$baseUrl/card-edit/");
    final String action = 'CHANGE_STATUS';
    final String status = 'blocked';

    return AuthService.authorizedPost(
      url,
      body: jsonEncode({'action': action, 'status': status}),
    ).then((response) {
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        notifyAccountDataChanged();
        return result;
      } else {
        throw Exception(
          'Failed to block card (HTTP ${response.statusCode}): ${response.body}',
        );
      }
    });
  }

  static Future<dynamic> getQrisDailyLimit() {
    final url = Uri.parse("$baseUrl/qris-daily-limit/");

    return AuthService.authorizedGet(url).then((response) {
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        notifyAccountDataChanged();
        return result;
      } else {
        throw Exception(
          'Failed to get QRIS daily limit (HTTP ${response.statusCode}): ${response.body}',
        );
      }
    });
  }

  static Future<dynamic> setQrisDailyLimit({
    // required String pinUser,
    required int qrisLimit,
  }) {
    final url = Uri.parse("$baseUrl/qris-daily-limit/");

    return AuthService.authorizedPatch(
      url,
      body: jsonEncode({'qris_limit': qrisLimit}),
    ).then((response) {
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        notifyAccountDataChanged();
        return result;
      } else {
        throw Exception(
          'Failed to set QRIS daily limit (HTTP ${response.statusCode}): ${response.body}',
        );
      }
    });
  }

  static Future<dynamic> blockAccount() {
    final url = Uri.parse("$baseUrl/block-account/");
    return AuthService.authorizedPost(url, body: {}).then((response) {
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Failed to block account (HTTP ${response.statusCode}): ${response.body}',
        );
      }
    });
  }

  static Future<dynamic> changePin({
    required String newPin,
    required String newPinConfirm,
  }) {
    final url = Uri.parse("$baseUrl/forgot-pin/");
    return AuthService.authorizedPost(
      url,
      body: jsonEncode({'new_pin': newPin, 'new_pin_confirm': newPinConfirm}),
    ).then((response) {
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Failed to change PIN (HTTP ${response.statusCode}): ${response.body}',
        );
      }
    });
  }

  static Future<dynamic> checkRekening({required String accountNumber}) async {
    final url = Uri.parse("$baseUrl/check-rekening/");
    final response = await AuthService.authorizedPost(
      url,
      body: jsonEncode({
        'bank_name': 'IKE Bank',
        'account_number': accountNumber,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Failed to check rekening (HTTP ${response.statusCode}): ${response.body}',
      );
    }
  }
}
