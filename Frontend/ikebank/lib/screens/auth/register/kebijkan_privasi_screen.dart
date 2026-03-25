import 'package:flutter/material.dart';
import '../../../core/colors.dart';

class KebijakanPrivasiScreen extends StatelessWidget {
  const KebijakanPrivasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryOrange,
      // ==========================================================
      // APP BAR (Judul & Panah Kembali)
      // ==========================================================
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Kebijakan Privasi",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 24,
          ),
        ),
      ),
      
      // ==========================================================
      // KONTEN UTAMA (Kertas Putih)
      // ==========================================================
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: SingleChildScrollView( // Agar teks panjang bisa di-scroll
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Kebijakan Privasi",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textBlack),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Versi: 3.0\nTanggal Efektif: 18 Februari 2026",
                  style: TextStyle(fontSize: 20, color: AppColors.textBlack, height: 1.5),
                ),
                const SizedBox(height: 24),
                const Text(
                  "A. Pendahuluan",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textBlack),
                ),
                const SizedBox(height: 16),
                Text(
                  "Kebijakan Privasi ini merupakan bagian yang tidak terpisahkan dari Syarat dan Ketentuan IKE Bank.\n\n"
                  "PT IKE Bank Indonesia yang memiliki layanan perbankan digital dengan nama IKE Bank (untuk selanjutnya disebut sebagai “IKE Bank” atau “Kami”) memahami pentingnya pelindungan Data Pribadi yang diatur dalam Undang-Undang No. 27 Tahun 2022 tentang Pelindungan Data Pribadi (untuk selanjutnya disebut sebagai “UU PDP”) maupun dalam (i) Peraturan Otoritas Jasa Keuangan No. 22 Tahun 2023 tentang Pelindungan Konsumen dan Masyarakat di Sektor Jasa Keuangan (untuk selanjutnya disebut sebagai “POJK Pelindungan Konsumen”) dan (ii) Peraturan Bank Indonesia Nomor 3 Tahun 2023 tentang Pelindungan Konsumen Bank Indonesia (untuk selanjutnya disebut sebagai “PBI 3/2023”), beserta peraturan pelaksanaannya dan perubahannya dari waktu ke waktu.\n\n"
                  "Oleh karena itu, Kami berkomitmen untuk melaksanakan ketentuan UU PDP, POJK Pelindungan Konsumen dan PBI 3/2023 beserta peraturan-peraturan terkait maupun peraturan pelaksanaanya demi menjaga kerahasiaan dan memastikan",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey.shade800,
                    height: 1.6, // Jarak antar baris agar nyaman dibaca
                  ),
                  textAlign: TextAlign.justify, // Teks rata kiri-kanan seperti di Figma
                ),
                const SizedBox(height: 40), // Jarak ekstra di bagian paling bawah
              ],
            ),
          ),
        ),
      ),
    );
  }
}