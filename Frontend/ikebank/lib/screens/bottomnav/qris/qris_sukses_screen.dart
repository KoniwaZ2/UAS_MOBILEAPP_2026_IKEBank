import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class QrisSuksesScreen extends StatelessWidget {
  const QrisSuksesScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
        ),
        title: const Text(
          "QRIS",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 24, fontFamily: 'AlumniSans'),
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
                    Text("Pembayaran Berhasil", style: alumniSansBold.copyWith(fontSize: 32, color: Colors.black)),
                    const SizedBox(height: 16),
                    const Icon(
                      Icons.verified, 
                      color: Color(0xFF00C853), 
                      size: 100,
                    ),
                    const SizedBox(height: 32),

                    // 2. KARTU MERCHANT & NOMINAL
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Kopi Nako", style: TextStyle(fontSize: 28, color: Colors.black, fontWeight: FontWeight.w400)),
                          const SizedBox(height: 4),
                          Text("Tangerang", style: TextStyle(fontSize: 16, color: Colors.black)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Jumlah pembayaran", style: TextStyle(fontSize: 14, color: Colors.black)),
                          const SizedBox(height: 4),
                          const Text("Rp 250.000", style: TextStyle(fontSize: 32, color: Colors.black)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Sumber dana", style: TextStyle(fontSize: 14, color: Colors.grey.shade400)),
                          const SizedBox(height: 2),
                          const Text("Saku Utama", style: TextStyle(fontSize: 18, color: Colors.black)),
                          Text("Rp0", style: TextStyle(fontSize: 14, color: Colors.black)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Rincian Transaksi", style: alumniSansBold.copyWith(fontSize: 24, color: Colors.black)),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow("Nama Acquirer", "Bank BCA"),
                    _buildDetailRow("Merchant PAN ID", "10324909204"),
                    _buildDetailRow("Transaction ID", "23948729309"),
                    _buildDetailRow("Transaction Time", "26 Feb 2026, 09:00 WIB"),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          elevation: 0,
                        ),
                        child: const Text("Kembali", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          final String resiText = """
🚀 Pembayaran Berhasil!
---------------------------
Merchant: Kopi Nako
Nominal : Rp 250.000
Waktu   : 26 Feb 2026, 09:00 WIB
ID Transaksi: 23948729309

Terima kasih telah menggunakan IKE-Bank!
""";

                          Share.share(resiText, subject: 'Bukti Pembayaran Kopi Nako');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9800),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.share, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            const Text("Bagikan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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
          Text(label, style: TextStyle(fontSize: 16, color: Colors.grey.shade800)),
          Text(value, style: const TextStyle(fontSize: 16, color: Colors.black)),
        ],
      ),
    );
  }
}