import 'package:flutter/material.dart';
import '../../auth/login/login_page.dart';
import '../../auth/signin.dart';
import 'laporan_keuangan_screen.dart';
import 'pengaturan_screen.dart';
import 'about_us_screen.dart';
import '../../home/layanan/bantuan_cs_screen.dart';
import '../../../api/auth.dart';

class LainnyaScreen extends StatelessWidget {
  const LainnyaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextStyle titleStyle = const TextStyle(
      fontWeight: FontWeight.w800,
      fontFamily: 'AlumniSans',
      fontSize: 32,
      color: Colors.black,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8F5),
        elevation: 0,
        title: Text("Lainnya", style: titleStyle),
        centerTitle: false,
        toolbarHeight: 80,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 8),

            // 1. Laporan Keuangan
            _buildMenuItem(
              icon: Icons.assessment,
              title: "Laporan Keuangan",
              subtitle: "Klik disini untuk melihat",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LaporanKeuanganScreen(),
                  ),
                );
              },
            ),

            // 2. Pengaturan
            _buildMenuItem(
              icon: Icons.settings,
              title: "Pengaturan",
              subtitle: "Lihat lebih lanjut tentang pengaturan",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PengaturanScreen(),
                  ),
                );
              },
            ),

            // 4. Bantuan/Help
            _buildMenuItem(
              icon: Icons.help_outline,
              title: "Bantuan/Help",
              subtitle: "Ada yang bisa kami bantu?",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BantuanCsScreen()),
                );
              },
            ),

            _buildMenuItem(
              icon: Icons.phone,
              title: "About Us",
              subtitle: "Info tentang Kami",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutUsScreen(),
                  ),
                );
              },
            ),

            _buildMenuItem(
              icon: Icons.person,
              title: "Ganti akun",
              onTap: () async {
                final lastEmail = await AuthService.getLastEmail();

                try {
                  await AuthService.logout();
                } catch (_) {
                  // Continue navigation even when logout API fails.
                }

                if (!context.mounted) {
                  return;
                }

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(
                      key: UniqueKey(),
                      prefilledEmail: lastEmail,
                    ),
                  ),
                  (Route<dynamic> route) => false,
                );
              },
            ),

            _buildMenuItem(
              icon: Icons.logout,
              title: "Keluar dari akun",
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => SignIn()),
                  (Route<dynamic> route) => false,
                );
              },
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFFFF7F00), size: 35),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 0.5),
                        Text(
                          subtitle,
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                      ],
                    ],
                  ),
                ),

                const Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFFFF7F00),
                  size: 20,
                ),
              ],
            ),
          ),
          const Divider(
            height: 1,
            thickness: 1,
            color: Color.fromARGB(255, 71, 71, 71),
            indent: 24,
            endIndent: 24,
          ),
        ],
      ),
    );
  }
}
