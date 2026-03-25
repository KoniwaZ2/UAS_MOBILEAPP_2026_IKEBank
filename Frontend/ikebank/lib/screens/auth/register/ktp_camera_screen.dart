import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart'; // Untuk mengambil gambar dari kamera
import '../../../core/colors.dart';
import 'review_foto_ktp_screen.dart'; // Import halaman review foto KTP

class KtpCameraScreen extends StatelessWidget {
  final String? reference;

  const KtpCameraScreen({super.key, required this.reference});

  @override
  Widget build(BuildContext context) {
    const TextStyle alumniSansBold = TextStyle(fontWeight: FontWeight.w700);

    return Scaffold(
      backgroundColor: AppColors.primaryOrange,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(10.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Pastikan KTP berada di dalam bingkai",
                style: alumniSansBold.copyWith(
                  fontSize: 22,
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(height: 20),

              // AREA KAMERA
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // 1. BACKGROUND KAMERA
                      Container(
                        color: Colors.grey.shade400,
                        child: const Center(
                          child: Icon(
                            Icons.camera_alt,
                            size: 60,
                            color: Colors.white54,
                          ),
                        ),
                      ),

                      // 2. BINGKAI KTP (4 Sudut Putih)
                      Center(
                        child: SizedBox(
                          width:
                              MediaQuery.of(context).size.width *
                              0.75, // Lebar bingkai KTP
                          height:
                              MediaQuery.of(context).size.height *
                              0.25, // Tinggi bingkai KTP
                          child: Stack(
                            children: [
                              _buildCorner(isTop: true, isLeft: true),
                              _buildCorner(isTop: true, isLeft: false),
                              _buildCorner(isTop: false, isLeft: true),
                              _buildCorner(isTop: false, isLeft: false),
                            ],
                          ),
                        ),
                      ),

                      // 3. TOMBOL CAPTURE (Jepret)
                      Positioned(
                        bottom: 30,
                        left: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () async {
                            final picker = ImagePicker();

                            final pickedFile = await picker.pickImage(
                              source: ImageSource.gallery,
                              imageQuality: 80,
                            );

                            if (pickedFile != null) {
                              File imageFile = File(pickedFile.path);

                              // 🔥 kirim foto ke halaman review
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReviewFotoKtpScreen(
                                    imageFile: imageFile,
                                    reference: reference,
                                  ),
                                ),
                              );
                            }
                          },
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fungsi helper untuk menggambar sudut bingkai KTP
  Widget _buildCorner({required bool isTop, required bool isLeft}) {
    return Positioned(
      top: isTop ? 0 : null,
      bottom: isTop ? null : 0,
      left: isLeft ? 0 : null,
      right: isLeft ? null : 0,
      child: Container(
        width: 40, // Panjang garis siku
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: (isTop && isLeft)
                ? const Radius.circular(12)
                : Radius.zero,
            topRight: (isTop && !isLeft)
                ? const Radius.circular(12)
                : Radius.zero,
            bottomLeft: (!isTop && isLeft)
                ? const Radius.circular(12)
                : Radius.zero,
            bottomRight: (!isTop && !isLeft)
                ? const Radius.circular(12)
                : Radius.zero,
          ),
          border: Border(
            top: isTop
                ? const BorderSide(color: Colors.white, width: 6)
                : BorderSide.none,
            bottom: !isTop
                ? const BorderSide(color: Colors.white, width: 6)
                : BorderSide.none,
            left: isLeft
                ? const BorderSide(color: Colors.white, width: 6)
                : BorderSide.none,
            right: !isLeft
                ? const BorderSide(color: Colors.white, width: 6)
                : BorderSide.none,
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
