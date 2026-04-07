import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SaldoRataRataScreen extends StatelessWidget {
  const SaldoRataRataScreen({super.key});

  static const primaryColor = Color(0xFFFF7F00);
  static const cardColor = Color(0xFFFFCA96);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),

      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              color: primaryColor,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon:
                        const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Expanded(
                    child: Text(
                      "Saldo Rata-Rata",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // SALDO
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: cardColor.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: SvgPicture.asset(
                            "assets/images/solar_chart-bold.svg",
                            height: 34,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Dana rata-rata sekarang",
                              style: TextStyle(fontSize: 24),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Rp400.000",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),

                    const SizedBox(height: 20),

                    // CARD 1
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: cardColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black26),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: primaryColor,
                                child: Icon(Icons.check, color: Colors.white),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "Pertahankan total dana rata-rata minimal Rp500.000 bulan ini",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          item("1 Kartu Debit"),
                          item("5x Bebas biaya tarik tunai di ATM tiap bulan"),
                          item("Gratis biaya admin tanpa batas"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // CARD 2
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: cardColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black26),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              CircleAvatar(
                                backgroundColor: Colors.white,
                                child: Icon(Icons.help_outline,
                                    color: primaryColor),
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Tentang dana rata-rata",
                                style: TextStyle(
                                  fontSize: 20, //
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          const Text(
                            "Nilai ini adalah perkiraan rata-rata total dana kamu selama 30 hari terakhir. Jumlahnya bisa berubah sesuai transaksi di rekeningmu sampai akhir bulan.",
                            style: TextStyle(
                              fontSize: 18,
                              height: 1.6,
                            ),
                          ),

                          const SizedBox(height: 14),

                          const Text(
                            "Contoh\nHari ini tanggal 1 Oktober",
                            style: TextStyle(fontSize: 18),
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            "Total dana kamu 30 hari terakhir\nTanggal 1-15 September: Rp5.000.000\nTanggal 16-30 September: Rp2.000.000",
                            style: TextStyle(fontSize: 18),
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            "Berarti, dana rata-rata kamu:\n(15 hari x 5.000.000) + (15 hari x 2.000.000) / 30 hari\n= Rp 3.500.000",
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ITEM LIST
  Widget item(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.check, color: primaryColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15.5), // 🔥 naik
            ),
          ),
        ],
      ),
    );
  }
}