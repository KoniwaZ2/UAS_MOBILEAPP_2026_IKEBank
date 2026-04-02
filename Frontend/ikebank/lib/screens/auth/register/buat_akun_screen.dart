import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; 
import '../../../core/colors.dart';
import 'register_screen.dart'; 

class BuatAkunScreen extends StatelessWidget {
  const BuatAkunScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const TextStyle alumniSansBold = TextStyle(fontWeight: FontWeight.w700);

    return Scaffold(
      backgroundColor: AppColors.primaryOrange, 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false, 
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Sebelum mulai...",
                          style: alumniSansBold.copyWith(
                            fontSize: 36,
                            color: AppColors.textBlack,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Siapkan hal-hal berikut untuk membuka akun IKE Bank:",
                          style: TextStyle(
                            fontSize: 20,
                            color: AppColors.textBlack,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 40),

                        _buildRequirementItem(
                          imagePath: 'assets/images/contact.svg', 
                          title: "Nomor ponsel & alamat email",
                          subtitle: "Pakai nomor dan email yang masih aktif.",
                        ),
                        const SizedBox(height: 32),

                        _buildRequirementItem(
                          imagePath: 'assets/images/ktp.svg', 
                          title: "KTP fisik",
                          subtitle: "Pastikan KTP kamu masih dalam kondisi baik.",
                        ),
                        const SizedBox(height: 32),

                        _buildRequirementItem(
                          imagePath: 'assets/images/wifi.svg', 
                          title: "Koneksi internet stabil",
                          subtitle: "Pakai koneksi internet yang lancar dan hindari\nWi-Fi umum.",
                        ),

                        const Spacer(), 

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryOrange,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
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
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRequirementItem({
    required String imagePath,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          imagePath,
          width: 40,
          height: 40,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700, 
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black, 
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}