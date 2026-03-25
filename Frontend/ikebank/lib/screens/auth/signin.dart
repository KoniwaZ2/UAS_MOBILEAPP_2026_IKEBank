import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/colors.dart';
import 'riplay.dart';
import 'login/masuk_screen.dart';
import 'register/buat_akun_screen.dart';

class SignIn extends StatelessWidget {
  const SignIn({super.key});

  @override
  Widget build(BuildContext context) {
    const TextStyle alumniSansBold = TextStyle(fontWeight: FontWeight.w700);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.43,
              width: double.infinity,
              child: Image.asset(
                'assets/images/IKEBank.png',
                fit: BoxFit.cover,
              ),
            ),

            Container(
              width: double.infinity,
              transform: Matrix4.translationValues(0.0, -30.0, 0.0),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Teman Menabung Kamu 🤝",
                    style: alumniSansBold.copyWith(
                      fontSize: 32,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black.withValues(alpha: 0.5), width: 1.5),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(0),
                        bottomRight: Radius.circular(0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Benefit kamu pakai IKE Bank",
                          style: alumniSansBold.copyWith(
                            fontSize: 24,
                            color: AppColors.textBlack,
                          ),
                        ),
                        const SizedBox(height: 20),

                        _buildBenefitItem(
                          assetPath: 'assets/images/infinity.svg',
                          text: "Transfer gratis unlimited dan bebas biaya admin",
                        ),
                        const SizedBox(height: 16),
                        _buildBenefitItem(
                          assetPath: 'assets/images/money.png', 
                          text: "Nabung otomatis dengan fitur AI, dapat bunga 10% p.a",
                        ),
                        const SizedBox(height: 16),
                        _buildBenefitItem(
                          assetPath: 'assets/images/deal.png',
                          text: "Buka deposito, bunga hingga 7% p.a",
                        ),
                        
                        const SizedBox(height: 40),
                        
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.black, 
                              height: 1.5,
                            ),
                            children: [
                              const TextSpan(
                                text: "IKE Bank",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,        
                                ),
                              ),
                              const TextSpan(
                                text: " (PT IKE Bank Indonesia) dimiliki oleh IKE International Corporate Trademark",
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => const RiplayScreen())
                        );
                      },
                      child: Text(
                        "Ringkasan Informasi Produk dan Layanan (RIPLAY) Umum",
                        style: alumniSansBold.copyWith(
                          fontSize: 18, 
                          color: AppColors.primaryOrange,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.primaryOrange.withValues(alpha: 0.25),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const MasukScreen()));
                          },
                          child: Text(
                            'Masuk',
                            style: alumniSansBold.copyWith(
                              fontSize: 20, 
                              color: AppColors.primaryOrange
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryOrange,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const BuatAkunScreen()));
                          },
                          child: Text(
                            'Buat Akun',
                            style: alumniSansBold.copyWith(
                              fontSize: 20, 
                              color: Colors.white
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: AppColors.textBlack,
                                ),
                                children: [
                                  TextSpan(
                                    text: "PT IKE Bank Indonesia ", 
                                    style: alumniSansBold, 
                                  ),
                                  const TextSpan(
                                    text: "berizin dan diawasi oleh Otoritas Jasa Keuangan",
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 3), 
                          
                          const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "(OJK) dan Bank Indonesia, serta merupakan peserta penjaminan LPS.",
                              style: TextStyle(
                                fontSize: 18,
                                color: AppColors.textBlack,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem({
    required String assetPath,
    required String text,
  }) {
    bool isSvg = assetPath.toLowerCase().endsWith('.svg');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24, 
          height: 24,
          child: isSvg
              ? SvgPicture.asset(assetPath, fit: BoxFit.contain)
              : Image.asset(assetPath, fit: BoxFit.contain),
        ),
        
        const SizedBox(width: 12),
        
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.w500,
              color: AppColors.textBlack,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}