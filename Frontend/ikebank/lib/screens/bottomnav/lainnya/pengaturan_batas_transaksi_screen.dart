import 'package:flutter/material.dart';
import 'atur_batas_qris_screen.dart';

class PengaturanBatasTransaksiScreen extends StatelessWidget {
  const PengaturanBatasTransaksiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextStyle alumniSansBold = const TextStyle(
      fontWeight: FontWeight.w800,
      fontFamily: 'AlumniSans',
    );

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
          "Pengaturan batas transaksi",
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
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          children: [
            Text(
              "Pengaturan Limit",
              style: alumniSansBold.copyWith(fontSize: 18, color: Colors.black),
            ),
            const SizedBox(height: 1),

            _buildLimitMenuItem(
              title: "Batas transaksi QRIS",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AturBatasQrisScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitMenuItem({
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, color: Colors.black87),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFFFF7F00),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
