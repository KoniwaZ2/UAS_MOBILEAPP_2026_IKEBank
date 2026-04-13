import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../api/banking.dart';

class AturBatasQrisScreen extends StatefulWidget {
  const AturBatasQrisScreen({super.key});

  @override
  State<AturBatasQrisScreen> createState() => _AturBatasQrisScreenState();
}

class _AturBatasQrisScreenState extends State<AturBatasQrisScreen> {
  final TextEditingController _amountController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadQrisLimit();
  }

  Future<void> _loadQrisLimit() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final result = await BankingService.getQrisDailyLimit();
      int limit = 10000000;
      if (result is Map<String, dynamic> && result['qris_limit'] != null) {
        limit = int.tryParse(result['qris_limit'].toString()) ?? 10000000;
      }
      _amountController.text = _formatRupiah(limit);
    } catch (e) {
      _error = 'Gagal memuat limit QRIS';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatRupiah(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  void _formatAndValidateInput(String value) {
    String cleanText = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanText.isEmpty) {
      _amountController.text = '';
      return;
    }
    int amount = int.parse(cleanText);
    if (amount > 10000000) {
      amount = 10000000;
    }
    String formatted = _formatRupiah(amount);
    _amountController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  Future<void> _saveLimit() async {
    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      String cleanText = _amountController.text.replaceAll('.', '');
      int amount = int.tryParse(cleanText) ?? 0;
      if (amount < 1000) {
        throw Exception('Minimal limit Rp1.000');
      }
      await BankingService.setQrisDailyLimit(qrisLimit: amount);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Batas transaksi QRIS berhasil disimpan: Rp${_formatRupiah(amount)}",
            ),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isSaving = false;
      });
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF7F00),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Atur batas transaksi QRIS",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            fontFamily: 'AlumniSans',
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  if (_error != null)
                    Container(
                      width: double.infinity,
                      color: Colors.red.shade50,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 32.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Untuk keamanan akunmu, transaksi yang melebihi\njumlah ini akan otomatis dibatalkan.",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade800,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  "Rupiah",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const Spacer(),
                                const Text(
                                  "Rp",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: _amountController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    onChanged: _formatAndValidateInput,
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    enabled: !_isSaving,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Batas maksimum: Rp10.000.000",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: const BoxDecoration(color: Colors.white),
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveLimit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7F00),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 0,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                "Simpan",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
