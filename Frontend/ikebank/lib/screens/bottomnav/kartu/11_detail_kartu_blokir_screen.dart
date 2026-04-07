import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '11.1_buka_blokir_sementara_screen.dart';
import '12_pin_blokir_permanen.dart';

class DetailKartuBlokirScreen extends StatelessWidget {
  const DetailKartuBlokirScreen({super.key});

  static const primaryColor = Color(0xFFFF7F00);
  static const cardColor = Color(0xFFF4E3D3);

  Widget menuItem({
    required String title,
    bool enabled = true,
    bool highlight = false,
    VoidCallback? onTap,
  }) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: highlight ? cardColor : Colors.grey[300],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SvgPicture.asset(
                "assets/images/ep_right.svg",
                width: 18,
                colorFilter: ColorFilter.mode(
                  highlight ? primaryColor : Colors.grey,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
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
              const SizedBox(height: 6),

              // CARD
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Image.asset(
                        "assets/images/debit.png",
                        width: double.infinity,
                        height: 280,
                        fit: BoxFit.cover,
                      ),
                    ),

                    Image.asset(
                      "assets/images/notavailable.png",
                      width: 320,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 2),

              // TITLE + DESC
              Transform.translate(
                offset: const Offset(0, -6),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Kartu tidak tersedia",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Kartumu sedang diblokir sementara, klik buka kartu untuk memulihkan kartumu",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // MENU
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    menuItem(
                      title: "Lihat detail kartu",
                      enabled: false,
                    ),

                    // 🔥 FIX FLOW DI SINI (INI YANG PENTING)
                    menuItem(
                      title: "Buka blokir kartu sementara",
                      highlight: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const BukaBlokirSementaraScreen(),
                          ),
                        );
                      },
                    ),

                    menuItem(
                    title: "Blokir kartu permanen",
                    highlight: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PinBlokirPermanenScreen(),
                        ),
                      );
                    },
                  ),
                    menuItem(
                      title: "Limit harian",
                      enabled: false,
                    ),

                    menuItem(
                      title: "Ubah PIN Kartu",
                      enabled: false,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}