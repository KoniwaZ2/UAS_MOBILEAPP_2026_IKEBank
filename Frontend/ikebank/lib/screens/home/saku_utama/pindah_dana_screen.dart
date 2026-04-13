import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import '../../../api/banking.dart';

class PindahDanaScreen extends StatefulWidget {
  final String? initialSourceSakuId;
  final String? initialSourceSakuName;
  final String? initialSourceSakuBalance;
  final String? initialDestinationSakuId;
  final String? initialDestinationSakuName;
  final String? initialDestinationSakuBalance;

  const PindahDanaScreen({
    super.key,
    this.initialSourceSakuId,
    this.initialSourceSakuName,
    this.initialSourceSakuBalance,
    this.initialDestinationSakuId,
    this.initialDestinationSakuName,
    this.initialDestinationSakuBalance,
  });

  @override
  State<PindahDanaScreen> createState() => _PindahDanaScreenState();
}

class _PindahDanaScreenState extends State<PindahDanaScreen> {
  final TextEditingController _amountController = TextEditingController();
  String _sourceSakuName = 'Saku Utama';
  String _sourceSakuSaldo = 'Rp 0';
  String _sourceSakuId = '';
  String _selectedTujuan = '-';
  String _selectedTujuanSaldo = 'Rp 0';
  String _selectedTujuanId = '';
  List<Map<String, dynamic>> _destinationSakus = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    _sourceSakuId = widget.initialSourceSakuId?.trim() ?? '';
    _selectedTujuanId = widget.initialDestinationSakuId?.trim() ?? '';

    final initialSourceName = widget.initialSourceSakuName?.trim() ?? '';
    if (initialSourceName.isNotEmpty) {
      _sourceSakuName = initialSourceName;
    }

    final initialSourceBalance =
        widget.initialSourceSakuBalance?.trim() ?? '';
    if (initialSourceBalance.isNotEmpty) {
      _sourceSakuSaldo = _formatRupiah(initialSourceBalance);
    }

    final initialDestinationName =
        widget.initialDestinationSakuName?.trim() ?? '';
    if (initialDestinationName.isNotEmpty) {
      _selectedTujuan = initialDestinationName;
    }

    final initialDestinationBalance =
        widget.initialDestinationSakuBalance?.trim() ?? '';
    if (initialDestinationBalance.isNotEmpty) {
      _selectedTujuanSaldo = _formatRupiah(initialDestinationBalance);
    }

    _loadSakuData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadSakuData() async {
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

      Map<String, dynamic>? selectedSourceSaku;
      if (_sourceSakuId.isNotEmpty) {
        selectedSourceSaku = sakus
            .where((s) => _readString(s, const ['id', 'saku_id']) == _sourceSakuId)
            .cast<Map<String, dynamic>?>()
            .firstWhere((_) => true, orElse: () => null);
      }

      selectedSourceSaku ??= sakus
          .where(
            (s) => _readBool(s, 'is_primary'),
          )
          .cast<Map<String, dynamic>?>()
          .firstWhere((_) => true, orElse: () => null);

      selectedSourceSaku ??= sakus
          .where(
            (s) => _readString(s, const ['saku_name', 'name'])
                .toLowerCase()
                .contains('utama'),
          )
          .cast<Map<String, dynamic>?>()
          .firstWhere((_) => true, orElse: () => null);

      selectedSourceSaku ??= sakus.first;

      var mergedSourceSaku = selectedSourceSaku;
      final sourceSakuId = _readString(
        mergedSourceSaku,
        const ['id', 'saku_id'],
      );
      if (sourceSakuId.isNotEmpty) {
        try {
          final detail = await BankingService.sakuDetail(sakuId: sourceSakuId);
          mergedSourceSaku = {...mergedSourceSaku, ...detail};
        } catch (_) {
          // gunakan data dari saku-list jika detail tidak tersedia
        }
      }

      final destinationSakus = sakus.where((saku) {
        final sakuId = _readString(saku, const ['id', 'saku_id']);
        final sakuName = _readString(saku, const ['saku_name', 'name']).toLowerCase();
        final category = _readString(saku, const ['category_name', 'category']).toLowerCase();
        final isDeposito = category.contains('deposito') || sakuName.contains('deposito');
        final isSameAsSource = sakuId == sourceSakuId;
        return !isDeposito && !isSameAsSource;
      }).toList();

      Map<String, dynamic>? selectedDestination;
      if (_selectedTujuanId.isNotEmpty) {
        selectedDestination = destinationSakus
            .where((s) => _readString(s, const ['id', 'saku_id']) == _selectedTujuanId)
            .cast<Map<String, dynamic>?>()
            .firstWhere((_) => true, orElse: () => null);
      }
      selectedDestination ??= destinationSakus.isNotEmpty ? destinationSakus.first : null;

      var mergedDestinationSaku = selectedDestination;
      if (mergedDestinationSaku != null) {
        final destinationSakuId = _readString(mergedDestinationSaku, const ['id', 'saku_id']);
        if (destinationSakuId.isNotEmpty) {
          try {
            final detail = await BankingService.sakuDetail(sakuId: destinationSakuId);
            mergedDestinationSaku = {...mergedDestinationSaku, ...detail};
          } catch (_) {
            // gunakan data dari saku-list jika detail tidak tersedia
          }
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _sourceSakuId = sourceSakuId;
        _sourceSakuName = _readString(mergedSourceSaku, const ['saku_name', 'name']).isEmpty
            ? 'Saku Utama'
            : _readString(mergedSourceSaku, const ['saku_name', 'name']);
        _sourceSakuSaldo = _formatRupiah(_readString(mergedSourceSaku, const ['balance']));
        _destinationSakus = destinationSakus;
        _selectedTujuanId = mergedDestinationSaku == null
            ? ''
            : _readString(mergedDestinationSaku, const ['id', 'saku_id']);
        _selectedTujuan = mergedDestinationSaku == null
            ? '-'
            : _readString(mergedDestinationSaku, const ['saku_name', 'name']);
        _selectedTujuanSaldo = mergedDestinationSaku == null
            ? 'Rp 0'
            : _formatRupiah(_readString(mergedDestinationSaku, const ['balance']));
      });
    } catch (_) {
      // keep fallback UI
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

  Future<void> _submitInternalTransfer() async {
    final amountDigits = _extractAmountDigits(_amountController.text);
    if (amountDigits.isEmpty || int.tryParse(amountDigits) == null || int.parse(amountDigits) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal transfer harus lebih dari 0'), backgroundColor: Colors.red,),
      );
      return;
    }

    if (_sourceSakuId.isEmpty || _selectedTujuanId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sumber atau tujuan saku belum valid'), backgroundColor: Colors.red,),
      );
      return;
    }

    if (_sourceSakuId == _selectedTujuanId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sumber dan tujuan saku tidak boleh sama'), backgroundColor: Colors.red,),
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
          "Pindah Dana",
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
                                const Text("Pindahkan ke", style: TextStyle(fontSize: 16, color: Colors.black)),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 45, height: 50,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFD6CFFF),
                                            borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
                                          ),
                                          alignment: Alignment.center,
                                          child: SvgPicture.asset(
                                            'assets/images/bag.svg', 
                                            height: 24,
                                            colorFilter: const ColorFilter.mode(Color(0xFFFF7F00), BlendMode.srcIn),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(_selectedTujuan, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                                            const SizedBox(height: 2),
                                            Text(_selectedTujuanSaldo, style: const TextStyle(fontSize: 14, color: Colors.black)),
                                          ],
                                        ),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        _showPilihTujuanBottomSheet(context);
                                      },
                                      child: const Text("Ganti", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFFF7F00))),
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
                                const Text("Jumlah", style: TextStyle(fontSize: 14, color: Colors.black)),
                                Row(
                                  children: [
                                    Text(
                                      "Rp ",
                                      style: TextStyle(
                                        fontFamily: 'AlumniSans', 
                                        fontSize: 32, 
                                        fontWeight: FontWeight.w900, 
                                        color: _amountController.text.isEmpty ? Colors.grey.shade400 : const Color(0xFFFF7F00)
                                      ),
                                    ),
                                    Expanded(
                                      child: TextField(
                                        controller: _amountController,
                                        keyboardType: TextInputType.number,
                                        style: const TextStyle(fontFamily: 'AlumniSans', fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFFFF7F00)),
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                          hintText: "100.000",
                                          hintStyle: TextStyle(
                                            fontFamily: 'AlumniSans', 
                                            fontSize: 32, 
                                            fontWeight: FontWeight.w900, 
                                            color: Colors.grey.shade400
                                          )
                                        ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly, 
                                          _CurrencyInputFormatter(maxAmount: 50000000),
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
                          const Text("Dari", style: TextStyle(fontSize: 12, color: Colors.black)),
                          const SizedBox(height: 4),
                          Text(_sourceSakuName, style: const TextStyle(fontSize: 16, color: Colors.black)),
                          const SizedBox(height: 2),
                          Text(_sourceSakuSaldo, style: const TextStyle(fontSize: 14, color: Colors.black)),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isSubmitting ? 'Memindahkan...' : 'Pindah Dana',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        "Rp ${_amountController.text.isEmpty ? '0' : _amountController.text}", 
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
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
          padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 16.0, bottom: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50, height: 5,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Pindahkan ke",
                style: TextStyle(fontFamily: 'AlumniSans', fontSize: 28, fontWeight: FontWeight.w800, color: Colors.black),
              ),
              const SizedBox(height: 20),
              ..._destinationSakus.map((saku) {
                final destinationId = _readString(saku, const ['id', 'saku_id']);
                final destinationName = _readString(saku, const ['saku_name', 'name']);
                final destinationBalance = _formatRupiah(_readString(saku, const ['balance']));
                final isSelected = _selectedTujuanId == destinationId;
                final category = _readString(saku, const ['category_name', 'category']).toLowerCase();
                final isUtama = _readBool(saku, 'is_primary') || destinationName.toLowerCase().contains('utama');

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTujuanId = destinationId;
                        _selectedTujuan = destinationName;
                        _selectedTujuanSaldo = destinationBalance;
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
                              color: isSelected ? const Color(0xFFFF7F00) : const Color(0xFFFFDBB7),
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
                                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
                                ),
                                alignment: Alignment.center,
                                child: SvgPicture.asset(
                                  'assets/images/bag.svg',
                                  height: 24,
                                  colorFilter: const ColorFilter.mode(Color(0xFFFF7F00), BlendMode.srcIn),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    destinationName,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    destinationBalance,
                                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                                  ),
                                  if (category.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      category,
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (isUtama)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF7F00),
                                borderRadius: BorderRadius.only(topRight: Radius.circular(14), bottomLeft: Radius.circular(12)),
                              ),
                              child: const Text(
                                "Utama",
                                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
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
}

class _CurrencyInputFormatter extends TextInputFormatter {
  final int maxAmount;
  _CurrencyInputFormatter({required this.maxAmount});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    String cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanText.isEmpty) return newValue.copyWith(text: '');
    int value = int.parse(cleanText);
    if (value > maxAmount) { value = maxAmount; cleanText = maxAmount.toString(); }
    String formatted = '';
    int count = 0;
    for (int i = cleanText.length - 1; i >= 0; i--) {
      if (count == 3) { formatted = '.$formatted'; count = 0; }
      formatted = cleanText[i] + formatted;
      count++;
    }
    return TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }
}