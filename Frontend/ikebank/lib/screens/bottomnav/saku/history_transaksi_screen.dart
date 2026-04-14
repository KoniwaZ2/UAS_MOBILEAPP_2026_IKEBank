import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../api/banking.dart';
import '../../../widgets/filter_bottom_sheet.dart';
import '../../home/saku_utama/pindah_dana_screen.dart';
import '../../home/saku_utama/riwayat_transaksi_screen.dart';

class HistoryTransaksiScreen extends StatefulWidget {
  final String title;
  final String amount;
  final String imageAsset;
  final String? sakuId;
  final String? categoryName;

  const HistoryTransaksiScreen({
    super.key,
    required this.title,
    required this.amount,
    required this.imageAsset,
    this.sakuId,
    this.categoryName,
  });

  @override
  State<HistoryTransaksiScreen> createState() => _HistoryTransaksiScreenState();
}

class _HistoryTransaksiScreenState extends State<HistoryTransaksiScreen> {
  String _sakuTitle = 'Saku';
  String _currentAmount = 'Rp 0';
  String _sakuImageAsset = 'assets/images/tabung.png';
  bool _isSvg = false;

  String _accountNumber = '-';
  String _currentSakuId = '';
  String _categoryLabel = 'Nabung';
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoadingTransactions = false;
  bool _isLoading = true;
  bool _shouldReturnRefresh = false;
  TransactionFilter _activeFilter = const TransactionFilter.noFilter();

  @override
  void initState() {
    super.initState();
    _sakuTitle = widget.title;
    _currentAmount = widget.amount;
    _sakuImageAsset = widget.imageAsset;
    _isSvg = widget.imageAsset.toLowerCase().endsWith('.svg');
    _categoryLabel = _formatCategoryLabel(widget.categoryName ?? 'nabung');
    _loadSakuData();
  }

  Future<void> _openAndTrack(Widget page) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
    if (result == true && mounted) {
      _shouldReturnRefresh = true;
      await _loadSakuData();
    }
  }

  Future<void> _loadSakuData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final accountDetails = await BankingService.fetchAccountDetails();
      final accountNumber = accountDetails.isNotEmpty
          ? accountDetails.first.accountnumber
          : '-';

      final rawSakuList = await BankingService.sakuList();
      final dynamic payload = rawSakuList is Map<String, dynamic>
          ? (rawSakuList['data'] ??
                rawSakuList['results'] ??
                rawSakuList['sakus'] ??
                rawSakuList)
          : rawSakuList;

      if (payload is! List) {
        if (!mounted) return;
        setState(() {
          _accountNumber = accountNumber;
          _isLoading = false;
        });
        return;
      }

      final sakus = payload.whereType<Map<String, dynamic>>().toList();
      Map<String, dynamic>? selectedSaku;

      final requestedId = widget.sakuId?.trim() ?? '';
      if (requestedId.isNotEmpty) {
        selectedSaku = sakus
            .where(
              (s) => _readString(s, const ['id', 'saku_id']) == requestedId,
            )
            .cast<Map<String, dynamic>?>()
            .firstWhere((_) => true, orElse: () => null);
      }

      selectedSaku ??= sakus
          .where(
            (s) =>
                _readString(s, const ['saku_name', 'name']).toLowerCase() ==
                widget.title.trim().toLowerCase(),
          )
          .cast<Map<String, dynamic>?>()
          .firstWhere((_) => true, orElse: () => null);

      selectedSaku ??= sakus.isNotEmpty ? sakus.first : null;
      if (selectedSaku == null) {
        if (!mounted) return;
        setState(() {
          _accountNumber = accountNumber;
          _isLoading = false;
        });
        return;
      }

      var mergedSaku = selectedSaku;
      final sakuId = _readString(mergedSaku, const ['id', 'saku_id']);
      if (sakuId.isNotEmpty) {
        try {
          final detail = await BankingService.sakuDetail(sakuId: sakuId);
          mergedSaku = {...mergedSaku, ...detail};
        } catch (_) {
          // Keep list payload as fallback if detail endpoint fails.
        }
      }

      if (!mounted) return;

      final name = _readString(mergedSaku, const ['saku_name', 'name']);
      final balance = _readString(mergedSaku, const ['balance']);
      final category = _readString(mergedSaku, const [
        'category_name',
        'category',
      ]);

      setState(() {
        _accountNumber = accountNumber.trim().isEmpty ? '-' : accountNumber;
        _currentSakuId = sakuId;
        _sakuTitle = name.isEmpty ? widget.title : name;
        _currentAmount = balance.isEmpty
            ? widget.amount
            : _formatRupiah(balance);
        _categoryLabel = _formatCategoryLabel(
          category.isEmpty ? (widget.categoryName ?? 'nabung') : category,
        );
        _sakuImageAsset = _resolveSakuImage(
          name: _sakuTitle,
          category: category,
          fallbackAsset: widget.imageAsset,
        );
        _isSvg = _sakuImageAsset.toLowerCase().endsWith('.svg');
        _isLoading = false;
      });

      if (sakuId.isNotEmpty) {
        _loadTransactionHistory(sakuId);
      } else {
        setState(() {
          _transactions = [];
          _isLoadingTransactions = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
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
      final transactionsById = await BankingService.transactionHistory(
        sakuId: sakuId,
      );

      var transactions = transactionsById;
      if (transactions.isEmpty && _sakuTitle.trim().isNotEmpty) {
        // Fallback when backend does not accept incoming saku_id format.
        transactions = await BankingService.transactionHistory(
          sakuName: _sakuTitle.trim(),
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _transactions = _applyTransactionFilter(transactions);
        _isLoadingTransactions = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingTransactions = false;
      });
    }
  }

  void _showInfoSakuBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
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
              Text(
                _sakuTitle,
                style: const TextStyle(
                  fontFamily: 'AlumniSans',
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(16),
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
                            child: _isSvg
                                ? SvgPicture.asset(
                                    _sakuImageAsset,
                                    height: 30,
                                    fit: BoxFit.contain,
                                  )
                                : Image.asset(
                                    _sakuImageAsset,
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
                                  _currentAmount,
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
                    Divider(
                      height: 1,
                      color: Colors.grey.shade300,
                      thickness: 1,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Kategori $_categoryLabel',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
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

  String _resolveSakuImage({
    required String name,
    required String category,
    required String fallbackAsset,
  }) {
    final normalizedName = name.toLowerCase();
    final normalizedCategory = category.toLowerCase();

    if (normalizedName.contains('utama') ||
        normalizedCategory.contains('utama')) {
      return 'assets/images/IKEHome.png';
    }
    if (normalizedName.contains('deposito') ||
        normalizedCategory.contains('deposito')) {
      return 'assets/images/deposito.png';
    }
    if (normalizedName.contains('celengan') ||
        normalizedCategory.contains('nabung')) {
      return 'assets/images/tabung.png';
    }

    return fallbackAsset;
  }

  String _formatCategoryLabel(String rawCategory) {
    final normalized = rawCategory.replaceAll('_', ' ').trim();
    if (normalized.isEmpty) {
      return 'Nabung';
    }

    return normalized
        .split(RegExp(r'\\s+'))
        .where((word) => word.isNotEmpty)
        .map(
          (word) =>
              '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
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
        final currentSakuInfo = _sakuTitle;
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
          icon: isIncome ? Icons.add : Icons.arrow_forward,
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
    return null;
  }

  bool _isTransactionIncome(Map<String, dynamic> transaction) {
    final category = _readString(transaction, const [
      'category',
      'category_name',
    ]).toLowerCase();

    if (category.contains('income') ||
        category.contains('deposit') ||
        category.contains('transfer_in') ||
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

  Future<void> _openReceiveFlow() async {
    if (_currentSakuId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saku belum siap. Coba lagi.')),
      );
      return;
    }

    await _openAndTrack(
      PindahDanaScreen(
        initialDestinationSakuId: _currentSakuId,
        initialDestinationSakuName: _sakuTitle,
        initialDestinationSakuBalance: _currentAmount,
      ),
    );
  }

  Future<void> _openSendFlow() async {
    if (_currentSakuId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saku belum siap. Coba lagi.')),
      );
      return;
    }

    await _openAndTrack(
      PindahDanaScreen(
        initialSourceSakuId: _currentSakuId,
        initialSourceSakuName: _sakuTitle,
        initialSourceSakuBalance: _currentAmount,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            onPressed: () => Navigator.pop(context, _shouldReturnRefresh),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_horiz, color: Colors.black, size: 28),
              onPressed: () => _showInfoSakuBottomSheet(context),
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
                const SizedBox(height: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Nomor rekening  ',
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
                            content: Text('Nomor rekening disalin!'),
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
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF7F00)),
                ),
              )
            : SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
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
                                  'Dana tersedia',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _currentAmount,
                                  style: const TextStyle(
                                    fontFamily: 'AlumniSans',
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFFF7F00),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Kategori: $_categoryLabel',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildActionButton(
                                      icon: Icons.add,
                                      label: 'Tambah dana',
                                      onTap: _openReceiveFlow,
                                    ),
                                    _buildActionButton(
                                      svgPath: 'assets/images/pindah.svg',
                                      label: 'Pindah dana',
                                      onTap: _openSendFlow,
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
                              child: _isSvg
                                  ? SvgPicture.asset(
                                      _sakuImageAsset,
                                      height: 50,
                                      fit: BoxFit.contain,
                                    )
                                  : Image.asset(
                                      _sakuImageAsset,
                                      height: 50,
                                      fit: BoxFit.contain,
                                      errorBuilder: (c, e, s) => const Icon(
                                        Icons.image,
                                        color: Colors.grey,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
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
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: const TextField(
                                      decoration: InputDecoration(
                                        hintText: 'Cari transaksi',
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

                            Expanded(
                              child: _isLoadingTransactions
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
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
                                      children:
                                          _buildGroupedTransactionWidgets(),
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
                    height: 42,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  )
                : Icon(icon, color: Colors.white, size: 26),
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
    IconData? icon,
    String? imagePath,
    required String title,
    required String subtitle,
    required String amount,
    required String time,
    required bool isIncome,
    VoidCallback? onTap,
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
