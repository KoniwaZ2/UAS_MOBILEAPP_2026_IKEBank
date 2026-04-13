import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../api/banking.dart';
import 'deposito_konfirmasi_screen.dart';

class DepositoSpesialScreen extends StatefulWidget {
  final int depositoId;
  final double sukuBunga;
  final int jangkaWaktuBulan;
  final bool isSpecial;
  final int? sisaKuota;

  const DepositoSpesialScreen({
    super.key,
    this.depositoId = 1,
    this.sukuBunga = 8.8,
    this.jangkaWaktuBulan = 1,
    this.isSpecial = true,
    this.sisaKuota,
  });

  @override
  State<DepositoSpesialScreen> createState() => _DepositoSpesialScreenState();
}

class _DepositoSpesialScreenState extends State<DepositoSpesialScreen> {
  final TextEditingController _amountController = TextEditingController();
  static const int _specialQuotaBaseline = 100;

  String _selectedSumber = '-';
  String _selectedSumberSaldo = 'Rp 0';
  bool _isLoadingSources = true;
  bool _isEstimating = false;
  int? _selectedSumberId;
  String _estimasiJatuhTempo = '-';
  List<Map<String, dynamic>> _availableSources = [];

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_handleAmountChanged);
    _loadSumberDana();
  }

  void _handleAmountChanged() {
    _refreshEstimate();
  }

  String _formatRate(double rate) {
    if (rate == rate.roundToDouble()) {
      return rate.toStringAsFixed(0);
    }

    return rate
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  double _specialQuotaProgress() {
    final remaining = widget.sisaKuota;
    if (remaining == null) {
      return 1;
    }

    return (remaining / _specialQuotaBaseline).clamp(0, 1).toDouble();
  }

  String _specialQuotaText() {
    final remaining = widget.sisaKuota;
    if (remaining == null) {
      return 'Kuota terbatas';
    }

    if (remaining <= 0) {
      return 'Kuota habis';
    }

    return 'Tersisa $remaining kuota';
  }

  double _parseAmount(dynamic value) {
    final cleaned = (value ?? '0').toString().replaceAll(',', '.').trim();
    return double.tryParse(cleaned) ?? 0;
  }

  String _formatRupiah(num amount) {
    final rounded = amount.round();
    final digits = rounded.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      final remaining = digits.length - i;
      buffer.write(digits[i]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write('.');
      }
    }

    return 'Rp ${buffer.toString()}';
  }

  bool _isAllowedSource(Map<String, dynamic> saku) {
    final category = (saku['category_name'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
    final isPrimary = saku['is_primary'] == true;

    if (category == 'celengan' || category == 'deposito') {
      return false;
    }

    return isPrimary || category == 'nabung' || category == 'transaksi';
  }

  Future<void> _loadSumberDana() async {
    try {
      final raw = await BankingService.sakuList();
      final dynamic payload = raw is List
          ? raw
          : (raw['data'] ?? raw['results'] ?? raw['sakus'] ?? <dynamic>[]);

      final sources = payload is List
          ? payload
                .whereType<Map<String, dynamic>>()
                .where(_isAllowedSource)
                .toList()
          : <Map<String, dynamic>>[];

      if (!mounted) {
        return;
      }

      if (sources.isEmpty) {
        setState(() {
          _availableSources = [];
          _isLoadingSources = false;
          _selectedSumberId = null;
          _selectedSumber = '-';
          _selectedSumberSaldo = 'Rp 0';
          _estimasiJatuhTempo = '-';
        });
        return;
      }

      final first = sources.first;
      setState(() {
        _availableSources = sources;
        _isLoadingSources = false;
        _selectedSumberId = int.tryParse((first['id'] ?? '').toString());
        _selectedSumber = (first['saku_name'] ?? '-').toString();
        _selectedSumberSaldo = _formatRupiah(_parseAmount(first['balance']));
      });

      _refreshEstimate();
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingSources = false;
        _availableSources = [];
      });
    }
  }

  Future<void> _refreshEstimate() async {
    if (!mounted || _selectedSumberId == null) {
      return;
    }

    final amount =
        int.tryParse(_amountController.text.replaceAll('.', '')) ?? 0;
    if (amount < 1000000) {
      if (mounted) {
        setState(() {
          _estimasiJatuhTempo = '-';
          _isEstimating = false;
        });
      }
      return;
    }

    setState(() {
      _isEstimating = true;
    });

    try {
      final result = await BankingService.estimasiDeposito(
        depositoId: widget.depositoId,
        sourceSakuId: _selectedSumberId!,
        amount: amount,
      );

      if (!mounted) {
        return;
      }

      final estimation = _parseAmount(result['maturity_estimation']);
      setState(() {
        _estimasiJatuhTempo = _formatRupiah(estimation);
        _isEstimating = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _estimasiJatuhTempo = '-';
        _isEstimating = false;
      });
    }
  }

  @override
  void dispose() {
    _amountController.removeListener(_handleAmountChanged);
    _amountController.dispose();
    super.dispose();
  }

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
        centerTitle: true,
        title: Text(
          widget.isSpecial ? "Deposito Spesial" : "Buka Deposito",
          style: const TextStyle(
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
              height: 100,
              color: const Color(0x1AFFCA96),
            ),

            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 8.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.shade400,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Bunga saat ini :",
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFF7F00),
                                    ),
                                  ),
                                  Text(
                                    "${_formatRate(widget.sukuBunga)}% p.a",
                                    style: const TextStyle(
                                      fontFamily: 'AlumniSans',
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFFFF7F00),
                                    ),
                                  ),
                                ],
                              ),

                              if (widget.isSpecial) ...[
                                const SizedBox(height: 24),
                                Builder(
                                  builder: (context) {
                                    final progress = _specialQuotaProgress();
                                    final markerX = (progress * 2 - 1).clamp(
                                      -1.0,
                                      1.0,
                                    );

                                    return Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Container(
                                          height: 12,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            border: Border.all(
                                              color: Colors.black,
                                              width: 1,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              9,
                                            ),
                                            child: LinearProgressIndicator(
                                              value: progress,
                                              backgroundColor:
                                                  Colors.transparent,
                                              valueColor:
                                                  const AlwaysStoppedAnimation<
                                                    Color
                                                  >(Color(0xFFFF7F00)),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 0,
                                          right: 0,
                                          top: -24,
                                          child: Align(
                                            alignment: Alignment(markerX, 0),
                                            child: SvgPicture.asset(
                                              'assets/images/api.svg',
                                              height: 26,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _specialQuotaText(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            _CurrencyInputFormatter(),
                          ],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF5F5F5),
                            hintText: "Jumlah penempatan",
                            hintStyle: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.normal,
                            ),

                            prefixText: 'Rp ',
                            prefixStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),

                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 20,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.grey.shade400,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Color(0xFFFF7F00),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 24.0),
                          child: Text(
                            "Min. Rp1.000.000 Maks Rp100.000.000",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.shade400,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Sumber dana",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _selectedSumber,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _selectedSumberSaldo,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              _isLoadingSources
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : GestureDetector(
                                      onTap: _availableSources.isEmpty
                                          ? null
                                          : () {
                                              _showPilihSumberBottomSheet(
                                                context,
                                              );
                                            },
                                      child: Text(
                                        "Ganti",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: _availableSources.isEmpty
                                              ? Colors.grey
                                              : const Color(0xFFFF7F00),
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.shade400,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Estimasi dana saat jatuh tempo",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isEstimating
                                    ? 'Menghitung...'
                                    : _estimasiJatuhTempo,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Jangka waktu : ${widget.jangkaWaktuBulan} Bulan",
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Text(
                            "Hitungan simulasi sudah termasuk potongan pajak bunga.",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
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
                        String cleanText = _amountController.text.replaceAll(
                          '.',
                          '',
                        );
                        double inputAmount = double.tryParse(cleanText) ?? 0;

                        if (_selectedSumberId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Sumber dana belum tersedia"),
                            ),
                          );
                          return;
                        }

                        if (inputAmount >= 1000000) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DepositoKonfirmasiScreen(
                                depositoId: widget.depositoId,
                                sourceSakuId: _selectedSumberId!,
                                jumlahPenempatan: inputAmount,
                                sukuBunga: widget.sukuBunga,
                                jangkaWaktuBulan: widget.jangkaWaktuBulan,
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Minimal penempatan Rp 1.000.000"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF7F00),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Lanjut",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _selectSourceAndClose(
    Map<String, dynamic> source,
    BuildContext context,
  ) {
    setState(() {
      _selectedSumberId = int.tryParse((source['id'] ?? '').toString());
      _selectedSumber = (source['saku_name'] ?? '-').toString();
      _selectedSumberSaldo = _formatRupiah(_parseAmount(source['balance']));
    });

    Navigator.pop(context);
    _refreshEstimate();
  }

  Widget _buildSourceTile(Map<String, dynamic> source, BuildContext context) {
    final isPrimary = source['is_primary'] == true;
    final category = (source['category_name'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
    final sourceId = int.tryParse((source['id'] ?? '').toString());
    final isSelected = sourceId != null && sourceId == _selectedSumberId;
    final sourceName = (source['saku_name'] ?? '-').toString();
    final sourceBalance = _formatRupiah(_parseAmount(source['balance']));
    final isTransaksi = category == 'transaksi';

    return GestureDetector(
      onTap: () => _selectSourceAndClose(source, context),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8F0),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFFF7F00)
                    : const Color(0x4D000000),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 55,
                  decoration: BoxDecoration(
                    color: isPrimary
                        ? const Color(0xFFD6E4FF)
                        : const Color(0xFFD6CFFF),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(25),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: isPrimary
                      ? Image.asset(
                          'assets/images/IKEHome.png',
                          height: 28,
                          fit: BoxFit.contain,
                          errorBuilder: (c, e, s) => const Icon(
                            Icons.account_balance,
                            color: Colors.blue,
                          ),
                        )
                      : SvgPicture.asset(
                          'assets/images/bag.svg',
                          height: 28,
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
                      sourceName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sourceBalance,
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isTransaksi)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFF1A36DF),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(14),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: const Text(
                  "Transaksi",
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
    );
  }

  void _showPilihSumberBottomSheet(BuildContext context) {
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
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Sumber dana",
                style: TextStyle(
                  fontFamily: 'AlumniSans',
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              ..._availableSources.map(
                (source) => _buildSourceTile(source, sheetContext),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    String cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanText.isEmpty) return newValue.copyWith(text: '');

    int value = int.tryParse(cleanText) ?? 0;

    if (value > 100000000) {
      cleanText = '100000000';
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
