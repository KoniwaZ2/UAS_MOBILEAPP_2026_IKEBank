import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '09_registrasi_pin_detail_screen.dart';
import '09_registrasi_pin_block_screen.dart';
import '12_pin_blokir_permanen.dart';
import '13_limit_harian_screen.dart';

class DetailKartuScreen extends StatelessWidget {
  const DetailKartuScreen({super.key});

  static const primaryColor = Color(0xFFFF7F00);
  static const cardColor = Color(0xFFF4E3D3);

  Widget menuItem({
    required String title,
    VoidCallback? onTap,
    String? trailingText,
    bool showArrow = true,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            Row(
              children: [
                if (trailingText != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text(
                      trailingText,
                      style: const TextStyle(
                        fontSize: 15,
                        color: primaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                if (showArrow)
                  SvgPicture.asset(
                    "assets/images/ep_right.svg",
                    width: 18,
                    colorFilter: const ColorFilter.mode(
                      primaryColor,
                      BlendMode.srcIn,
                    ),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),

              // CARD
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.asset(
                    "assets/images/debit.png",
                    width: double.infinity,
                    height: 280,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 22),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // ✅ DETAIL (PIN LAMA)
                    menuItem(
                      title: "Lihat detail kartu",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const RegistrasiPinDetailScreen(),
                          ),
                        );
                      },
                    ),
                    
                    menuItem(
                      title: "Blokir kartu sementara",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const RegistrasiPinBlockScreen(),
                          ),
                        );
                      },
                    ),

                    // BLOKIR PERMANEN
                    menuItem(
                      title: "Blokir kartu permanen",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const PinBlokirPermanenScreen(),
                          ),
                        );
                      },
                    ),

                    // LIMIT HARIAN
                    menuItem(
                      title: "Limit harian",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const LimitHarianScreen(),
                          ),
                        );
                      },
                    ),

                    // UBAH PIN
                    menuItem(
                      title: "Ubah PIN Kartu",
                      trailingText: "Bantuan CS",
                      showArrow: false,
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}