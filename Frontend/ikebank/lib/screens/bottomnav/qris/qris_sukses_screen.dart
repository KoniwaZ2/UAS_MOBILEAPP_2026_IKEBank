import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class QrisSuksesScreen extends StatelessWidget {
  final Map<String, dynamic> paymentResponse;
  final String qrisNumber;
  final String merchantName;
  final String location;
  final String aquirer;
  final String panId;
  final String amount;
  final String walletName;
  final String walletBalance;

  const QrisSuksesScreen({
    super.key,
    required this.paymentResponse,
    required this.qrisNumber,
    required this.merchantName,
    required this.amount,
    required this.location,
    required this.aquirer,
    required this.panId,
    required this.walletName,
    required this.walletBalance,
  });

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
  }

  Map<String, dynamic> _resolvePayload() {
    final root = _asMap(paymentResponse);
    final data = _asMap(root['data']);
    final transaction = _asMap(root['transaction']);
    final dataTransaction = _asMap(data['transaction']);

    return <String, dynamic>{
      ...root,
      ...data,
      ...transaction,
      ...dataTransaction,
    };
  }

  String _firstString(List<dynamic> values, {String fallback = '-'}) {
    for (final value in values) {
      if (value == null) {
        continue;
      }
      final text = value.toString().trim();
      if (text.isNotEmpty) {
        return text;
      }
    }
    return fallback;
  }

  String _formatAmount(dynamic value) {
    final dynamic parsed = value is num
        ? value
        : num.tryParse(value?.toString() ?? '');
    if (parsed == null) {
      return _firstString([value, amount], fallback: 'Rp 0');
    }

    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(parsed);
  }

  String _formatTransactionTime(dynamic value) {
    if (value == null) {
      return '-';
    }

    final raw = value.toString().trim();
    if (raw.isEmpty) {
      return '-';
    }

    final parsed = DateTime.tryParse(raw);
    if (parsed == null) {
      return raw;
    }

    return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(parsed.toLocal());
  }

  String _compactId(String id) {
    if (id == '-') return id;
    if (id.length <= 16) return id; 
    return "${id.substring(0, 8)}...${id.substring(id.length - 8)}";
  }

  @override
  Widget build(BuildContext context) {
    final payload = _resolvePayload();
    final displayMerchantName = merchantName;
    final merchantSubtitle = location;
    final displayAmount = _formatAmount(amount);
    final sourceName = walletName;
    final sourceBalance = _formatAmount(
      payload['saku_balance'] ?? walletBalance,
    );
    final acquirerName = aquirer;
    final merchantPanId = panId;
    
    final rawTransactionId = _firstString([
      payload['transaction_id'],
      payload['id'],
      payload['reference_id'],
    ], fallback: '-');
    final transactionId = _compactId(rawTransactionId);

    final transactionTime = _formatTransactionTime(
      payload['transaction_time'] ??
          payload['created_at'] ??
          payload['timestamp'],
    );

    final TextStyle alumniSansBold = const TextStyle(
      fontWeight: FontWeight.w800,
      fontFamily: 'AlumniSans',
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () =>
              Navigator.popUntil(context, (route) => route.isFirst),
        ),
        title: const Text(
          "QRIS",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 24,
            fontFamily: 'AlumniSans',
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Pembayaran Berhasil",
                      style: alumniSansBold.copyWith(
                        fontSize: 24,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Icon(
                      Icons.verified,
                      color: Color(0xFF00C853),
                      size: 100,
                    ),
                    const SizedBox(height: 32),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayMerchantName,
                            style: const TextStyle(
                              fontSize: 28,
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            merchantSubtitle,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Jumlah pembayaran",
                            style: TextStyle(fontSize: 14, color: Colors.black),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            displayAmount,
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Sumber dana",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            sourceName,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            sourceBalance,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Rincian Transaksi",
                        style: alumniSansBold.copyWith(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow("Nama Acquirer", acquirerName),
                    _buildDetailRow("Merchant PAN ID", merchantPanId),
                    _buildDetailRow("Transaction ID", transactionId), 
                    _buildDetailRow("Transaction Time", transactionTime),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9800),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Kembali",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          final String resiText =
                              """
🚀 Pembayaran Berhasil!
---------------------------
Merchant: $displayMerchantName
Nominal : $displayAmount
Waktu   : $transactionTime
ID Transaksi: $rawTransactionId

Terima kasih telah menggunakan IKE-Bank!
""";

                          Share.share(
                            resiText,
                            subject: 'Bukti Pembayaran $displayMerchantName',
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9800),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.share,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "Bagikan",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
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
          ],
        ),
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
            style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
        ],
      ),
    );
  }
}