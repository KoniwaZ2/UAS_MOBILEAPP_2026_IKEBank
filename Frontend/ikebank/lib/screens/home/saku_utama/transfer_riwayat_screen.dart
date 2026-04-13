import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart'; 
import 'riwayat_pin_screen.dart'; 
import '../../../api/banking.dart';

class TransferRiwayatScreen extends StatefulWidget {
  final String namaPenerima;
  final String nomorRekening;

  const TransferRiwayatScreen({
    super.key, 
    required this.namaPenerima, 
    required this.nomorRekening
  });

  @override
  State<TransferRiwayatScreen> createState() => _TransferRiwayatScreenState();
}

class _TransferRiwayatScreenState extends State<TransferRiwayatScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();

  // Variabel State untuk menyimpan Saku yang dipilih
  String _selectedSumberDana = "Saku Utama";
  String _selectedSumberDanaSaldo = "Rp 0";
  List<Map<String, String>> _availableSourceSakus = [];

  @override
  void initState() {
    super.initState();
    _loadSourceSakuOptions();
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

  String _normalizeCategory(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'utama' || normalized == 'main' || normalized.contains('utama')) {
      return 'utama';
    }
    if (normalized == 'transaksi' || normalized == 'transaction' || normalized.contains('transaksi')) {
      return 'transaksi';
    }
    return normalized;
  }

  Future<void> _loadSourceSakuOptions() async {
    try {
      final raw = await BankingService.sakuList();
      final dynamic payload = raw is Map<String, dynamic>
          ? (raw['data'] ?? raw['results'] ?? raw['sakus'] ?? raw)
          : raw;

      if (payload is! List) {
        return;
      }

      final options = <Map<String, String>>[];
      for (final item in payload.whereType<Map<String, dynamic>>()) {
        final name = _readString(item, const ['saku_name', 'name']);
        final balance = _formatRupiah(_readString(item, const ['balance']));
        final categoryRaw = _readString(item, const ['category_name', 'category']);
        final normalizedCategory = _normalizeCategory(categoryRaw);
        final isPrimary = (item['is_primary'] == true) || name.toLowerCase().contains('utama');
        final isAllowed = isPrimary || normalizedCategory == 'transaksi';

        if (!isAllowed || name.isEmpty) {
          continue;
        }

        options.add({
          'name': name,
          'balance': balance,
          'category': isPrimary ? 'utama' : normalizedCategory,
        });
      }

      if (!mounted || options.isEmpty) {
        return;
      }

      final defaultSource = options.firstWhere(
        (opt) => opt['category'] == 'utama',
        orElse: () => options.first,
      );

      setState(() {
        _availableSourceSakus = options;
        _selectedSumberDana = defaultSource['name'] ?? _selectedSumberDana;
        _selectedSumberDanaSaldo = defaultSource['balance'] ?? _selectedSumberDanaSaldo;
      });
    } catch (_) {
      // keep fallback static UI when API fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0x1AFFCA96), 
        elevation: 0,
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Transfer Dana",
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
                        border: Border.all(color: Colors.grey.shade400, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Transfer ke", style: TextStyle(fontSize: 14, color: Colors.black)),
                                const SizedBox(height: 1),
                                Row(
                                  children: [
                                    Container(
                                      width: 50, height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.grey.shade300),
                                      ),
                                      alignment: Alignment.center,
                                      child: Image.asset('assets/images/IKEHome.png', width: 50, fit: BoxFit.contain),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(widget.namaPenerima, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                                          const SizedBox(height: 2),
                                          Text("IKE Bank: ${widget.nomorRekening}", style: const TextStyle(fontSize: 16, color: Colors.black)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          Divider(height: 1, color: Colors.grey.shade300, thickness: 1),
                          
                          Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: Color(0x80FFD9B0), 
                              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 1.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Jumlah", style: TextStyle(fontSize: 16, color: Colors.black87)),
                                Row(
                                  children: [
                                    const Text(
                                      "Rp ",
                                      style: TextStyle(
                                        fontFamily: 'AlumniSans', 
                                        fontSize: 26, 
                                        fontWeight: FontWeight.w900, 
                                        color: Colors.black 
                                      ),
                                    ),
                                    Expanded(
                                      child: TextField(
                                        controller: _amountController,
                                        keyboardType: TextInputType.number,
                                        style: const TextStyle(fontFamily: 'AlumniSans', fontSize: 32, fontWeight: FontWeight.w900, color: Colors.black),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                          hintText: "0", 
                                          hintStyle: TextStyle(
                                            fontFamily: 'AlumniSans', 
                                            fontSize: 32, 
                                            fontWeight: FontWeight.w900, 
                                            color: Colors.black26
                                          ),
                                        ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly, 
                                          _CurrencyInputFormatter(maxAmount: 50000000),
                                        ],
                                        onChanged: (value) => setState(() {}), 
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          Container(
                            color: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                            child: TextField(
                              controller: _catatanController,
                              style: const TextStyle(fontSize: 14, color: Colors.black),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "Tambah catatan",
                                hintStyle: TextStyle(fontSize: 16, color: Colors.black),
                              ),
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
                        border: Border.all(color: Colors.grey.shade400, width: 1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Sumber dana", style: TextStyle(fontSize: 14, color: Colors.black45)),
                              const SizedBox(height: 1),
                              Text(_selectedSumberDana, style: const TextStyle(fontSize: 16, color: Colors.black)),
                              const SizedBox(height: 1),
                              Text(_selectedSumberDanaSaldo, style: const TextStyle(fontSize: 16, color: Colors.black)),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              _showSumberDanaBottomSheet(context); 
                            }, 
                            child: const Text("Ganti", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFFF7F00))),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade400, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Jenis transfer", style: TextStyle(fontSize: 14, color: Colors.black45)),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Text("BI Fast", style: TextStyle(fontSize: 16, color: Colors.black)),
                              const SizedBox(width: 12),
                              Text(
                                "Rp2.500", 
                                style: TextStyle(
                                  fontSize: 14, 
                                  color: Colors.grey.shade600,
                                  decoration: TextDecoration.lineThrough, 
                                )
                              ),
                              const SizedBox(width: 8),
                              const Text("Gratis", style: TextStyle(fontSize: 16, color: Colors.green)),
                            ],
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
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // 🔥 VALIDASI: Cek jika input kosong atau hanya 0
                    String amountText = _amountController.text.replaceAll('.', '').trim();
                    if (amountText.isEmpty || int.tryParse(amountText) == null || int.parse(amountText) <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Nominal transfer harus lebih dari 0'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return; // Berhenti di sini, tidak lanjut pindah halaman
                    }

                    String nominalTransfer = _amountController.text;

                    // Jika validasi lolos, baru oper semua data ke halaman PIN
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RiwayatPinScreen(
                          namaPenerima: widget.namaPenerima,
                          nomorRekening: widget.nomorRekening,
                          jumlah: nominalTransfer,
                          sumberDana: _selectedSumberDana, 
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7F00),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text("Lanjut", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 UPDATE: Bottom sheet Sumber Dana Anti-Overflow (Turun ke bawah)
  void _showSumberDanaBottomSheet(BuildContext context) {
    if (_availableSourceSakus.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sumber dana belum tersedia')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 🔥 Izinkan popup lebih panjang
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return ConstrainedBox(
          // 🔥 Batasi tinggi agar tidak menabrak batas atas layar (status bar)
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: Padding(
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
                  "Sumber dana",
                  style: TextStyle(fontFamily: 'AlumniSans', fontSize: 28, fontWeight: FontWeight.w800, color: Colors.black),
                ),
                const SizedBox(height: 20),
                
                // 🔥 Bungkus list dengan Flexible + SingleChildScrollView agar bisa di-scroll
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: _availableSourceSakus.map((source) {
                        final name = source['name'] ?? '-';
                        final balance = source['balance'] ?? 'Rp 0';
                        final category = source['category'] ?? '';
                        final isUtama = category == 'utama';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedSumberDana = name;
                                _selectedSumberDanaSaldo = balance;
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
                                        decoration: BoxDecoration(
                                          color: isUtama
                                              ? const Color(0xFFCCCCFF)
                                              : const Color(0xFFD6CFFF),
                                          borderRadius: const BorderRadius.vertical(
                                            bottom: Radius.circular(25),
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: isUtama
                                            ? Image.asset(
                                                'assets/images/IKEHome.png',
                                                height: 24,
                                                fit: BoxFit.contain,
                                              )
                                            : SvgPicture.asset(
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
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              name,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              balance,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (category == 'transaksi')
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF3B44F6),
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(14),
                                          bottomLeft: Radius.circular(12),
                                        ),
                                      ),
                                      child: const Text(
                                        'Transaksi',
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