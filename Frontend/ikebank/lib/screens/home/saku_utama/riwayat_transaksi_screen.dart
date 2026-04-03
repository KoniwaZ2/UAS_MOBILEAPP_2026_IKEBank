import 'package:flutter/material.dart';
import 'dart:math' as math; 

class RiwayatTransaksiScreen extends StatelessWidget {
  const RiwayatTransaksiScreen({super.key});

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
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
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
                          child: const Icon(Icons.add, color: Colors.white, size: 50),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    const Text(
                      "Dana Masuk",
                      style: TextStyle(
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
                      child: const Text(
                        "+Rp 250.000",
                        style: TextStyle(
                          fontFamily: 'AlumniSans',
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildInfoBox(title: "Dari", subtitle: "Ericson Wen\nBank BCA"),
                    const SizedBox(height: 12),
                    _buildInfoBox(title: "Ke", subtitle: "Jacob Sins\nSaku Utama : 10095653346"),

                    const SizedBox(height: 32),

                    const Text(
                      "Detail Transaksi",
                      style: TextStyle(fontFamily: 'AlumniSans', fontSize: 26, fontWeight: FontWeight.w800, color: Colors.black),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow("Nomor referensi", "1000000198341032"),
                    _buildDetailRow("Jenis transaksi", "Dana masuk"),
                    _buildDetailRow("Status", "Berhasil"),
                    _buildDetailRow("Waktu transaksi", "26 Feb 2026, 11:00"),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text("Selesai", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFFF7F00))),
          Text(
            subtitle, 
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
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
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFFFF7F00))),
          Text(value, style: const TextStyle(fontSize: 14, color: Colors.black87)),
        ],
      ),
    );
  }
}