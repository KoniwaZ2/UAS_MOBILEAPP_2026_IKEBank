import 'package:flutter/material.dart';
import '../../../api/banking.dart';
import 'detail_status_screen.dart';
import 'riwayat_cash_flow_screen.dart';

class CashFlowScreen extends StatefulWidget {
  const CashFlowScreen({super.key});

  @override
  State<CashFlowScreen> createState() => _CashFlowScreenState();
}

class _CashFlowScreenState extends State<CashFlowScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  String _statusRaw = 'optimal';
  String _topExpenseTitle = '-';
  int? _topExpenseAmount;
  int _monthlySavingsAmount = 1532981;
  int _interestTabungan = 132247;
  int _interestDeposito = 40574394;

  @override
  void initState() {
    super.initState();
    _loadCashflowSummary();
  }

  Future<void> _loadCashflowSummary() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final now = DateTime.now();
      final dynamic response = await BankingService.cashflowCalculate(
        month: now.month,
        year: now.year,
      );

      if (response is! Map<String, dynamic>) {
        throw Exception('Format data cash flow tidak valid.');
      }

      final highlights = _readAsMap(response['highlights']);
      final topTransaction = _readAsMap(
        highlights['top_transaction_last_month'],
      );
      final monthlySavings = _readAsMap(highlights['monthly_savings']);
      final interestEarnings = _readAsMap(highlights['interest_earnings']);

      if (!mounted) {
        return;
      }

      setState(() {
        _statusRaw = _readAsString(response['status'], fallback: 'optimal');
        _topExpenseTitle = _resolveTopExpenseTitle(topTransaction);
        _topExpenseAmount = _resolveTopExpenseAmount(topTransaction);
        _monthlySavingsAmount = _readAsInt(monthlySavings['amount']);
        _interestTabungan = _readAsInt(interestEarnings['tabungan']);
        _interestDeposito = _readAsInt(interestEarnings['deposito']);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _readAsMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    return <String, dynamic>{};
  }

  int _readAsInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    final sanitized = value.toString().replaceAll(RegExp(r'[^0-9-]'), '');
    return int.tryParse(sanitized) ?? 0;
  }

  String _readAsString(dynamic value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  String _resolveTopExpenseTitle(Map<String, dynamic> topTransaction) {
    if (topTransaction.isEmpty) {
      return '-';
    }

    final merchantName = _readAsString(topTransaction['merchant_name']);
    if (merchantName.isNotEmpty) {
      return merchantName;
    }

    final description = _readAsString(topTransaction['description']);
    if (description.isNotEmpty) {
      return description;
    }

    final category = _readAsString(topTransaction['category']).toLowerCase();
    switch (category) {
      case 'payment':
        return 'Pembayaran';
      case 'transfer_out':
        return 'Transfer Keluar';
      case 'withdrawal':
        return 'Tarik Tunai';
      case 'other':
        return 'Transaksi Lainnya';
      default:
        return '-';
    }
  }

  int? _resolveTopExpenseAmount(Map<String, dynamic> topTransaction) {
    if (topTransaction.isEmpty) {
      return null;
    }
    if (!topTransaction.containsKey('amount') ||
        topTransaction['amount'] == null) {
      return null;
    }
    return _readAsInt(topTransaction['amount']);
  }

  String _statusLabel(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'sangat_optimal':
        return 'Sangat Optimal';
      case 'optimal':
        return 'Optimal';
      case 'cukup_optimal':
        return 'Cukup Optimal';
      default:
        return 'Belum Optimal';
    }
  }

  Color _statusColor(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'sangat_optimal':
        return const Color(0xFF148F34);
      case 'optimal':
        return Colors.green;
      case 'cukup_optimal':
        return const Color(0xFFFFA000);
      default:
        return const Color(0xFFD32F2F);
    }
  }

  String _formatRupiah(int value) {
    final absolute = value.abs().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < absolute.length; i++) {
      final remaining = absolute.length - i;
      buffer.write(absolute[i]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write('.');
      }
    }
    return 'Rp ${buffer.toString()}';
  }

  String _buildAdviceText() {
    final statusText = _statusLabel(_statusRaw).toLowerCase();
    return 'Wah, keuangan kamu sebulan ini $statusText. '
        'Bulan ini kamu paling banyak transaksi di ${_topExpenseTitle == '-' ? 'kategori belum tersedia' : _topExpenseTitle}. '
        'Jangan lupa minggu ini kamu bisa masukin ${_formatRupiah(_monthlySavingsAmount)} ke Saku Celengan ya!';
  }

  @override
  Widget build(BuildContext context) {
    final statusText = _statusLabel(_statusRaw);
    final statusColor = _statusColor(_statusRaw);

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
        title: const Text(
          "Cash Flow",
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
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: LinearProgressIndicator(
                        color: Color(0xFFFF7F00),
                        minHeight: 2,
                      ),
                    ),

                  if (_errorMessage != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEF9A9A)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Color(0xFFD32F2F),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFD32F2F),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: _loadCashflowSummary,
                            child: const Text('Coba lagi'),
                          ),
                        ],
                      ),
                    ),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.shade400,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/status.png',
                                width: 50,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.image,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                              ),
                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Status Keuangan",
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 0.1),
                                    Text(
                                      statusText,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: statusColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const DetailStatusScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0x80F69500),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: const [
                                      Text(
                                        "Detail",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFFFF7F00),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(
                                        Icons.arrow_forward,
                                        color: Color(0xFFFF7F00),
                                        size: 14,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const RiwayatCashFlowScreen(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: const BoxDecoration(
                              color: Color(0x1AFF7F00),
                              borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(14),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  "Riwayat Status Keuangan",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward,
                                  color: Color(0xFFFF7F00),
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  _buildInfoCard(
                    title: "Transaksi Terbanyak Bulan Lalu",
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _topExpenseTitle,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _topExpenseAmount == null
                              ? '-'
                              : '-${_formatRupiah(_topExpenseAmount!)}',
                          style: const TextStyle(
                            fontFamily: 'AlumniSans',
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFFF7F00),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildInfoCard(
                    title: "Kamu Berhasil Menabung",
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Saku Celengan",
                          style: TextStyle(fontSize: 18, color: Colors.black87),
                        ),
                        Text(
                          '+ ${_formatRupiah(_monthlySavingsAmount)}',
                          style: const TextStyle(
                            fontFamily: 'AlumniSans',
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFFF7F00),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildInfoCard(
                    title: "Perolehan Bungamu",
                    content: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Bunga Tabungan",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              '+ ${_formatRupiah(_interestTabungan)}',
                              style: const TextStyle(
                                fontFamily: 'AlumniSans',
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFFF7F00),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Bunga Deposito",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              '+ ${_formatRupiah(_interestDeposito)}',
                              style: const TextStyle(
                                fontFamily: 'AlumniSans',
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFFF7F00),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.shade400,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Nasihat IKE Bank",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _buildAdviceText(),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 0.5),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required Widget content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade400, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }
}
