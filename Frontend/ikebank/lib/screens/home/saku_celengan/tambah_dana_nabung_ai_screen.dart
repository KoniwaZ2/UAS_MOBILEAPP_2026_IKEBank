import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import '../../../api/banking.dart';

class TambahDanaNabungAiScreen extends StatefulWidget {
  final String? amount;
  const TambahDanaNabungAiScreen({super.key, this.amount});

  @override
  State<TambahDanaNabungAiScreen> createState() =>
      _TambahDanaNabungAiScreenState();
}

class _TambahDanaNabungAiScreenState extends State<TambahDanaNabungAiScreen> {
  final TextEditingController _amountController = TextEditingController(
    text: "",
  );

  String _targetSakuId = "";
  String _targetSakuName = "Saku Celengan";
  String _targetSakuSaldo = "Rp 0";
  String _targetIconPath = 'assets/images/celengan.png';
  bool _isTargetSvg = false;

  String _selectedSumberId = "";
  String _selectedSumber = "-";
  String _selectedSumberSaldo = "Rp 0";

  List<Map<String, dynamic>> _sourceSakus = [];
  bool _isLoadingData = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _setInitialAmount();
    _loadSakuData();
  }

  void _setInitialAmount() {
    final raw = widget.amount?.trim() ?? '';
    if (raw.isEmpty) {
      return;
    }

    final digitsOnly = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) {
      return;
    }

    final parsed = int.tryParse(digitsOnly) ?? 0;
    if (parsed <= 0) {
      return;
    }

    final capped = parsed > 500000 ? 500000 : parsed;
    _amountController.text = _formatRupiah(capped.toString()).replaceFirst('Rp ', '');
    _amountController.selection = TextSelection.collapsed(
      offset: _amountController.text.length,
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

  bool _readBool(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is bool) return value;
    if (value is num) return value != 0;
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

  String _extractAmountDigits(String formattedText) {
    return formattedText.replaceAll(RegExp(r'[^0-9]'), '');
  }

  bool _isBlockedSourceCategory(Map<String, dynamic> saku) {
    final name = _readString(saku, const ['saku_name', 'name']).toLowerCase();
    final category = _readString(saku, const [
      'category_name',
      'category',
    ]).toLowerCase();
    return name.contains('nabung') ||
        category.contains('nabung') ||
        name.contains('deposito') ||
        category.contains('deposito');
  }

  String _resolveSakuIcon(Map<String, dynamic> saku) {
    final name = _readString(saku, const ['saku_name', 'name']).toLowerCase();
    final category = _readString(saku, const [
      'category_name',
      'category',
    ]).toLowerCase();

    if (_readBool(saku, 'is_primary') || name.contains('utama')) {
      return 'assets/images/IKEHome.png';
    }
    if (category.contains('celengan') || name.contains('celengan')) {
      return 'assets/images/celengan.png';
    }
    return 'assets/images/bag.svg';
  }

  Future<void> _loadSakuData() async {
    try {
      if (!mounted) return;

      setState(() {
        _isLoadingData = true;
      });

      final rawSakuList = await BankingService.sakuList();
      final dynamic payload = rawSakuList is Map<String, dynamic>
          ? (rawSakuList['data'] ??
                rawSakuList['results'] ??
                rawSakuList['sakus'] ??
                rawSakuList)
          : rawSakuList;

      if (payload is! List) {
        if (mounted) {
          setState(() {
            _isLoadingData = false;
          });
        }
        return;
      }

      final sakus = payload.whereType<Map<String, dynamic>>().toList();
      if (sakus.isEmpty) {
        if (mounted) {
          setState(() {
            _isLoadingData = false;
          });
        }
        return;
      }

      Map<String, dynamic>? target = sakus
          .where((s) {
            final name = _readString(s, const [
              'saku_name',
              'name',
            ]).toLowerCase();
            final category = _readString(s, const [
              'category_name',
              'category',
            ]).toLowerCase();
            return name.contains('celengan') || category.contains('celengan');
          })
          .cast<Map<String, dynamic>?>()
          .firstWhere((_) => true, orElse: () => null);

      target ??= sakus.first;
      final targetId = _readString(target, const ['id', 'saku_id']);

      final sourceCandidates = sakus.where((saku) {
        final id = _readString(saku, const ['id', 'saku_id']);
        return id != targetId && !_isBlockedSourceCategory(saku);
      }).toList();

      Map<String, dynamic>? selectedSource;
      if (_selectedSumberId.isNotEmpty) {
        selectedSource = sourceCandidates
            .where(
              (s) =>
                  _readString(s, const ['id', 'saku_id']) == _selectedSumberId,
            )
            .cast<Map<String, dynamic>?>()
            .firstWhere((_) => true, orElse: () => null);
      }

      selectedSource ??= sourceCandidates
          .where((s) => _readBool(s, 'is_primary'))
          .cast<Map<String, dynamic>?>()
          .firstWhere((_) => true, orElse: () => null);

      selectedSource ??= sourceCandidates.isNotEmpty
          ? sourceCandidates.first
          : null;

      if (!mounted) return;

      setState(() {
        _targetSakuId = targetId;
        _targetSakuName = _readString(target!, const ['saku_name', 'name']);
        _targetSakuSaldo = _formatRupiah(
          _readString(target, const ['balance']),
        );
        _targetIconPath = _resolveSakuIcon(target);
        _isTargetSvg = _targetIconPath.toLowerCase().endsWith('.svg');

        _sourceSakus = sourceCandidates;

        if (selectedSource != null) {
          _selectedSumberId = _readString(selectedSource, const [
            'id',
            'saku_id',
          ]);
          _selectedSumber = _readString(selectedSource, const [
            'saku_name',
            'name',
          ]);
          _selectedSumberSaldo = _formatRupiah(
            _readString(selectedSource, const ['balance']),
          );
        } else {
          _selectedSumberId = '';
          _selectedSumber = '-';
          _selectedSumberSaldo = 'Rp 0';
        }

        _isLoadingData = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
      }
    }
  }

  Future<void> _submitTambahDana() async {
    final amountDigits = _extractAmountDigits(_amountController.text);
    final parsedAmount = int.tryParse(amountDigits) ?? 0;

    if (parsedAmount < 1) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nominal minimal Rp 1')));
      return;
    }

    if (parsedAmount > 500000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal maksimal Rp 500.000')),
      );
      return;
    }

    if (_selectedSumberId.isEmpty || _targetSakuId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sumber atau tujuan saku belum valid')),
      );
      return;
    }

    if (_selectedSumberId == _targetSakuId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sumber dan tujuan saku tidak boleh sama'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await BankingService.internalTransfer(
        sourceSakuId: _selectedSumberId,
        destinationSakuId: _targetSakuId,
        amount: amountDigits,
        description: 'Tambah dana dari $_selectedSumber ke $_targetSakuName',
      );

      await _loadSakuData();

      if (!mounted) return;

      final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
      Navigator.pop(context, true);
      scaffoldMessenger?.showSnackBar(
        SnackBar(
          content: Text('Dana berhasil ditambahkan ke $_targetSakuName!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
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
  void dispose() {
    _amountController.dispose();
    super.dispose();
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
          "Tambah Dana",
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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                  "Tambahkan ke",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Container(
                                      width: 45,
                                      height: 50,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFD6CFFF),
                                        borderRadius: BorderRadius.vertical(
                                          bottom: Radius.circular(25),
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: _isTargetSvg
                                          ? SvgPicture.asset(
                                              _targetIconPath,
                                              height: 24,
                                              colorFilter:
                                                  const ColorFilter.mode(
                                                    Color(0xFFFF7F00),
                                                    BlendMode.srcIn,
                                                  ),
                                            )
                                          : Image.asset(
                                              _targetIconPath,
                                              height: 28,
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
                                          _targetSakuName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _isLoadingData
                                              ? 'Memuat...'
                                              : _targetSakuSaldo,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: _isLoadingData
                                                ? Colors.grey
                                                : Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          Divider(height: 0.1, color: Colors.grey.shade200),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16.0),
                            decoration: const BoxDecoration(
                              color: Color(0x1AFFCA96),
                              borderRadius: BorderRadius.all(
                                Radius.circular(16),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Jumlah",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Rp ",
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
                                          hintText: "500.000",
                                          hintStyle: TextStyle(
                                            fontFamily: 'AlumniSans',
                                            fontSize: 32,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                          _CurrencyInputFormatter(
                                            maxAmount: 500000,
                                          ), // Maksimal 500.000
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

                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                        child: Text(
                          "*Minimal Rp 1, Maksimal Rp 500.000",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                          ),
                        ),
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Dari",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isLoadingData ? 'Memuat...' : _selectedSumber,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _isLoadingData
                                      ? Colors.grey
                                      : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _isLoadingData
                                    ? 'Memuat...'
                                    : _selectedSumberSaldo,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _isLoadingData
                                      ? Colors.grey
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              _showPilihSumberBottomSheet(context);
                            },
                            child: const Text(
                              "Ganti",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF7F00),
                              ),
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
                  onPressed: (_isLoadingData || _isSubmitting)
                      ? null
                      : _submitTambahDana,
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
                        _isLoadingData
                            ? 'Memuat...'
                            : (_isSubmitting ? 'Memproses...' : 'Tambah Dana'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Rp ${_amountController.text.isEmpty ? '0' : _amountController.text}",
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
                "Pilih sumber dana",
                style: TextStyle(
                  fontFamily: 'AlumniSans',
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),

              ..._sourceSakus.asMap().entries.map((entry) {
                final index = entry.key;
                final saku = entry.value;
                final sourceId = _readString(saku, const ['id', 'saku_id']);
                final sourceName = _readString(saku, const [
                  'saku_name',
                  'name',
                ]);
                final sourceBalance = _formatRupiah(
                  _readString(saku, const ['balance']),
                );
                final iconPath = _resolveSakuIcon(saku);
                final isSvg = iconPath.toLowerCase().endsWith('.svg');

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == _sourceSakus.length - 1 ? 0 : 12,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedSumberId = sourceId;
                        _selectedSumber = sourceName;
                        _selectedSumberSaldo = sourceBalance;
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
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 55,
                            decoration: BoxDecoration(
                              color: isSvg
                                  ? const Color(0xFFD6CFFF)
                                  : const Color(0xFFD6E4FF),
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(25),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: isSvg
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
