import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import '../../../api/banking.dart';

class _LifecycleObserver extends WidgetsBindingObserver {
  final Function() onResume;
  _LifecycleObserver({required this.onResume});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onResume();
    }
  }
}

class PindahDanaCelenganScreen extends StatefulWidget {
  final String destName;
  final String destBalance;
  final String destIconPath;
  final bool isSvg;
  final String? destId;

  const PindahDanaCelenganScreen({
    super.key,
    required this.destName,
    required this.destBalance,
    required this.destIconPath,
    this.isSvg = false,
    this.destId,
  });

  @override
  State<PindahDanaCelenganScreen> createState() =>
      _PindahDanaCelenganScreenState();
}

class _PindahDanaCelenganScreenState extends State<PindahDanaCelenganScreen> {
  final TextEditingController _amountController = TextEditingController();

  String _selectedTujuan = '-';
  String _selectedTujuanSaldo = 'Rp 0';
  String _selectedTujuanId = '';
  String _selectedIconPath = 'assets/images/bag.svg';
  bool _isSvg = true;

  String _sourceSakuName = '-';
  String _sourceSakuSaldo = 'Rp 0';
  String _sourceSakuId = '';

  List<Map<String, dynamic>> _allSakus = [];
  List<Map<String, dynamic>> _sourceSakus = [];
  List<Map<String, dynamic>> _destinationSakus = [];

  bool _isSubmitting = false;
  bool _isLoadingData = true;
  late _LifecycleObserver _lifecycleObserver;

  @override
  void initState() {
    super.initState();

    _selectedTujuan = widget.destName;
    _selectedTujuanSaldo = _formatRupiah(widget.destBalance);
    _selectedTujuanId = widget.destId?.trim() ?? '';
    _selectedIconPath = widget.destIconPath;
    _isSvg = widget.isSvg;

    _lifecycleObserver = _LifecycleObserver(onResume: () {
      if (mounted) {
        setState(() => _isLoadingData = true);
        _loadSakuData();
      }
    });
    WidgetsBinding.instance.addObserver(_lifecycleObserver);

    _loadSakuData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    _amountController.dispose();
    super.dispose();
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

  String _extractAmountDigits(String formattedText) {
    return formattedText.replaceAll(RegExp(r'[^0-9]'), '');
  }

  bool _isDepositoSaku(Map<String, dynamic> saku) {
    final name = _readString(saku, const ['saku_name', 'name']).toLowerCase();
    final category = _readString(saku, const ['category_name', 'category'])
        .toLowerCase();
    return name.contains('deposito') || category.contains('deposito');
  }

  bool _isBlockedSourceCategory(Map<String, dynamic> saku) {
    final name = _readString(saku, const ['saku_name', 'name']).toLowerCase();
    final category = _readString(saku, const ['category_name', 'category'])
        .toLowerCase();
    return name.contains('nabung') ||
        category.contains('nabung') ||
        name.contains('deposito') ||
        category.contains('deposito');
  }

  String _resolveSakuIcon(Map<String, dynamic> saku) {
    final name = _readString(saku, const ['saku_name', 'name']).toLowerCase();
    final category = _readString(saku, const ['category_name', 'category'])
        .toLowerCase();

    if (_readBool(saku, 'is_primary') || name.contains('utama')) {
      return 'assets/images/IKEHome.png';
    }
    if (category.contains('celengan') || name.contains('celengan')) {
      return 'assets/images/celengan.png';
    }
    if (category.contains('deposito') || name.contains('deposito')) {
      return 'assets/images/deposito.png';
    }
    return 'assets/images/bag.svg';
  }

  List<Map<String, dynamic>> _buildSourceSakus(String destinationId) {
    return _allSakus.where((saku) {
      final id = _readString(saku, const ['id', 'saku_id']);
      final isSameAsDestination =
          destinationId.trim().isNotEmpty && id == destinationId;
      return !_isBlockedSourceCategory(saku) && !isSameAsDestination;
    }).toList();
  }

  List<Map<String, dynamic>> _buildDestinationSakus(String sourceId) {
    return _allSakus.where((saku) {
      final id = _readString(saku, const ['id', 'saku_id']);
      final isSameAsSource = sourceId.trim().isNotEmpty && id == sourceId;
      return !_isDepositoSaku(saku) && !isSameAsSource;
    }).toList();
  }

  Future<void> _loadSakuData() async {
    try {
      if (!mounted) return;

      final rawSakuList = await BankingService.sakuList();
      final dynamic payload = rawSakuList is Map<String, dynamic>
          ? (rawSakuList['data'] ??
                rawSakuList['results'] ??
                rawSakuList['sakus'] ??
                rawSakuList)
          : rawSakuList;

      if (payload is! List) {
        if (mounted) setState(() => _isLoadingData = false);
        return;
      }

      final sakus = payload.whereType<Map<String, dynamic>>().toList();
      if (sakus.isEmpty) {
        if (mounted) setState(() => _isLoadingData = false);
        return;
      }

      _allSakus = sakus;

      Map<String, dynamic>? selectedDestination;
      if (_selectedTujuanId.isNotEmpty) {
        selectedDestination = sakus
            .where(
              (s) => _readString(s, const ['id', 'saku_id']) == _selectedTujuanId,
            )
            .cast<Map<String, dynamic>?>()
            .firstWhere((_) => true, orElse: () => null);
      }

      selectedDestination ??= sakus
          .where(
            (s) => _readString(s, const ['saku_name', 'name']).toLowerCase() ==
                _selectedTujuan.toLowerCase(),
          )
          .cast<Map<String, dynamic>?>()
          .firstWhere((_) => true, orElse: () => null);

      selectedDestination ??= sakus
          .where((s) => !_isDepositoSaku(s))
          .cast<Map<String, dynamic>?>()
          .firstWhere((_) => true, orElse: () => null);

      selectedDestination ??= sakus.first;

      _selectedTujuanId = _readString(selectedDestination, const ['id', 'saku_id']);

      final sourceCandidates = _buildSourceSakus(_selectedTujuanId);
      if (sourceCandidates.isEmpty) {
        if (!mounted) {
          return;
        }

        setState(() {
          _destinationSakus = _buildDestinationSakus('');
          _isLoadingData = false;
        });
        return;
      }

      Map<String, dynamic>? selectedSource;
      if (_sourceSakuId.isNotEmpty) {
        selectedSource = sourceCandidates
            .where(
              (s) => _readString(s, const ['id', 'saku_id']) == _sourceSakuId,
            )
            .cast<Map<String, dynamic>?>()
            .firstWhere((_) => true, orElse: () => null);
      }

      selectedSource ??= sourceCandidates
          .where((s) => _readBool(s, 'is_primary'))
          .cast<Map<String, dynamic>?>()
          .firstWhere((_) => true, orElse: () => null);

      selectedSource ??= sourceCandidates.first;

      final selectedSourceId = _readString(selectedSource, const ['id', 'saku_id']);
      final destinationCandidates = _buildDestinationSakus(selectedSourceId);

      if (destinationCandidates.isNotEmpty &&
          !destinationCandidates.any(
            (s) => _readString(s, const ['id', 'saku_id']) == _selectedTujuanId,
          )) {
        selectedDestination = destinationCandidates.first;
        _selectedTujuanId = _readString(selectedDestination, const ['id', 'saku_id']);
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _sourceSakuId = selectedSourceId;
        _sourceSakuName = _readString(selectedSource!, const ['saku_name', 'name']);
        _sourceSakuSaldo = _formatRupiah(_readString(selectedSource, const ['balance']));

        final destination = selectedDestination!;
        _selectedTujuanId = _readString(destination, const ['id', 'saku_id']);
        _selectedTujuan = _readString(destination, const ['saku_name', 'name']);
        _selectedTujuanSaldo = _formatRupiah(_readString(destination, const ['balance']));
        _selectedIconPath = _resolveSakuIcon(destination);
        _isSvg = _selectedIconPath.toLowerCase().endsWith('.svg');

        _sourceSakus = sourceCandidates;
        _destinationSakus = destinationCandidates;
        _isLoadingData = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingData = false);
      }
    }
  }

  Future<void> _submitInternalTransfer() async {
    final amountDigits = _extractAmountDigits(_amountController.text);
    if (amountDigits.isEmpty ||
        int.tryParse(amountDigits) == null ||
        int.parse(amountDigits) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal transfer harus lebih dari 0')),
      );
      return;
    }

    if (_sourceSakuId.isEmpty || _selectedTujuanId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sumber atau tujuan saku belum valid')),
      );
      return;
    }

    if (_sourceSakuId == _selectedTujuanId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sumber dan tujuan saku tidak boleh sama')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await BankingService.internalTransfer(
        sourceSakuId: _sourceSakuId,
        destinationSakuId: _selectedTujuanId,
        amount: amountDigits,
        description: 'Pindah dana dari $_sourceSakuName ke $_selectedTujuan',
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Pindah Dana',
          style: TextStyle(
            fontFamily: 'AlumniSans',
            fontWeight: FontWeight.w800,
            fontSize: 28,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Pindahkan ke',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 45,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: _isSvg
                                                ? const Color(0xFFD6CFFF)
                                                : const Color(0xFFD6E4FF),
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                  bottom: Radius.circular(25),
                                                ),
                                          ),
                                          alignment: Alignment.center,
                                          child: _isSvg
                                              ? SvgPicture.asset(
                                                  _selectedIconPath,
                                                  height: 24,
                                                  colorFilter:
                                                      const ColorFilter.mode(
                                                        Color(0xFFFF7F00),
                                                        BlendMode.srcIn,
                                                      ),
                                                )
                                              : Image.asset(
                                                  _selectedIconPath,
                                                  height: 24,
                                                  fit: BoxFit.contain,
                                                  errorBuilder: (c, e, s) =>
                                                      const Icon(
                                                        Icons.account_balance,
                                                        color: Colors.blue,
                                                      ),
                                                ),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _selectedTujuan,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              _isLoadingData ? 'Memuat...' : _selectedTujuanSaldo,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: _isLoadingData ? Colors.grey : Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        _showPilihTujuanBottomSheet(context);
                                      },
                                      child: const Text(
                                        'Ganti',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFFF7F00),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Divider(height: 0.1, color: Colors.grey.shade200),
                          Container(
                            width: double.infinity,
                            color: const Color(0x1AFFCA96),
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Jumlah',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Rp ',
                                      style: TextStyle(
                                        fontFamily: 'AlumniSans',
                                        fontSize: 32,
                                        fontWeight: FontWeight.w900,
                                        color: _amountController.text.isEmpty
                                            ? Colors.grey.shade400
                                            : const Color(0xFFFF7F00),
                                      ),
                                    ),
                                    Expanded(
                                      child: TextField(
                                        controller: _amountController,
                                        keyboardType: TextInputType.number,
                                        style: const TextStyle(
                                          fontFamily: 'AlumniSans',
                                          fontSize: 32,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFFFF7F00),
                                        ),
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                          hintText: '100.000',
                                          hintStyle: TextStyle(
                                            fontFamily: 'AlumniSans',
                                            fontSize: 32,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                          _CurrencyInputFormatter(
                                            maxAmount: 50000000,
                                          ),
                                        ],
                                        onChanged: (value) {
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Dari',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  _showPilihSumberBottomSheet(context);
                                },
                                child: const Text(
                                  'Ganti',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFF7F00),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isLoadingData ? 'Memuat...' : _sourceSakuName,
                            style: TextStyle(
                              fontSize: 16,
                              color: _isLoadingData ? Colors.grey : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _isLoadingData ? 'Memuat...' : _sourceSakuSaldo,
                            style: TextStyle(
                              fontSize: 14,
                              color: _isLoadingData ? Colors.grey : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: const BoxDecoration(color: Colors.transparent),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: (_isSubmitting || _isLoadingData) ? null : _submitInternalTransfer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7F00),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isLoadingData ? 'Memuat...' : (_isSubmitting ? 'Memindahkan...' : 'Pindah Dana'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Rp ${_amountController.text.isEmpty ? '0' : _amountController.text}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPilihTujuanBottomSheet(BuildContext context) {
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
      builder: (context) {
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
              ..._destinationSakus.map((saku) {
                final destinationId = _readString(saku, const ['id', 'saku_id']);
                final destinationName = _readString(saku, const ['saku_name', 'name']);
                final destinationBalance = _formatRupiah(
                  _readString(saku, const ['balance']),
                );
                final rawCategory = _readString(saku, const [
                  'category_name',
                  'category',
                ]);
                final categoryLabel = _formatCategoryLabel(rawCategory);
                final iconPath = _resolveSakuIcon(saku);
                final isSvgIcon = iconPath.toLowerCase().endsWith('.svg');

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () {
                      final nextSourceSakus = _buildSourceSakus(destinationId);
                      if (nextSourceSakus.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tidak ada saku sumber untuk tujuan ini'),
                          ),
                        );
                        return;
                      }

                      String nextSourceId = _sourceSakuId;
                      String nextSourceName = _sourceSakuName;
                      String nextSourceSaldo = _sourceSakuSaldo;

                      if (!nextSourceSakus.any(
                        (source) =>
                            _readString(source, const ['id', 'saku_id']) ==
                            _sourceSakuId,
                      )) {
                        final fallbackSource = nextSourceSakus.first;
                        nextSourceId = _readString(
                          fallbackSource,
                          const ['id', 'saku_id'],
                        );
                        nextSourceName = _readString(
                          fallbackSource,
                          const ['saku_name', 'name'],
                        );
                        nextSourceSaldo = _formatRupiah(
                          _readString(fallbackSource, const ['balance']),
                        );
                      }

                      setState(() {
                        _selectedTujuanId = destinationId;
                        _selectedTujuan = destinationName;
                        _selectedTujuanSaldo = destinationBalance;
                        _selectedIconPath = iconPath;
                        _isSvg = isSvgIcon;

                        _sourceSakus = nextSourceSakus;
                        _sourceSakuId = nextSourceId;
                        _sourceSakuName = nextSourceName;
                        _sourceSakuSaldo = nextSourceSaldo;
                      });

                      Navigator.pop(context);
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
                                child: isSvgIcon
                                    ? SvgPicture.asset(
                                        iconPath,
                                        height: 24,
                                        colorFilter: const ColorFilter.mode(
                                          Color(0xFFFF7F00),
                                          BlendMode.srcIn,
                                        ),
                                      )
                                    : Image.asset(
                                        iconPath,
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
                                      fontSize: 14,
                                      color: Colors.black87,
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

  void _showPilihSumberBottomSheet(BuildContext context) {
    if (_sourceSakus.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada saku sumber yang tersedia')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
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
                'Dari',
                style: TextStyle(
                  fontFamily: 'AlumniSans',
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              ..._sourceSakus.map((saku) {
                final sourceId = _readString(saku, const ['id', 'saku_id']);
                final sourceName = _readString(saku, const ['saku_name', 'name']);
                final sourceBalance = _formatRupiah(
                  _readString(saku, const ['balance']),
                );

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () {
                      final nextDestinationSakus = _buildDestinationSakus(sourceId);
                      if (nextDestinationSakus.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tidak ada saku tujuan untuk sumber ini'),
                          ),
                        );
                        return;
                      }

                      String nextDestinationId = _selectedTujuanId;
                      String nextDestinationName = _selectedTujuan;
                      String nextDestinationSaldo = _selectedTujuanSaldo;
                      String nextDestinationIconPath = _selectedIconPath;

                      if (!nextDestinationSakus.any(
                        (destination) =>
                            _readString(destination, const ['id', 'saku_id']) ==
                            _selectedTujuanId,
                      )) {
                        final fallbackDestination = nextDestinationSakus.first;
                        nextDestinationId = _readString(
                          fallbackDestination,
                          const ['id', 'saku_id'],
                        );
                        nextDestinationName = _readString(
                          fallbackDestination,
                          const ['saku_name', 'name'],
                        );
                        nextDestinationSaldo = _formatRupiah(
                          _readString(fallbackDestination, const ['balance']),
                        );
                        nextDestinationIconPath = _resolveSakuIcon(
                          fallbackDestination,
                        );
                      }

                      setState(() {
                        _sourceSakuId = sourceId;
                        _sourceSakuName = sourceName;
                        _sourceSakuSaldo = sourceBalance;

                        _destinationSakus = nextDestinationSakus;
                        _selectedTujuanId = nextDestinationId;
                        _selectedTujuan = nextDestinationName;
                        _selectedTujuanSaldo = nextDestinationSaldo;
                        _selectedIconPath = nextDestinationIconPath;
                        _isSvg =
                            nextDestinationIconPath.toLowerCase().endsWith('.svg');
                      });

                      Navigator.pop(context);
                    },
                    child: Container(
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sourceName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            sourceBalance,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
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
}

class _CurrencyInputFormatter extends TextInputFormatter {
  final int maxAmount;
  _CurrencyInputFormatter({required this.maxAmount});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    String cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanText.isEmpty) return newValue.copyWith(text: '');
    int value = int.parse(cleanText);
    if (value > maxAmount) {
      value = maxAmount;
      cleanText = maxAmount.toString();
    }
    String formatted = '';
    int count = 0;
    for (int i = cleanText.length - 1; i >= 0; i--) {
      if (count == 3) {
        formatted = '.$formatted';
        count = 0;
      }
      formatted = cleanText[i] + formatted;
      count++;
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
