import 'package:flutter/material.dart';
import '../../../core/colors.dart';
import 'ktp_camera_screen.dart';

class FotoKtpScreen extends StatelessWidget {
  final String? reference;

  const FotoKtpScreen({super.key, required this.reference});

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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  color: AppColors.textBlack,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              GestureDetector(
                onTap: () {
                  if (reference == null || reference!.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Reference OTP tidak tersedia. Ulangi verifikasi OTP.',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          KtpCameraScreen(reference: reference),
                    ),
                  );
                },
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.inputGrey,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.camera_alt_outlined,
                        size: 48,
                        color: Colors.black87,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Klik untuk mengambil gambar",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade300,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {},
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
  Widget _buildProgressSegment({required bool isActive}) {
    return Expanded(
      child: Container(
        height: 6,
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: [Color(0xFF0000FF), Color(0xFF9999FF)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,

          color: isActive ? null : Colors.white.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
