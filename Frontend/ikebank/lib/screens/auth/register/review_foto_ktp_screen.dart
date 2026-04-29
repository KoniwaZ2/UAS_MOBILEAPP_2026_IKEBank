import 'package:flutter/material.dart';
import 'package:ikebank/api/auth.dart';
import 'dart:io';
import '../../../core/colors.dart';
import 'isi_data_screen.dart'; // Nanti kita buat file ini

class ReviewFotoKtpScreen extends StatelessWidget {
  final File? imageFile;
  final String phone;
  final String email;
  final String? reference;

  const ReviewFotoKtpScreen({
    super.key,
    this.imageFile,
    required this.phone,
    required this.email,
    this.reference,
  });

  @override
  Widget build(BuildContext context) {
    const TextStyle alumniSansBold = TextStyle(fontWeight: FontWeight.w700);

    return Scaffold(
      backgroundColor:
          AppColors.primaryOrange, // Latar belakang oranye solid di atas
      // ==========================================================
      // APP BAR & PROGRESS BAR
      // ==========================================================
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(
            20.0,
          ), // Beri padding sedikit vertikal
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                // Progress Bar: 3 Nyala (Gradasi Biru), 3 Mati (Putih Transparan)
                _buildProgressSegment(isActive: true),
                _buildProgressSegment(isActive: true),
                _buildProgressSegment(isActive: true),
                _buildProgressSegment(isActive: false),
                _buildProgressSegment(isActive: false),
                _buildProgressSegment(isActive: false),
              ],
            ),
          ),
        ),
      ),

      // ==========================================================
      // KONTEN UTAMA (Lengkungan Putih)
      // ==========================================================
      body: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 16.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================================
              // JUDUL & DESKRIPSI
              // ==========================================================
              Text(
                "Ambil foto KTP Kamu",
                style: alumniSansBold.copyWith(
                  fontSize: 32,
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Pastikan foto tidak blur dan kamu berada di cahaya\nyang terang",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // ==========================================================
              // FOTO KTP PREVIEW
              // ==========================================================
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  height: 200, // Proporsi mirip kartu
                  color: Colors.grey.shade300,
                  child: imageFile != null
                      ? Image.file(
                          imageFile!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.credit_card,
                                size: 80,
                                color: Colors.white70,
                              ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.credit_card,
                            size: 80,
                            color: Colors.white70,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 8),

              // ==========================================================
              // TOMBOL TEKS "AMBIL FOTO ULANG" (Kanan Bawah KTP)
              // ==========================================================
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Kembali ke halaman kamera
                  },
                  child: const Text(
                    "Ambil Foto Ulang",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              const Spacer(), // Dorong tombol "Lanjut" ke paling bawah layar
              // ==========================================================
              // TOMBOL LANJUT
              // ==========================================================
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        30,
                      ), // Pill shape penuh
                    ),
                  ),
                  onPressed: () async {
                    if (imageFile == null ||
                        reference == null ||
                        reference!.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Data foto atau reference OTP belum tersedia.',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    try {
                      final result = await AuthService.uploadKTP(
                        imageFile: imageFile!,
                        reference: reference!,
                      );

                      if (!context.mounted) {
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => IsiDataScreen(
                            phone: phone,
                            email: email,
                            ktpImageFile: imageFile,
                            reference: reference,
                            prefillIdentity:
                                (result['prefill_identity']
                                    as Map<String, dynamic>?) ??
                                <String, dynamic>{},
                          ),
                        ),
                      );
                    } catch (e) {
                      if (!context.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            e.toString().replaceFirst('Exception: ', ''),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Text(
                    "Lanjut",
                    style: alumniSansBold.copyWith(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPER UNTUK MEMBANGUN KOTAK PROGRESS BAR FIGMA ---
  // --- FUNGSI HELPER UNTUK PROGRESS BAR (Disamakan dengan Register Screen) ---
  Widget _buildProgressSegment({required bool isActive}) {
    return Expanded(
      child: Container(
        height: 6, // Ketebalan kotak disesuaikan dengan Figma
        margin: const EdgeInsets.symmetric(
          horizontal: 4.0,
        ), // Jarak antar kotak
        decoration: BoxDecoration(
          // Jika AKTIF (sudah dilewati), beri warna gradasi
          gradient: isActive
              ? const LinearGradient(
                  colors: [
                    Color(0xFF0000FF),
                    Color(0xFF9999FF),
                  ], // Gradasi Biru Tua ke Biru Muda
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,

          // Jika MATI (belum dilewati), beri warna putih keabu-abuan
          color: isActive ? null : Colors.white.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
