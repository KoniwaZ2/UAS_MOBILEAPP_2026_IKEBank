import 'package:flutter/material.dart';
import 'pengaturan_batas_transaksi_screen.dart';
import 'ubah_password_screen.dart';
import 'ubah_pin_screen.dart';
import 'informasi_pribadi_screen.dart';

class PengaturanScreen extends StatefulWidget {
  const PengaturanScreen({super.key});

  @override
  State<PengaturanScreen> createState() => _PengaturanScreenState();
}

class _PengaturanScreenState extends State<PengaturanScreen> {
  bool _isBiometricEnabled = true;

  final TextStyle alumniSansBold = const TextStyle(
    fontWeight: FontWeight.w800,
    fontFamily: 'AlumniSans',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF7F00),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Pengaturan",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            fontFamily: 'AlumniSans',
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          children: [
            _buildSectionTitle("Pengaturan Transaksi"),
            const SizedBox(height: 1),
            _buildMenuItem(
              title: "Pengaturan batas transaksi",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const PengaturanBatasTransaksiScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 4),
            const Padding(
              padding: EdgeInsets.only(left: 20.0),
              child: Divider(
                thickness: 1,
                color: Color.fromARGB(255, 177, 177, 177),
              ),
            ),
            const SizedBox(height: 8),

            _buildSectionTitle("Pengaturan Keamanan"),
            const SizedBox(height: 1),
            _buildMenuItem(
              title: "Ubah password",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UbahPasswordScreen(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              title: "Ubah PIN",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UbahPinScreen(),
                  ),
                );
              },
            ),
            _buildToggleItem(
              title: "Aktifkan login biometrik",
              value: _isBiometricEnabled,
              onChanged: (val) {
                setState(() {
                  _isBiometricEnabled = val;
                });
              },
            ),

            const SizedBox(height: 4),
            const Padding(
              padding: EdgeInsets.only(left: 20.0),
              child: Divider(
                thickness: 1,
                color: Color.fromARGB(255, 177, 177, 177),
              ),
            ),
            const SizedBox(height: 8),

            _buildSectionTitle("Pengaturan Lain"),
            const SizedBox(height: 4),
            _buildMenuItem(
              title: "Informasi pribadi",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InformasiPribadiScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: alumniSansBold.copyWith(fontSize: 20, color: Colors.black),
    );
  }

  Widget _buildMenuItem({required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0, top: 10.0, bottom: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, color: Colors.black87),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFFFF7F00),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, top: 2.0, bottom: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          Transform.scale(
            scale: 0.75,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: Colors.white,
              activeTrackColor: const Color(0xFFFFC085),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey.shade300,
            ),
          ),
        ],
      ),
    );
  }
}
