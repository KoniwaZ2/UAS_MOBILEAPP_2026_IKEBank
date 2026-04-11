import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'riwayat_transaksi_screen.dart';
import '../tambah_dana_screen.dart';
import 'tambah_dana_saku_screen.dart';
import 'pindah_dana_screen.dart';
import 'transfer_dana_screen.dart';
import '../../bottomnav/kartu/buat_kartu_screen.dart';
import '../../../api/banking.dart';
import '../../../widgets/filter_bottom_sheet.dart';

class SakuUtamaScreen extends StatefulWidget {
  final String title;
  final String amount;
  final String imageAsset;

  const SakuUtamaScreen({
    super.key,
    this.title = "Saku Utama",
    this.amount = "Rp 3.000.000",
    this.imageAsset = 'assets/images/IKEHome.png',
  });

  @override
  State<SakuUtamaScreen> createState() => _SakuUtamaScreenState();
}

class _SakuUtamaScreenState extends State<SakuUtamaScreen> {
  String _accountNumber = '-';
  String _currentSakuId = '';
  late String _sakuTitle;
  late String _sakuAmount;
  late String _sakuImageAsset;
  String _cardNumber = '';
  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> _destinationSakus = [];
  bool _isLoadingTransactions = false;
  bool _shouldReturnRefresh = false;
  TransactionFilter _activeFilter = const TransactionFilter.noFilter();

  Future<void> _refreshIfChanged(dynamic result) async {
    if (result == true && mounted) {
      _shouldReturnRefresh = true;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Data saku diperbarui')));
      await _loadSakuUtamaData();
    }
  }

  void _popWithRefreshFlag() {
    Navigator.pop(context, _shouldReturnRefresh);
  }

  @override
  void initState() {
    super.initState();
    _sakuTitle = widget.title;
    _sakuAmount = widget.amount;
    _sakuImageAsset = widget.imageAsset;
    _cardNumber = '';
    _loadSakuUtamaData();
  }

  Future<void> _loadSakuUtamaData() async {
    try {
      final accountDetails = await BankingService.fetchAccountDetails();
      final accountNumber = accountDetails.isNotEmpty
          ? accountDetails.first.accountnumber
          : '-';
      final accountCardNumber = accountDetails.isNotEmpty
          ? (accountDetails.first.cardnumber ?? '')
          : '';

      final rawSakuList = await BankingService.sakuList();
      final dynamic payload = rawSakuList is Map<String, dynamic>
          ? (rawSakuList['data'] ??
                rawSakuList['results'] ??
                rawSakuList['sakus'] ??
                rawSakuList)
          : rawSakuList;

      List<Map<String, dynamic>> sakus = [];

      Map<String, dynamic>? primarySaku;
      if (payload is List) {
        sakus = payload.whereType<Map<String, dynamic>>().toList();

        for (final saku in sakus) {
          if (_readBool(saku, 'is_primary')) {
            primarySaku = saku;
            break;
          }
        }

        primarySaku ??= sakus.cast<Map<String, dynamic>?>().firstWhere(
          (s) => _readString(s ?? const {}, const [
            'saku_name',
            'name',
          ]).toLowerCase().contains('utama'),
          orElse: () => null,
        );

        primarySaku ??= sakus.isNotEmpty ? sakus.first : null;
      }

      var mergedSaku = primarySaku ?? <String, dynamic>{};
      final sakuId = _readString(mergedSaku, const ['id', 'saku_id']);
      if (sakuId.isNotEmpty) {
        try {
          final detail = await BankingService.sakuDetail(sakuId: sakuId);
          mergedSaku = {...mergedSaku, ...detail};
        } catch (_) {
          // Keep fallback data from saku-list when saku-detail is unavailable.
        }
      }

      if (!mounted) {
        return;
      }

      final name = _readString(mergedSaku, const ['saku_name', 'name']);
      final balance = _readString(mergedSaku, const ['balance']);
      final targetSakuId = _readString(mergedSaku, const ['id', 'saku_id']);

      final destinationSakus = sakus.where((saku) {
        final sakuId = _readString(saku, const ['id', 'saku_id']);
        final sakuName = _readString(saku, const [
          'saku_name',
          'name',
        ]).toLowerCase();
        final category = _readString(saku, const [
          'category_name',
          'category',
        ]).toLowerCase();
        final isDeposito =
            category.contains('deposito') || sakuName.contains('deposito');
        final isSameAsPrimary = sakuId == targetSakuId;
        return !isDeposito && !isSameAsPrimary;
      }).toList();

      setState(() {
        _accountNumber = accountNumber.trim().isEmpty ? '-' : accountNumber;
        _currentSakuId = targetSakuId;
        _cardNumber = accountCardNumber.trim();
        _sakuTitle = name.isEmpty ? widget.title : name;
        _sakuAmount = balance.isEmpty ? widget.amount : _formatRupiah(balance);
        _sakuImageAsset = _resolveSakuImage(mergedSaku);
        _destinationSakus = destinationSakus;
      });

      // Fetch transaction history for this saku
      if (targetSakuId.isNotEmpty) {
        _loadTransactionHistory(targetSakuId);
      }
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadTransactionHistory(String sakuId) async {
    setState(() {
      _isLoadingTransactions = true;
    });

    try {
      final transactions = await BankingService.transactionHistory(
        sakuId: sakuId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _transactions = _applyTransactionFilter(transactions);
        _isLoadingTransactions = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingTransactions = false;
      });

      // Silent fail - show empty list if transaction load fails
      debugPrint('Error loading transactions: $e');
    }
  }

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

  String _resolveSakuImage(Map<String, dynamic> saku) {
    final category = _readString(saku, const [
      'category_name',
      'category',
    ]).toLowerCase();
    final name = _readString(saku, const ['saku_name', 'name']).toLowerCase();

    if (name.contains('utama')) {
      return 'assets/images/IKEHome.png';
    }
    if (name.contains('deposito') || category.contains('deposito')) {
      return 'assets/images/deposito.png';
    }
    if (name.contains('celengan') || category.contains('celengan')) {
      return 'assets/images/celengan.png';
    }
    return widget.imageAsset;
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
    } catch (e) {
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

    for (final transaction in transactions) {
      final parsedDate = _parseTransactionDate(transaction);
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
                  onTap: () {
                    _showFilterBottomSheet(context);
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

        widgets.add(const SizedBox(height: 16));
      }

      final title = _readString(transaction, const ['description']);
      final category = _readString(transaction, const [
        'category',
        'category_name',
      ]);
      final categoryLabel = _formatCategoryLabel(category);
      final amount = _readString(transaction, const ['amount']);
      final timestamp = _readString(transaction, const [
        'timestamp',
        'created_at',
      ]);
      final isIncome = _isTransactionIncome(transaction);
      final iconPath = _getTransactionIcon(transaction);
        final sourceFunds = _readString(transaction, const [
        'source_funds',
        'merchant_name',
        ]);
        final referenceNumber = _readString(transaction, const ['transaction_id']);
        final currentSakuInfo = _accountNumber == '-'
          ? _sakuTitle
          : '$_sakuTitle\n$_accountNumber';
        final fromInfo = isIncome
          ? (sourceFunds.isEmpty ? '-' : sourceFunds)
          : currentSakuInfo;
        final toInfo = isIncome
          ? currentSakuInfo
          : (sourceFunds.isEmpty ? '-' : sourceFunds);

      final formattedAmount = isIncome
          ? '+${_formatRupiah(amount)}'
          : '-${_formatRupiah(amount)}';

      widgets.add(
        _buildTransactionItem(
          imagePath: iconPath,
          title: title.isEmpty ? 'Transaksi' : title,
          subtitle: categoryLabel.isEmpty ? 'IKE Bank' : categoryLabel,
          amount: formattedAmount,
          time: _formatTransactionTime(timestamp),
          isIncome: isIncome,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RiwayatTransaksiScreen(
                  transactionTitle: title.isEmpty ? 'Transaksi' : title,
                  amount: formattedAmount,
                  isIncome: isIncome,
                  fromInfo: fromInfo,
                  toInfo: toInfo,
                  referenceNumber: referenceNumber,
                  status: 'Berhasil',
                  transactionTimeRaw: timestamp,
                  transactionTypeLabel: isIncome ? 'Dana masuk' : 'Dana keluar',
                ),
              ),
            );
          },
        ),
      );
    }

    return widgets;
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

  String _buildSakuCategoryLabel(Map<String, dynamic> saku) {
    final category = _readString(saku, const ['category_name', 'category']);
    return _formatCategoryLabel(category);
  }

  String? _getTransactionIcon(Map<String, dynamic> transaction) {
    final category = _readString(transaction, const [
      'category',
      'category_name',
    ]).toLowerCase();
    final description = _readString(transaction, const [
      'description',
    ]).toLowerCase();

    if (category.contains('deposit') || description.contains('pencairan')) {
      return 'assets/images/deposito.png';
    }
    if (category.contains('bunga') ||
        description.contains('bunga') ||
        description.contains('interest')) {
      return 'assets/images/bunga.png';
    }
    if (category.contains('income') ||
        category.contains('transfer_in') ||
        description.contains('masuk') ||
        description.contains('terima')) {
      return null; // Use default icon (add)
    }
    return null; // Use default icon (arrow_forward)
  }

  bool _isTransactionIncome(Map<String, dynamic> transaction) {
    final category = _readString(transaction, const [
      'category',
      'category_name',
    ]).toLowerCase();

    // Income categories
    if (category.contains('income') ||
        category.contains('deposit') ||
        category.contains('transfer_in') ||
        category.contains('bunga') ||
        category.contains('interest') ||
        category.contains('credit')) {
      return true;
    }

    // Expense categories (payment, transfer, withdraw, etc)
    if (category.contains('payment') ||
        category.contains('transfer_out') ||
        category.contains('withdraw') ||
        category.contains('expense')) {
      return false;
    }

    // For generic category like `other`, infer direction from text fields.
    // `source_funds` from backend is the most reliable marker:
    // - Internal transfer to <Saku>   => expense
    // - Internal transfer from <Saku> => income
    final description = _readString(transaction, const [
      'description',
    ]).toLowerCase();
    final sourceFunds = _readString(transaction, const [
      'source_funds',
    ]).toLowerCase();

    if (sourceFunds.contains('internal transfer to')) {
      return false;
    }
    if (sourceFunds.contains('internal transfer from')) {
      return true;
    }

    if (description.contains('transfer to')) {
      return false;
    }
    if (description.contains('transfer from')) {
      return true;
    }

    final hints = '$description $sourceFunds';

    if (hints.contains('masuk') ||
        hints.contains('terima') ||
        hints.contains('pencairan')) {
      return true;
    }

    if (hints.contains('keluar') || hints.contains('bayar')) {
      return false;
    }

    return false;
  }

  List<Map<String, dynamic>> _applyTransactionFilter(
    List<Map<String, dynamic>> transactions,
  ) {
    final filter = _activeFilter;
    if (filter.periode == FilterPeriode.all &&
        filter.jenis == FilterJenisTransaksi.all) {
      return transactions;
    }

    final now = DateTime.now();
    DateTime? startDate;
    DateTime? endDate;

    if (filter.periode != FilterPeriode.all) {
      switch (filter.periode) {
        case FilterPeriode.all:
          break;
        case FilterPeriode.last7Days:
          startDate = DateUtils.dateOnly(now.subtract(const Duration(days: 6)));
          endDate = DateUtils.dateOnly(now);
          break;
        case FilterPeriode.last30Days:
          startDate = DateUtils.dateOnly(
            now.subtract(const Duration(days: 29)),
          );
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
    }

    return transactions.where((transaction) {
      if (filter.periode != FilterPeriode.all) {
        final parsedDate = _parseTransactionDate(transaction);
        final dateOnly = parsedDate == null
            ? null
            : DateUtils.dateOnly(parsedDate);

        if (startDate != null &&
            (dateOnly == null || dateOnly.isBefore(startDate))) {
          return false;
        }
        if (endDate != null &&
            (dateOnly == null || dateOnly.isAfter(endDate))) {
          return false;
        }
      }

      if (filter.jenis != FilterJenisTransaksi.all) {
        final isIncome = _isTransactionIncome(transaction);
        if (filter.jenis == FilterJenisTransaksi.danaMasuk && !isIncome) {
          return false;
        }
        if (filter.jenis == FilterJenisTransaksi.danaKeluar && isIncome) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    bool isSvg = _sakuImageAsset.toLowerCase().endsWith('.svg');

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.55],
          colors: [Color(0xFFFFF7EE), Color(0xFFFFEEDB)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          toolbarHeight: 50,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
            onPressed: _popWithRefreshFlag,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_horiz, color: Colors.black, size: 28),
              onPressed: () {
                _showSakuBottomSheet(context);
              },
            ),
          ],
          centerTitle: true,
          title: Transform.translate(
            offset: const Offset(0, 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _sakuTitle,
                  style: const TextStyle(
                    fontFamily: 'AlumniSans',
                    fontWeight: FontWeight.w800,
                    fontSize: 26,
                    color: Colors.black,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Nomor rekening  ",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color.fromARGB(255, 107, 107, 107),
                      ),
                    ),
                    Text(
                      '$_accountNumber ',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: _accountNumber));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Nomor rekening berhasil disalin!"),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: SvgPicture.asset(
                          'assets/images/copy.svg',
                          height: 14,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFFFF7F00),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 50),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                        top: 60,
                        bottom: 24,
                        left: 16,
                        right: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Dana tersedia",
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _sakuAmount,
                            style: const TextStyle(
                              fontFamily: 'AlumniSans',
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFFF7F00),
                            ),
                          ),
                          const SizedBox(height: 2),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildActionButton(
                                icon: Icons.add,
                                label: "Tambah dana",
                                onTap: () {
                                  _showTambahDanaBottomSheet(context);
                                },
                              ),
                              _buildActionButton(
                                svgPath: 'assets/images/pindah.svg',
                                label: "Pindah dana",
                                onTap: () {
                                  _showPindahkanKeBottomSheet(context);
                                },
                              ),
                              _buildActionButton(
                                icon: Icons.arrow_forward,
                                label: "Kirim & bayar",
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const TransferDanaScreen(),
                                    ),
                                  );
                                  await _refreshIfChanged(result);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Positioned(
                      top: -30,
                      child: Container(
                        width: 70,
                        height: 75,
                        decoration: const BoxDecoration(
                          color: Color(0xFFCCCCFF),
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(35),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: isSvg
                            ? SvgPicture.asset(
                                _sakuImageAsset,
                                height: 50,
                                fit: BoxFit.contain,
                              )
                            : Image.asset(
                                _sakuImageAsset,
                                height: 50,
                                fit: BoxFit.contain,
                                errorBuilder: (c, e, s) =>
                                    const Icon(Icons.image, color: Colors.grey),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              GestureDetector(
                onTap: _cardNumber.isEmpty
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BuatKartuScreen(),
                          ),
                        );
                      }
                    : null,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24.0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 16.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/images/kartu.svg',
                        height: 24,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFFFF7F00),
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _cardNumber.isEmpty
                              ? 'Request kartu'
                              : 'Kartu debit terhubung: $_cardNumber',
                          style: TextStyle(
                            fontSize: 16,
                            color: _cardNumber.isEmpty
                                ? const Color(0xFFFF7F00)
                                : Colors.black87,
                            fontWeight: _cardNumber.isEmpty
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: const Color(0xFFFF7F00).withOpacity(0.7),
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    left: 24.0,
                    right: 24.0,
                    top: 24.0,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 45,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: const TextField(
                                decoration: InputDecoration(
                                  hintText: "Cari transaksi",
                                  hintStyle: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: Colors.black87,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () {
                              _showFilterBottomSheet(context);
                            },
                            child: SvgPicture.asset(
                              'assets/images/history.svg',
                              height: 28,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // dummy history transaksi
                      Expanded(
                        child: _isLoadingTransactions
                            ? const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFFFF7F00),
                                  ),
                                ),
                              )
                            : _transactions.isEmpty
                            ? Center(
                                child: Text(
                                  'Belum ada transaksi',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              )
                            : ListView(
                                physics: const BouncingScrollPhysics(),
                                children: _buildGroupedTransactionWidgets(),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    IconData? icon,
    String? svgPath,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: const Color(0x80F69500),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: svgPath != null
                ? SvgPicture.asset(
                    svgPath,
                    height: 50,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  )
                : Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFF7F00),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem({
    IconData? icon, // Sekarang nullable
    String? imagePath, // Tambahan untuk gambar
    required String title,
    required String subtitle,
    required String amount,
    required String time,
    required bool isIncome,
    VoidCallback? onTap, // Tambahan agar bisa diklik
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFFFCA96).withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              // Jika ada imagePath, gunakan gambar. Jika tidak, gunakan Icon.
              child: imagePath != null
                  ? Image.asset(imagePath, height: 28, fit: BoxFit.contain)
                  : Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isIncome
                        ? const Color(0xFF00B14F)
                        : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSakuBottomSheet(BuildContext context) {
    final currentImageAsset = _sakuImageAsset;
    final isSvg = currentImageAsset.toLowerCase().endsWith('.svg');

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (sheetContext) {
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
                      child: Row(
                        children: [
                          Container(
                            width: 55,
                            height: 55,
                            decoration: const BoxDecoration(
                              color: Color(0xFFCCCCFF),
                              borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(25),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: isSvg
                                ? SvgPicture.asset(
                                    currentImageAsset,
                                    height: 30,
                                    fit: BoxFit.contain,
                                  )
                                : Image.asset(
                                    currentImageAsset,
                                    height: 30,
                                    fit: BoxFit.contain,
                                    errorBuilder: (c, e, s) => const Icon(
                                      Icons.image,
                                      color: Colors.grey,
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _sakuTitle,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _sakuAmount,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
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
                        vertical: 8.0,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0x1AFFCA96),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(16),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "$_sakuTitle - Bunga 0.5% p.a.",
                        style: const TextStyle(
                          fontSize: 18,
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

  void _showTambahDanaBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
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
              // 1. Drag Handle
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
                "Tambah dana dari mana?",
                style: TextStyle(
                  fontFamily: 'AlumniSans',
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),

              _buildTambahDanaOption(
                iconWidget: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCCCCFF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/images/IKEHome.png',
                    height: 24,
                    fit: BoxFit.contain,
                  ),
                ),
                title: "Dari Saku kamu",
                subtitle: "Pindahkan dari Saku lain",
                onTap: () async {
                  Navigator.pop(sheetContext);

                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TambahDanaSakuScreen(),
                    ),
                  );
                  await _refreshIfChanged(result);
                },
              ),

              const SizedBox(height: 16),

              _buildTambahDanaOption(
                iconWidget: SvgPicture.asset(
                  'assets/images/bank2.svg',
                  width: 36,
                ),
                title: "Dari luar IKE Bank",
                subtitle: "Kirim dana dari bank atau aplikasi lain",
                onTap: () async {
                  Navigator.pop(sheetContext);

                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TambahDanaScreen(),
                    ),
                  );
                  await _refreshIfChanged(result);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTambahDanaOption({
    required Widget iconWidget,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8F0),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFDBB7), width: 1.5),
        ),
        child: Row(
          children: [
            iconWidget,
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPindahkanKeBottomSheet(BuildContext context) {
    if (_destinationSakus.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada saku tujuan yang tersedia')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
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
                "Pindahkan ke",
                style: TextStyle(
                  fontFamily: 'AlumniSans',
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              ..._destinationSakus.map((saku) {
                final destinationId = _readString(saku, const [
                  'id',
                  'saku_id',
                ]);
                final destinationName = _readString(saku, const [
                  'saku_name',
                  'name',
                ]);
                final destinationBalance = _formatRupiah(
                  _readString(saku, const ['balance']),
                );
                final isPrimary =
                    _readBool(saku, 'is_primary') ||
                    destinationName.toLowerCase().contains('utama');
                final categoryLabel = _buildSakuCategoryLabel(saku);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.pop(sheetContext);
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PindahDanaScreen(
                            initialSourceSakuId: _currentSakuId,
                            initialSourceSakuName: _sakuTitle,
                            initialSourceSakuBalance: _sakuAmount,
                            initialDestinationSakuId: destinationId,
                            initialDestinationSakuName: destinationName,
                            initialDestinationSakuBalance: destinationBalance,
                          ),
                        ),
                      );
                      await _refreshIfChanged(result);
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
                                child: SvgPicture.asset(
                                  'assets/images/bag.svg',
                                  height: 36,
                                  colorFilter: const ColorFilter.mode(
                                    Color(0xFFFF7F00),
                                    BlendMode.srcIn,
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
                                  if (categoryLabel.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      categoryLabel,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (isPrimary)
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
                              child: const Text(
                                "Utama",
                                style: TextStyle(
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

  void _showFilterBottomSheet(BuildContext context) {
    showFilterBottomSheet(context, initialFilter: _activeFilter).then((value) {
      if (value == null || !mounted) {
        return;
      }

      setState(() {
        _activeFilter = value;
      });

      if (_currentSakuId.isNotEmpty) {
        _loadTransactionHistory(_currentSakuId);
      }
    });
  }
}
