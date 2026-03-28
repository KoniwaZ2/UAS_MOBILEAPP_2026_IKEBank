import 'package:flutter/material.dart';
import '../../../core/colors.dart';
import 'review_foto_ktp_screen.dart'; 

class KtpCameraScreen extends StatelessWidget {
  const KtpCameraScreen({super.key});

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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Pastikan KTP berada di dalam bingkai",
                style: alumniSansBold.copyWith(fontSize: 22, color: AppColors.textBlack),
              ),
              const SizedBox(height: 20),

              // AREA KAMERA DUMMY
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        color: Colors.grey.shade400,
                        child: const Center(
                          child: Icon(Icons.camera_alt, size: 60, color: Colors.white54),
                        ),
                      ),

                      Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.75, 
                          height: MediaQuery.of(context).size.height * 0.25, 
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

                      Positioned(
                        bottom: 30,
                        left: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (context) => const ReviewFotoKtpScreen())
                            );
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
        width: 40, 
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: (isTop && isLeft) ? const Radius.circular(12) : Radius.zero,
            topRight: (isTop && !isLeft) ? const Radius.circular(12) : Radius.zero,
            bottomLeft: (!isTop && isLeft) ? const Radius.circular(12) : Radius.zero,
            bottomRight: (!isTop && !isLeft) ? const Radius.circular(12) : Radius.zero,
          ),
          border: Border(
            top: isTop ? const BorderSide(color: Colors.white, width: 6) : BorderSide.none,
            bottom: !isTop ? const BorderSide(color: Colors.white, width: 6) : BorderSide.none,
            left: isLeft ? const BorderSide(color: Colors.white, width: 6) : BorderSide.none,
            right: !isLeft ? const BorderSide(color: Colors.white, width: 6) : BorderSide.none,
          ),
        ),
      ),
    );
  }

  // --- FUNGSI HELPER UNTUK PROGRESS BAR (Disamakan dengan Register Screen) ---
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
              
          color: isActive 
              ? null 
              : Colors.white.withValues(alpha: 0.6), 
        ),
      ),
    );
  }
}