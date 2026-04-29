import 'package:flutter/material.dart';
import '06_aktivasi_kartu_screen.dart';

class KartuBerhasilScreen extends StatelessWidget {
  const KartuBerhasilScreen({super.key});

  static const primaryColor = Color(0xFFFF7F00);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              color: primaryColor,
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Kartumu sedang diproses",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // CONTENT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  "assets/images/debit.png",
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // SMILE + TEXT
            Expanded(
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Opacity(
                    opacity: 1.0,
                    child: Center(
                      child: Image.asset(
                        "assets/images/mdi_face.png",
                        width: 420,
                      ),
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Selamat! Kartumu berhasil dibuat! Silakan menunggu kartumu diproses, estimasi 3 hari kerja! Jangan lupa untuk aktifkan kartumu setelah tiba ya!",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 16,

                        height: 1.7,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // BUTTON
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AktivasiKartuScreen(),
                        ),
                      );
                    },
                    child: const Center(
                      child: Text(
                        "Aktifkan Kartu Sekarang",
                        style: TextStyle(
                          fontSize: 20, // 🔥 FIX LEBIH BESAR
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
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
