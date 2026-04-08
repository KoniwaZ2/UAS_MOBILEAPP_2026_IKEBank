import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ikebank/screens/home/saku_celengan/pindah_dana_celengan_screen.dart';
import '../../../api/banking.dart';
import '../../../widgets/action_square_button.dart';
import '../../../widgets/transaction_card.dart';
import '../../../widgets/filter_bottom_sheet.dart';
import 'tambah_dana_nabung_ai_screen.dart';
import '../promo_screen.dart';
import '../reward_screen.dart';
import '../../bottomnav/lainnya/undang_teman_screen.dart';
import '../saku_utama/riwayat_transaksi_screen.dart';

class SakuCelenganScreen extends StatefulWidget {
  const SakuCelenganScreen({super.key});

  @override
  State<SakuCelenganScreen> createState() => _SakuCelenganScreenState();
}

class _SakuCelenganScreenState extends State<SakuCelenganScreen>
    with WidgetsBindingObserver {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static const String _cooldownKey = 'nabung_cooldown_until';
  static const String _autoIsiKey = 'nabung_auto_isi_enabled';

  bool isAutoIsi = true;
  bool hasAddedFund =
      false; // TAMBAHAN: State untuk nge-cek apakah sudah tambah dana
  DateTime? _nextNabungAt;
  Timer? _countdownTimer;
  bool _isLoadingCelengan = true;
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoadingTransactions = true;
  String _celenganName = 'Saku Celengan';
  String _celenganBalance = 'Rp 8.000.000';
  String _celenganImageAsset = 'assets/images/celengan.png';
  String _savingRecommendationAmount = 'Rp 500.000';
  int _savingRecommendationValue = 0;
  bool _isLoadingSavingRecommendation = true;
  TransactionFilter _activeFilter = const TransactionFilter.initial();
  String _celenganSakuId = '';
  String _autoIsiSourceSakuId = '';
  bool _isAutoIsiProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadAutoIsiPreference();
    _loadNabungAiStateFromServer();
    _loadCelenganData();
    _loadSavingRecommendation();
    _loadCooldownState();
    _loadTransactionHistory();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadNabungAiStateFromServer();
      _loadCelenganData();
      _loadSavingRecommendation();
      _loadCooldownState();
      _loadTransactionHistory();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadCooldownState() async {
    try {
      final savedTime = await _secureStorage.read(key: _cooldownKey);

      print('📱 Loading cooldown state... savedTime: $savedTime');

      if (savedTime != null && savedTime.isNotEmpty) {
        _nextNabungAt = DateTime.parse(savedTime);

        final now = DateTime.now();
        print('⏰ Cooldown deadline: $_nextNabungAt');
        print('⏰ Current time: $now');

        if (_nextNabungAt!.isBefore(now)) {
          // Cooldown sudah expired
          print('✅ Cooldown expired');
          await _handleCooldownFinished();
        } else {
          // Cooldown masih aktif, resume countdown
          print('🔄 Resuming countdown from saved state');
          if (!mounted) return;
          setState(() {
            hasAddedFund = true;
          });
          _startCooldownTimer();
        }
      } else {
        print('❌ No saved cooldown state');
      }
    } catch (e) {
      print('❌ Error loading cooldown: $e');
    }
  }

  Future<void> _loadAutoIsiPreference() async {
    try {
      final saved = await _secureStorage.read(key: _autoIsiKey);
      if (!mounted || saved == null) {
        return;
      }

      final normalized = saved.trim().toLowerCase();
      final enabled = normalized == 'true' || normalized == '1';

      setState(() {
        isAutoIsi = enabled;
      });
    } catch (_) {
      // Ignore storage read issues and keep default value.
    }
  }

  Future<void> _loadNabungAiStateFromServer() async {
    try {
      final state = await BankingService.fetchNabungAiState();

      final autoIsiRaw = state['auto_isi'];
      final cooldownRaw = state['cooldown_until'];

      bool remoteAutoIsi = isAutoIsi;
      if (autoIsiRaw is bool) {
        remoteAutoIsi = autoIsiRaw;
      } else if (autoIsiRaw is num) {
        remoteAutoIsi = autoIsiRaw != 0;
      } else if (autoIsiRaw is String) {
        final normalized = autoIsiRaw.trim().toLowerCase();
        remoteAutoIsi = normalized == 'true' || normalized == '1';
      }

      DateTime? remoteCooldown;
      if (cooldownRaw is String && cooldownRaw.trim().isNotEmpty) {
        remoteCooldown = DateTime.tryParse(cooldownRaw)?.toLocal();
      }

      if (!mounted) {
        return;
      }

      setState(() {
        isAutoIsi = remoteAutoIsi;
        _nextNabungAt = remoteCooldown;
        hasAddedFund =
            remoteCooldown != null && remoteCooldown.isAfter(DateTime.now());
      });

      if (_nextNabungAt != null && _nextNabungAt!.isAfter(DateTime.now())) {
        _startCooldownTimer();
      }

      await _saveAutoIsiPreference(remoteAutoIsi);
      await _saveCooldownState();
    } catch (_) {
      // Keep local state if remote state fetch fails.
    }
  }

  Future<void> _saveAutoIsiPreference(bool value) async {
    try {
      await _secureStorage.write(key: _autoIsiKey, value: value.toString());
      try {
        await BankingService.updateNabungAiState(autoIsi: value);
      } catch (_) {
        // Keep local state if remote save fails.
      }
    } catch (_) {
      // Ignore storage write issues.
    }
  }

  Future<void> _saveCooldownState() async {
    try {
      if (_nextNabungAt != null) {
        await _secureStorage.write(
          key: _cooldownKey,
          value: _nextNabungAt!.toIso8601String(),
        );
        try {
          await BankingService.updateNabungAiState(
            cooldownUntil: _nextNabungAt,
          );
        } catch (_) {
          // Keep local state if remote save fails.
        }
      } else {
        await _secureStorage.delete(key: _cooldownKey);
        try {
          await BankingService.updateNabungAiState(clearCooldown: true);
        } catch (_) {
          // Keep local state if remote save fails.
        }
      }
    } catch (_) {}
  }

  void _startCooldownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }

      final remaining = _remainingCooldown;
      if (remaining == Duration.zero) {
        _countdownTimer?.cancel();
        _handleCooldownFinished();
        return;
      }

      setState(() {});
    });
  }

  Duration get _remainingCooldown {
    if (_nextNabungAt == null) {
      return Duration.zero;
    }
    final diff = _nextNabungAt!.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  void _startNabungCooldown() {
    _nextNabungAt = DateTime.now().add(const Duration(days: 7));
    print('🚀 Starting 7-day countdown until: $_nextNabungAt');
    hasAddedFund = true;
    _saveCooldownState();
    _startCooldownTimer();
  }

  Future<void> _handleCooldownFinished() async {
    if (_isAutoIsiProcessing) {
      return;
    }

    if (isAutoIsi) {
      final success = await _runAutoIsiTransfer();
      if (!mounted) {
        return;
      }

      if (success) {
        setState(() {
          _startNabungCooldown();
        });
        return;
      }
    }

    if (!mounted) {
      return;
    }
    setState(() {
      hasAddedFund = false;
      _nextNabungAt = null;
    });
    await _saveCooldownState();
  }

  Future<bool> _runAutoIsiTransfer() async {
    if (_isAutoIsiProcessing) {
      return false;
    }

    if (_celenganSakuId.isEmpty || _autoIsiSourceSakuId.isEmpty) {
      return false;
    }

    if (_savingRecommendationValue <= 0) {
      await _loadSavingRecommendation();
    }

    if (_savingRecommendationValue <= 0) {
      return false;
    }

    _isAutoIsiProcessing = true;
    try {
      await BankingService.internalTransfer(
        sourceSakuId: _autoIsiSourceSakuId,
        destinationSakuId: _celenganSakuId,
        amount: _savingRecommendationValue.toString(),
        description: 'Auto isi Nabung AI',
      );

      await _loadCelenganData();
      await _loadSavingRecommendation();
      await _loadTransactionHistory();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Auto isi berhasil: ${_formatRupiah(_savingRecommendationValue.toString())}',
            ),
          ),
        );
      }

      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    } finally {
      _isAutoIsiProcessing = false;
    }
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  String _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null) {
        final text = value.toString().trim();
        if (text.isNotEmpty) {
          return text;
        }
      }
    }
    return '';
  }

  bool _readBool(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' || normalized == '1';
    }
    return false;
  }

  String _formatRupiah(String rawBalance) {
    final digitsOnly = rawBalance.replaceAll(RegExp(r'[^0-9]'), '');
    final value = int.tryParse(digitsOnly) ?? 0;
    final text = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      final remaining = text.length - i;
      buffer.write(text[i]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write('.');
      }
    }
    return 'Rp ${buffer.toString()}';
  }

  int _parseBalanceToInt(String rawBalance) {
    final digitsOnly = rawBalance.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digitsOnly) ?? 0;
  }

  String _resolveCelenganImage(Map<String, dynamic> saku) {
    final category = _readString(saku, const [
      'category_name',
      'category',
    ]).toLowerCase();
    final name = _readString(saku, const ['saku_name', 'name']).toLowerCase();

    if (name.contains('celengan') || category.contains('celengan')) {
      return 'assets/images/celengan.png';
    }

    return 'assets/images/celengan.png';
  }

  String _formatCategoryLabel(String rawCategory) {
    final normalized = rawCategory.replaceAll('_', ' ').trim();
    if (normalized.isEmpty) {
      return '';
    }

    return normalized
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .map(
          (word) =>
              '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  Future<List<Map<String, dynamic>>> _loadTransferTargets() async {
    final raw = await BankingService.sakuList();
    final dynamic payload = raw is Map<String, dynamic>
        ? (raw['data'] ?? raw['results'] ?? raw['sakus'] ?? raw)
        : raw;

    if (payload is! List) {
      return <Map<String, dynamic>>[];
    }

    final targets = payload.whereType<Map<String, dynamic>>().where((saku) {
      final name = _readString(saku, const ['saku_name', 'name']).toLowerCase();
      final category = _readString(saku, const [
        'category_name',
        'category',
      ]).toLowerCase();
      final isDeposito =
          name.contains('deposito') || category.contains('deposito');
      final isCelengan =
          name.contains('celengan') || category.contains('celengan');
      return !isDeposito && !isCelengan;
    }).toList();

    targets.sort((a, b) {
      final nameA = _readString(a, const ['saku_name', 'name']).toLowerCase();
      final nameB = _readString(b, const ['saku_name', 'name']).toLowerCase();
      return nameA.compareTo(nameB);
    });

    return targets;
  }

  Future<void> _loadCelenganData() async {
    try {
      final raw = await BankingService.sakuList();
      final dynamic payload = raw is Map<String, dynamic>
          ? (raw['data'] ?? raw['results'] ?? raw['sakus'] ?? raw)
          : raw;

      if (payload is! List) {
        return;
      }

      final sakus = payload.whereType<Map<String, dynamic>>().toList();
      final celenganSakus = sakus.where((saku) {
        final name = _readString(saku, const [
          'saku_name',
          'name',
        ]).toLowerCase();
        final category = _readString(saku, const [
          'category_name',
          'category',
        ]).toLowerCase();
        return name.contains('celengan') || category.contains('celengan');
      }).toList();

      if (celenganSakus.isEmpty) {
        if (!mounted) {
          return;
        }

        setState(() {
          _isLoadingCelengan = false;
        });
        return;
      }

      final celenganSaku = celenganSakus.firstWhere(
        (saku) => _readBool(saku, 'is_primary'),
        orElse: () => celenganSakus.first,
      );
      final celenganSakuId = _readString(celenganSaku, const ['id', 'saku_id']);

      final autoIsiSourceCandidates = sakus.where((saku) {
        final name = _readString(saku, const [
          'saku_name',
          'name',
        ]).toLowerCase();
        final category = _readString(saku, const [
          'category_name',
          'category',
        ]).toLowerCase();
        final isDeposito =
            name.contains('deposito') || category.contains('deposito');
        final isCelengan =
            name.contains('celengan') || category.contains('celengan');
        final isCurrentCelengan =
            _readString(saku, const ['id', 'saku_id']) == celenganSakuId;
        return !isDeposito && !isCelengan && !isCurrentCelengan;
      }).toList();

      final autoIsiSource = autoIsiSourceCandidates.firstWhere(
        (saku) => _readBool(saku, 'is_primary'),
        orElse: () => autoIsiSourceCandidates.isNotEmpty
            ? autoIsiSourceCandidates.first
            : <String, dynamic>{},
      );
      final autoIsiSourceId = _readString(autoIsiSource, const [
        'id',
        'saku_id',
      ]);

      final name = _readString(celenganSaku, const ['saku_name', 'name']);
      final balance = _readString(celenganSaku, const ['balance']);
      final balanceValue = _parseBalanceToInt(balance);
      const targetValue = 10000000;
      final progress = targetValue == 0
          ? 0.0
          : (balanceValue / targetValue).clamp(0.0, 1.0).toDouble();

      if (!mounted) {
        return;
      }

      setState(() {
        _celenganName = name.isEmpty ? _celenganName : name;
        _celenganBalance = balance.isEmpty
            ? _celenganBalance
            : _formatRupiah(balance);
        _celenganImageAsset = _resolveCelenganImage(celenganSaku);
        _celenganSakuId = celenganSakuId;
        _autoIsiSourceSakuId = autoIsiSourceId;
        _isLoadingCelengan = false;
        // Progress tetap mengikuti saldo API, target tampilan masih 10 jt.
        _celenganProgress = progress;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingCelengan = false;
      });
    }
  }

  Future<void> _loadSavingRecommendation() async {
    try {
      final raw = await BankingService.savingRecommendation();
      final payload = raw is Map<String, dynamic>
          ? (raw['data'] ?? raw['result'] ?? raw)
          : raw;

      num? recommendationAmount;
      if (payload is Map<String, dynamic>) {
        final dynamic value =
            payload['recommendation_amount'] ??
            payload['recommended_amount'] ??
            payload['amount'] ??
            payload['nominal'];
        if (value is num) {
          recommendationAmount = value;
        } else if (value != null) {
          recommendationAmount = num.tryParse(value.toString());
        }
      } else if (payload is num) {
        recommendationAmount = payload;
      } else if (payload != null) {
        recommendationAmount = num.tryParse(payload.toString());
      }

      if (!mounted) {
        return;
      }

      setState(() {
        if (recommendationAmount != null && recommendationAmount >= 0) {
          _savingRecommendationValue = recommendationAmount.toInt();
          _savingRecommendationAmount = _formatRupiah(
            recommendationAmount.toString(),
          );
        } else {
          _savingRecommendationValue = 0;
        }
        _isLoadingSavingRecommendation = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingSavingRecommendation = false;
      });
    }
  }

  Future<void> _loadTransactionHistory() async {
    setState(() {
      _isLoadingTransactions = true;
    });

    try {
      final transactions = await BankingService.transactionHistory();
      final filteredTransactions = _applyTransactionFilter(
        transactions,
        _activeFilter,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _transactions = filteredTransactions;
        _isLoadingTransactions = false;
      });
    } catch (e) {
      debugPrint('Error loading transactions: $e');
      if (!mounted) {
        return;
      }

      setState(() {
        _transactions = [];
        _isLoadingTransactions = false;
      });
    }
  }

  List<Map<String, dynamic>> _applyTransactionFilter(
    List<Map<String, dynamic>> transactions,
    TransactionFilter filter,
  ) {
    DateTime now = DateTime.now();
    DateTime? startDate;
    DateTime? endDate;

    switch (filter.periode) {
      case FilterPeriode.last7Days:
        startDate = DateUtils.dateOnly(now.subtract(const Duration(days: 6)));
        endDate = DateUtils.dateOnly(now);
        break;
      case FilterPeriode.last30Days:
        startDate = DateUtils.dateOnly(now.subtract(const Duration(days: 29)));
        endDate = DateUtils.dateOnly(now);
        break;
      case FilterPeriode.customDate:
        startDate = filter.tanggalDari == null
            ? null
            : DateUtils.dateOnly(filter.tanggalDari!);
        endDate = filter.tanggalSampai == null
            ? null
            : DateUtils.dateOnly(filter.tanggalSampai!);
        break;
    }

    return transactions.where((tx) {
      final parsedDate = _parseTransactionDate(tx);
      final dateOnly = parsedDate == null
          ? null
          : DateUtils.dateOnly(parsedDate);

      if (startDate != null &&
          (dateOnly == null || dateOnly.isBefore(startDate))) {
        return false;
      }

      if (endDate != null && (dateOnly == null || dateOnly.isAfter(endDate))) {
        return false;
      }

      final isIncome = _isTransactionIncome(tx);
      if (filter.jenis == FilterJenisTransaksi.danaMasuk && !isIncome) {
        return false;
      }
      if (filter.jenis == FilterJenisTransaksi.danaKeluar && isIncome) {
        return false;
      }

      return true;
    }).toList();
  }

  bool _isTransactionIncome(Map<String, dynamic> transaction) {
    final category = _readString(transaction, const [
      'category',
      'category_name',
    ]).toLowerCase();

    if (category.contains('income') ||
        category.contains('transfer_in') ||
        category.contains('deposit') ||
        category.contains('bunga') ||
        category.contains('interest') ||
        category.contains('credit')) {
      return true;
    }

    if (category.contains('payment') ||
        category.contains('transfer_out') ||
        category.contains('withdraw') ||
        category.contains('expense')) {
      return false;
    }

    final description = _readString(transaction, const [
      'description',
    ]).toLowerCase();
    final sourceFunds = _readString(transaction, const [
      'source_funds',
    ]).toLowerCase();
    final amount = _readString(transaction, const ['amount', 'nominal']);

    if (amount.startsWith('-')) {
      return false;
    }

    if (sourceFunds.contains('internal transfer to')) {
      return false;
    }
    if (sourceFunds.contains('internal transfer from')) {
      return true;
    }
    if (description.contains('transfer to') || description.contains('keluar')) {
      return false;
    }
    if (description.contains('transfer from') ||
        description.contains('masuk') ||
        description.contains('terima')) {
      return true;
    }

    return true;
  }

  Future<void> _openTransactionFilter() async {
    final selected = await showFilterBottomSheet(
      context,
      initialFilter: _activeFilter,
    );

    if (selected == null || !mounted) {
      return;
    }

    setState(() {
      _activeFilter = selected;
    });
    await _loadTransactionHistory();
  }

  double _celenganProgress = 0.8;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0x1AFFCA96),
        elevation: 0,
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black, size: 28),
            onPressed: () {
              _showInfoSakuBottomSheet(context);
            },
          ),
        ],
        centerTitle: true,
        title: const Text(
          "Saku Celengan",
          style: TextStyle(
            fontFamily: 'AlumniSans',
            fontWeight: FontWeight.w800,
            fontSize: 24,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: 155,
              color: const Color(0x1AFFCA96),
            ),

            SingleChildScrollView(
              padding: const EdgeInsets.only(top: 8.0, bottom: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(
                                left: 20,
                                right: 20,
                                bottom: 20,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFD6CFFF),
                                      borderRadius: BorderRadius.vertical(
                                        bottom: Radius.circular(40),
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Image.asset(
                                      _celenganImageAsset,
                                      width: 65,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    "Total Dana",
                                    style: TextStyle(
                                      fontSize: 25,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _isLoadingCelengan
                                        ? 'Memuat...'
                                        : _celenganBalance,
                                    style: const TextStyle(
                                      fontFamily: 'AlumniSans',
                                      fontSize: 30,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFFFF7F00),
                                    ),
                                  ),
                                  const SizedBox(height: 1),

                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Container(
                                              height: 12,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                  color: const Color(
                                                    0x4D000000,
                                                  ),
                                                  width: 1,
                                                ),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(9),
                                                child: LinearProgressIndicator(
                                                  value: _celenganProgress,
                                                  backgroundColor: Colors.white,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(Color(0xFFF8C471)),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 1),
                                            const Text(
                                              "10jt",
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      GestureDetector(
                                        onTap: () {
                                          _showPindahDanaBottomSheet(context);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0x4DF69500),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Row(
                                            children: const [
                                              Icon(
                                                Icons.arrow_forward,
                                                color: Color(0xFFFF7F00),
                                                size: 16,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                "Pindahkan Dana",
                                                style: TextStyle(
                                                  color: Color(0xFFFF7F00),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            Positioned(
                              top: -1,
                              right: -1,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 26,
                                  vertical: 4,
                                ),
                                decoration: const BoxDecoration(
                                  color: Color(0x80FF7F00),
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(20),
                                    bottomLeft: Radius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  "10% p.a",
                                  style: TextStyle(
                                    color: Color(0xFF01008A),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        const Text(
                          "Cara Meningkatkan Dana Saku Celengan",
                          style: TextStyle(
                            fontFamily: 'AlumniSans',
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFFF7F00),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ==========================================
                        // CONTAINER NABUNG AI (YANG DIUBAH HANYA BAGIAN DALAM SINI)
                        // ==========================================
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "Nabung AI",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // LOGIKA PERUBAHAN TAMPILAN
                              if (!hasAddedFund) ...[
                                // BELUM DITAMBAH: Menampilkan nominal
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Expanded(
                                      child: Text(
                                        "Dana yang dapat kamu\nmasukkan ke Saku",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Color(0xFFFF7F00),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      _isLoadingSavingRecommendation
                                          ? "Memuat..."
                                          : _savingRecommendationAmount,
                                      style: const TextStyle(
                                        fontFamily: 'AlumniSans',
                                        fontSize: 28,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFFFF7F00),
                                      ),
                                    ),
                                  ],
                                ),
                              ] else ...[
                                // SUDAH DITAMBAH: Menampilkan Countdown
                                Text(
                                  "Waktu untuk menabung kembali",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFFFF7F00),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildCountdownBox(
                                      _remainingCooldown.inDays.toString(),
                                      "Hari",
                                    ),
                                    const SizedBox(width: 12),
                                    _buildCountdownBox(
                                      _twoDigits(
                                        _remainingCooldown.inHours % 24,
                                      ),
                                      "Jam",
                                    ),
                                    const SizedBox(width: 12),
                                    _buildCountdownBox(
                                      _twoDigits(
                                        _remainingCooldown.inMinutes % 60,
                                      ),
                                      "Menit",
                                    ),
                                    const SizedBox(width: 12),
                                    _buildCountdownBox(
                                      _twoDigits(
                                        _remainingCooldown.inSeconds % 60,
                                      ),
                                      "Detik",
                                    ),
                                  ],
                                ),
                              ],

                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: ElevatedButton(
                                      // JIKA SUDAH TAMBAH DANA, TOMBOL DISABLE (null)
                                      onPressed: hasAddedFund
                                          ? null
                                          : () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      TambahDanaNabungAiScreen(
                                                        amount:
                                                            _savingRecommendationAmount,
                                                      ),
                                                ),
                                              ).then((result) {
                                                if (!mounted) return;
                                                // KETIKA KEMBALI DARI LAYAR TAMBAH DANA, UBAH STATE JADI TRUE
                                                // HANYA JIKA LAYAR TAMBAH DANA MENGEMBALIKAN `true`
                                                if (result == true) {
                                                  setState(() {
                                                    _startNabungCooldown();
                                                  });
                                                }
                                              });
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFFF8C471,
                                        ),
                                        disabledBackgroundColor: Colors
                                            .grey
                                            .shade300, // Warna tombol saat disabled
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add,
                                            // Warna icon jadi abu-abu kalau disable
                                            color: hasAddedFund
                                                ? Colors.grey.shade500
                                                : const Color(0xFFFF7F00),
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "Tambah dana ke Saku",
                                            style: TextStyle(
                                              // Warna teks jadi abu-abu kalau disable
                                              color: hasAddedFund
                                                  ? Colors.grey.shade500
                                                  : const Color(0xFFFF7F00),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Row(
                                    children: [
                                      Switch(
                                        value: isAutoIsi,
                                        onChanged: (val) {
                                          setState(() {
                                            isAutoIsi = val;
                                          });
                                          _saveAutoIsiPreference(val);
                                        },
                                        activeThumbColor: Colors.white,
                                        activeTrackColor: const Color(
                                          0x80F69500,
                                        ),
                                      ),
                                      const Text(
                                        "Auto isi",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFFFF7F00),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // ==========================================
                        // BATAS CONTAINER NABUNG AI
                        // ==========================================
                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ActionSquareButton(
                              imageAsset: 'assets/images/cashback.png',
                              label: "Promo Cashback",
                              imageHeight: 32,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const PromoScreen(),
                                  ),
                                );
                              },
                            ),
                            ActionSquareButton(
                              imageAsset: 'assets/images/misi.png',
                              label: "Ikut Misi",
                              imageHeight: 45,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const RewardScreen(),
                                  ),
                                );
                              },
                            ),
                            ActionSquareButton(
                              imageAsset: 'assets/images/teman3.png',
                              label: "Undang Teman",
                              imageHeight: 45,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const UndangTemanScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),

                  Divider(
                    color: Colors.grey.shade400,
                    thickness: 1.5,
                    height: 1,
                  ),
                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        if (_isLoadingTransactions)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (_transactions.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                'Belum ada transaksi',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _buildGroupedTransactionWidgets(),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPindahDanaBottomSheet(BuildContext context) {
    Future<void> openSheet() async {
      final targets = await _loadTransferTargets();

      if (!mounted) {
        return;
      }

      if (targets.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada saku tujuan yang tersedia')),
        );
        return;
      }

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        backgroundColor: Colors.white,
        builder: (sheetContext) {
          return Padding(
            padding: const EdgeInsets.only(
              left: 24.0,
              right: 24.0,
              top: 16.0,
              bottom: 32.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Pindahkan ke',
                  style: TextStyle(
                    fontFamily: 'AlumniSans',
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                ...targets.map((saku) {
                  final destinationName = _readString(saku, const [
                    'saku_name',
                    'name',
                  ]);
                  final destinationBalance = _formatRupiah(
                    _readString(saku, const ['balance']),
                  );
                  final rawCategory = _readString(saku, const [
                    'category_name',
                    'category',
                  ]);
                  final categoryLabel = _formatCategoryLabel(rawCategory);
                  final isSvg = rawCategory.toLowerCase().contains('bag');
                  final destinationIconPath = _resolveCelenganImage(saku);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(sheetContext);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PindahDanaCelenganScreen(
                              destName: destinationName,
                              destBalance: destinationBalance,
                              destIconPath: destinationIconPath,
                              isSvg: isSvg,
                            ),
                          ),
                        );
                      },
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8F0),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFFFDBB7),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 55,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFD6CFFF),
                                    borderRadius: BorderRadius.vertical(
                                      bottom: Radius.circular(25),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: destinationIconPath.endsWith('.svg')
                                      ? SvgPicture.asset(
                                          destinationIconPath,
                                          height: 36,
                                          colorFilter: const ColorFilter.mode(
                                            Color(0xFFFF7F00),
                                            BlendMode.srcIn,
                                          ),
                                        )
                                      : Image.asset(
                                          destinationIconPath,
                                          height: 28,
                                          fit: BoxFit.contain,
                                          errorBuilder: (c, e, s) => const Icon(
                                            Icons.account_balance,
                                            color: Colors.blue,
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      destinationName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      destinationBalance,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (categoryLabel.isNotEmpty)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF7F00),
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(14),
                                    bottomLeft: Radius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  categoryLabel,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      );
    }

    openSheet();
  }

  void _showInfoSakuBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                "Saku Saya",
                style: TextStyle(
                  fontFamily: 'AlumniSans',
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 55,
                                height: 55,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFD6CFFF),
                                  borderRadius: BorderRadius.vertical(
                                    bottom: Radius.circular(25),
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Image.asset(
                                  _celenganImageAsset,
                                  height: 50,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _celenganName,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _celenganBalance,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              "*Kamu tidak dapat menambahkan dana langsung ke saku ini",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: Colors.grey.shade400),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14.0,
                        vertical: 4.0,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0x1AFFCA96),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(16),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$_celenganName - Bunga 10% p.a.',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCountdownBox(String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade400, width: 1.0),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF7F00),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFFFF7F00)),
        ),
      ],
    );
  }

  String _formatTransactionTime(String? dateString) {
    if (dateString == null || dateString.trim().isEmpty) {
      return '';
    }
    try {
      final date = DateTime.parse(dateString);
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$hour:$minute WIB';
    } catch (_) {
      return '';
    }
  }

  DateTime? _parseTransactionDate(Map<String, dynamic> transaction) {
    final raw = _readString(transaction, const [
      'timestamp',
      'created_at',
      'date',
      'transaction_date',
    ]);

    if (raw.isEmpty) {
      return null;
    }

    return DateTime.tryParse(raw);
  }

  String _formatTransactionDateHeader(DateTime date) {
    const weekdays = <String>[
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    const months = <String>[
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];
    return '$weekday, ${date.day} $month ${date.year}';
  }

  List<Widget> _buildGroupedTransactionWidgets() {
    final transactions = List<Map<String, dynamic>>.from(_transactions);
    transactions.sort((a, b) {
      final dateA = _parseTransactionDate(a);
      final dateB = _parseTransactionDate(b);
      if (dateA == null && dateB == null) {
        return 0;
      }
      if (dateA == null) {
        return 1;
      }
      if (dateB == null) {
        return -1;
      }
      return dateB.compareTo(dateA);
    });

    final widgets = <Widget>[];
    DateTime? activeDate;
    bool hasUntitledDateGroup = false;
    bool hasPlacedFilterOnHeader = false;

    for (final tx in transactions) {
      final parsedDate = _parseTransactionDate(tx);
      final dateOnly = parsedDate == null
          ? null
          : DateUtils.dateOnly(parsedDate);

      final shouldInsertDateHeader = dateOnly == null
          ? !hasUntitledDateGroup
          : activeDate == null || activeDate != dateOnly;

      if (shouldInsertDateHeader) {
        late final Widget headerText;

        if (dateOnly == null) {
          hasUntitledDateGroup = true;
          headerText = const Text(
            'Tanpa tanggal',
            style: TextStyle(
              color: Color(0xFFFF7F00),
              fontSize: 18,
              fontFamily: 'AlumniSans',
              fontWeight: FontWeight.w800,
            ),
          );
        } else {
          activeDate = dateOnly;
          headerText = Text(
            _formatTransactionDateHeader(dateOnly),
            style: const TextStyle(
              color: Color(0xFFFF7F00),
              fontSize: 18,
              fontFamily: 'AlumniSans',
              fontWeight: FontWeight.w800,
            ),
          );
        }

        if (!hasPlacedFilterOnHeader) {
          widgets.add(
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                headerText,
                GestureDetector(
                  onTap: () async {
                    await _openTransactionFilter();
                  },
                  child: SvgPicture.asset(
                    'assets/images/history.svg',
                    width: 28,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFFFF7F00),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
          );
          hasPlacedFilterOnHeader = true;
        } else {
          widgets.add(headerText);
        }

        widgets.add(const SizedBox(height: 12));
      }

      final title = _readString(tx, const [
        'description',
        'merchant_name',
        'category',
      ]);
      final subTitle = _readString(tx, const [
        'category',
        'category_name',
        'transaction_type',
        'type',
      ]);
      final amount = _readString(tx, const ['amount', 'nominal']);
      final timestamp = _readString(tx, const [
        'timestamp',
        'created_at',
        'transaction_date',
        'date',
      ]);
      final isExpense = _readBool(tx, 'is_debit') || amount.startsWith('-');

      widgets.add(
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RiwayatTransaksiScreen(),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TransactionCard(
              title: title.isEmpty ? 'Transaksi' : title,
              subTitle: subTitle.isEmpty
                  ? 'Saku Celengan'
                  : _formatCategoryLabel(subTitle),
              amount: amount.isEmpty
                  ? _formatRupiah('0')
                  : _formatRupiah(amount),
              time: _formatTransactionTime(timestamp),
              imageAsset: 'assets/images/celengan.png',
              isExpense: isExpense,
            ),
          ),
        ),
      );
    }

    return widgets;
  }
}
