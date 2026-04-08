import 'package:flutter/material.dart';
import 'dart:math' as math;

class RiwayatTransaksiScreen extends StatefulWidget {
  final String transactionTitle;
  final String amount;
  final bool isIncome;
  final String fromInfo;
  final String toInfo;
  final String referenceNumber;
  final String status;
  final String transactionTimeRaw;
  final String transactionTypeLabel;

  const RiwayatTransaksiScreen({
    super.key,
    this.transactionTitle = 'Transaksi',
    this.amount = 'Rp 0',
    this.isIncome = true,
    this.fromInfo = '-',
    this.toInfo = '-',
    this.referenceNumber = '-',
    this.status = 'Berhasil',
    this.transactionTimeRaw = '',
    this.transactionTypeLabel = '',
  });

  @override
  State<RiwayatTransaksiScreen> createState() => _RiwayatTransaksiScreenState();
}

class _RiwayatTransaksiScreenState extends State<RiwayatTransaksiScreen> {
  String _formatTransactionDateTime(String rawValue) {
    if (rawValue.trim().isEmpty) {
      return '-';
    }

    final parsed = DateTime.tryParse(rawValue);
    if (parsed == null) {
      return rawValue;
    }

    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    final local = parsed.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = months[local.month - 1];
    final year = local.year.toString();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day $month $year, $hour:$minute';
  }

  String _normalizeAmount(String value, bool isIncome) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return isIncome ? '+Rp 0' : '-Rp 0';
    }

    if (trimmed.startsWith('+') || trimmed.startsWith('-')) {
      return trimmed;
    }

    return '${isIncome ? '+' : '-'}$trimmed';
  }

  @override
  Widget build(BuildContext context) {
    final signedAmount = _normalizeAmount(widget.amount, widget.isIncome);
    final transactionType = widget.transactionTypeLabel.trim().isNotEmpty
        ? widget.transactionTypeLabel
        : (widget.isIncome ? 'Dana masuk' : 'Dana keluar');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF7F00),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Riwayat Transaksi",
          style: TextStyle(
            fontFamily: 'AlumniSans',
            fontWeight: FontWeight.w800,
            fontSize: 28,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 32.0,
                ),
                child: Column(
                  children: [
                    Transform.rotate(
                      angle: math.pi / 4,
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFCA96).withOpacity(0.8),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Transform.rotate(
                          angle: -math.pi / 4,
                          child: Icon(
                            widget.isIncome ? Icons.add : Icons.arrow_upward,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    Text(
                      transactionType,
                      style: const TextStyle(
                        fontFamily: 'AlumniSans',
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFFF7F00),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        signedAmount,
                        style: const TextStyle(
                          fontFamily: 'AlumniSans',
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildInfoBox(
                      title: "Dari",
                      subtitle: widget.fromInfo.trim().isEmpty
                          ? '-'
                          : widget.fromInfo,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoBox(
                      title: "Ke",
                      subtitle: widget.toInfo.trim().isEmpty ? '-' : widget.toInfo,
                    ),

                    const SizedBox(height: 32),

                    const Text(
                      "Detail Transaksi",
                      style: TextStyle(
                        fontFamily: 'AlumniSans',
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      "Nomor referensi",
                      widget.referenceNumber.trim().isEmpty
                          ? '-'
                          : widget.referenceNumber,
                    ),
                    _buildDetailRow("Jenis transaksi", transactionType),
                    _buildDetailRow(
                      "Status",
                      widget.status.trim().isEmpty ? '-' : widget.status,
                    ),
                    _buildDetailRow(
                      "Waktu transaksi",
                      _formatTransactionDateTime(widget.transactionTimeRaw),
                    ),
                  ],
                ),
              ),
            ),

            // 5. Tombol Selesai di bagian bawah
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7F00),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Selesai",
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
      ),
    );
  }

  Widget _buildInfoBox({required String title, required String subtitle}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFDBB7), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF7F00),
            ),
          ),
          Text(
            subtitle,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFFFF7F00),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
