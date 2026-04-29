import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../api/banking.dart';

class TambahDanaSakuScreen extends StatefulWidget {
  const TambahDanaSakuScreen({super.key});

  @override
  State<TambahDanaSakuScreen> createState() => _TambahDanaSakuScreenState();
}

class _TambahDanaSakuScreenState extends State<TambahDanaSakuScreen> {
  final TextEditingController _amountController = TextEditingController();
  String _targetSakuName = 'Saku Utama';
  String _targetSakuBalance = 'Rp 0';
  String _targetSakuId = '';
  List<Map<String, dynamic>> _sourceSakus = [];
  bool _isSubmitting = false;

  String _selectedSumberDanaId = '';
  String _selectedSumberDana = "-";
  String _selectedSumberDanaSaldo = "Rp 0";

  @override
  void initState() {
    super.initState();
    _loadTargetSakuUtama();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadTargetSakuUtama() async {
    try {
      final rawSakuList = await BankingService.sakuList();
      final dynamic payload = rawSakuList is Map<String, dynamic>
          ? (rawSakuList['data'] ??
                rawSakuList['results'] ??
                rawSakuList['sakus'] ??
                rawSakuList)
          : rawSakuList;

      if (payload is! List) {
        return;
      }

      final sakus = payload.whereType<Map<String, dynamic>>().toList();
      if (sakus.isEmpty) {
        return;
      }

      Map<String, dynamic>? primarySaku;
      for (final saku in sakus) {
        if (_readBool(saku, 'is_primary')) {
          primarySaku = saku;
          break;
        }
      }

      primarySaku ??= sakus
          .where(
            (s) => _readString(s, const [
              'saku_name',
              'name',
            ]).toLowerCase().contains('utama'),
          )
          .cast<Map<String, dynamic>?>()
          .firstWhere((_) => true, orElse: () => null);

      primarySaku ??= sakus.first;

      var mergedSaku = primarySaku;
      final sakuId = _readString(mergedSaku, const ['id', 'saku_id']);
      if (sakuId.isNotEmpty) {
        try {
          final detail = await BankingService.sakuDetail(sakuId: sakuId);
          mergedSaku = {...mergedSaku, ...detail};
        } catch (_) {
          // Fall back to saku-list data.
        }
      }

      if (!mounted) {
        return;
      }

      final name = _readString(mergedSaku, const ['saku_name', 'name']);
      final balance = _readString(mergedSaku, const ['balance']);
      final targetSakuId = _readString(mergedSaku, const ['id', 'saku_id']);

      final sourceSakus = sakus.where((saku) {
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
        final isSameAsTarget = sakuId == targetSakuId;
        return !isDeposito && !isSameAsTarget;
      }).toList();

      Map<String, dynamic>? selectedSource;
      if (_selectedSumberDana != '-' && _selectedSumberDana.isNotEmpty) {
        selectedSource = sourceSakus
            .where(
              (s) =>
                  _readString(s, const ['saku_name', 'name']) ==
                  _selectedSumberDana,
            )
            .cast<Map<String, dynamic>?>()
            .firstWhere((_) => true, orElse: () => null);
      }
      selectedSource ??= sourceSakus
          .where((s) => _readString(s, const ['id', 'saku_id']) != targetSakuId)
          .cast<Map<String, dynamic>?>()
          .firstWhere((_) => true, orElse: () => null);
      selectedSource ??= sourceSakus.isNotEmpty ? sourceSakus.first : null;

      final selectedSourceId = selectedSource == null
          ? ''
          : _readString(selectedSource, const ['id', 'saku_id']);
      final selectedSourceName = selectedSource == null
          ? '-'
          : _readString(selectedSource, const ['saku_name', 'name']);
      final selectedSourceBalance = selectedSource == null
          ? 'Rp 0'
          : _formatRupiah(_readString(selectedSource, const ['balance']));

      setState(() {
        _targetSakuName = name.isEmpty ? 'Saku Utama' : name;
        _targetSakuBalance = balance.isEmpty ? 'Rp 0' : _formatRupiah(balance);
        _targetSakuId = targetSakuId;
        _sourceSakus = sourceSakus;
        _selectedSumberDanaId = selectedSourceId;
        _selectedSumberDana = selectedSourceName;
        _selectedSumberDanaSaldo = selectedSourceBalance;
      });
    } catch (_) {
      // Keep existing fallback UI values.
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

  String _extractAmountDigits(String formattedText) {
    return formattedText.replaceAll(RegExp(r'[^0-9]'), '');
  }

  String _parseErrorMessage(String error) {
    final errorLower = error.toLowerCase();

    if (errorLower.contains('insufficient') || errorLower.contains('balance')) {
      return 'Saldo tidak cukup untuk melakukan transfer';
    }

    if (errorLower.contains('not found') || errorLower.contains('tidak ada')) {
      return 'Saku tidak ditemukan. Silakan refresh dan coba lagi';
    }

    if (errorLower.contains('socket') ||
        errorLower.contains('connection') ||
        errorLower.contains('timeout')) {
      return 'Koneksi internet bermasalah. Silakan coba lagi';
    }

    if (errorLower.contains('unauthorized') ||
        errorLower.contains('unauthenticated')) {
      return 'Sesi Anda telah habis. Silakan login kembali';
    }

    if (errorLower.contains('bad request') || errorLower.contains('invalid')) {
      return 'Data transfer tidak valid. Periksa kembali data Anda';
    }

    if (errorLower.contains('403') || errorLower.contains('forbidden')) {
      return 'Anda tidak memiliki izin untuk melakukan transfer ini';
    }

    if (errorLower.contains('500') || errorLower.contains('server error')) {
      return 'Terjadi kesalahan pada server. Silakan coba lagi nanti';
    }

    if (error.isNotEmpty && !error.startsWith('Exception:')) {
      return error;
    }

    return error.replaceFirst('Exception: ', '').isNotEmpty
        ? error.replaceFirst('Exception: ', '')
        : 'Transfer gagal. Silakan coba lagi';
  }

  Future<void> _submitInternalTransfer() async {
    final amountDigits = _extractAmountDigits(_amountController.text);
    if (amountDigits.isEmpty ||
        int.tryParse(amountDigits) == null ||
        int.parse(amountDigits) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nominal transfer harus lebih dari 0'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedSumberDanaId.isEmpty || _targetSakuId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sumber atau tujuan saku belum valid'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedSumberDanaId == _targetSakuId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sumber dan tujuan saku tidak boleh sama'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await BankingService.internalTransfer(
        sourceSakuId: _selectedSumberDanaId,
        destinationSakuId: _targetSakuId,
        amount: amountDigits,
        description:
            'Tambah dana dari $_selectedSumberDana ke $_targetSakuName',
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tambah Dana Berhasil!'),
          backgroundColor: Color(0xFF00C853),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      String errorMessage = "Gagal menambahkan dana. Silakan coba lagi.";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
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
          "Tambah Dana",
          style: TextStyle(
            fontFamily: 'AlumniSans',
            fontWeight: FontWeight.w800,
            fontSize: 24,
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
                                  "Tambahkan ke",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Container(
                                      width: 45,
                                      height: 50,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFCCCCFF),
                                        borderRadius: BorderRadius.vertical(
                                          bottom: Radius.circular(25),
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Image.asset(
                                        'assets/images/IKEHome.png',
                                        height: 24,
                                        fit: BoxFit.contain,
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
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 0.5),
                                        Text(
                                          _targetSakuBalance,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
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
                            color: const Color(0x1AFFCA96),
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Jumlah",
                                  style: TextStyle(
                                    fontSize: 16,
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
                                          hintText: "100.000",
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
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                _selectedSumberDana,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                _selectedSumberDanaSaldo,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              _showSumberDanaBottomSheet(context);
                            },
                            child: const Text(
                              "Ganti",
                              style: TextStyle(
                                fontSize: 16,
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
                  onPressed: _isSubmitting ? null : _submitInternalTransfer,
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
                      const Text(
                        "Tambah Dana",
                        style: TextStyle(
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

  // 🔥 UPDATE: Bottom sheet Sumber Dana yang sudah Anti-Overflow
  void _showSumberDanaBottomSheet(BuildContext context) {
    if (_sourceSakus.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada sumber dana yang tersedia')),
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
      builder: (context) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: Padding(
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
                  "Sumber Dana",
                  style: TextStyle(
                    fontFamily: 'AlumniSans',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),

                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: _sourceSakus.map((saku) {
                        final sourceId = _readString(saku, const [
                          'id',
                          'saku_id',
                        ]);
                        final sourceName = _readString(saku, const [
                          'saku_name',
                          'name',
                        ]);
                        final sourceBalance = _formatRupiah(
                          _readString(saku, const ['balance']),
                        );
                        final isSelected = _selectedSumberDana == sourceName;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedSumberDanaId = sourceId;
                                _selectedSumberDana = sourceName;
                                _selectedSumberDanaSaldo = sourceBalance;
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
                                      color: isSelected
                                          ? const Color(0xFFFF7F00)
                                          : const Color(0xFFFFDBB7),
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
                                          height: 24,
                                          colorFilter: const ColorFilter.mode(
                                            Color(0xFFFF7F00),
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                if (sourceId == _targetSakuId)
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
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
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
    if (newValue.text.isEmpty) {
      return newValue;
    }

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
