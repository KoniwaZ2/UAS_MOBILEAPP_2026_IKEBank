import 'package:flutter/material.dart';
import 'pengaturan_batas_transaksi_screen.dart';
import 'ubah_password_screen.dart';
import 'ubah_pin_screen.dart';
import 'informasi_pribadi_screen.dart';
import 'package:local_auth/local_auth.dart';
import '../../../api/auth.dart';

class PengaturanScreen extends StatefulWidget {
  const PengaturanScreen({super.key});

  @override
  State<PengaturanScreen> createState() => _PengaturanScreenState();
}

class _PengaturanScreenState extends State<PengaturanScreen> {
  bool _isBiometricEnabled = false;
  bool _isLoadingBiometric = true;
  @override
  void initState() {
    super.initState();
    _fetchBiometricStatus();
  }

  Future<void> _fetchBiometricStatus() async {
    setState(() {
      _isLoadingBiometric = true;
    });
    try {
      final resp = await AuthService.biometricCheck(
        email: await AuthService.getLastEmail() ?? '',
      );
      // Asumsi response: { "biometric_login": true/false, ... }
      final enabled = resp is Map && resp['biometric_login'] == true;
      setState(() {
        _isBiometricEnabled = enabled;
        _isLoadingBiometric = false;
      });
    } catch (_) {
      setState(() {
        _isBiometricEnabled = false;
        _isLoadingBiometric = false;
      });
    }
  }

  Future<bool> _authenticateBiometric() async {
    try {
      final LocalAuthentication auth = LocalAuthentication();

      bool canCheckBiometrics = await auth.canCheckBiometrics;
      bool isSupported = await auth.isDeviceSupported();

      if (!canCheckBiometrics || !isSupported) {
        return false;
      }

      final availableBiometrics = await auth.getAvailableBiometrics();

      if (availableBiometrics.isEmpty) {
        return false;
      }

      return await auth.authenticate(
        localizedReason: 'Silakan autentikasi untuk mengaktifkan biometrik',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

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
            _isLoadingBiometric
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _buildToggleItem(
                    title: "Aktifkan login biometrik",
                    value: _isBiometricEnabled,
                    onChanged: (val) async {
                      setState(() {
                        _isLoadingBiometric = true;
                      });

                      // kalau user mau AKTIFKAN biometrik
                      if (val) {
                        bool success = await _authenticateBiometric();

                        if (!success) {
                          // gagal autentikasi → balikkan toggle
                          setState(() {
                            _isBiometricEnabled = false;
                            _isLoadingBiometric = false;
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Autentikasi biometrik gagal'),
                            ),
                          );
                          return;
                        }
                      }

                      // kalau sukses / atau user matikan
                      try {
                        await AuthService.biometricToogle(val);

                        setState(() {
                          _isBiometricEnabled = val;
                        });
                      } catch (e) {
                        // rollback kalau gagal API
                        setState(() {
                          _isBiometricEnabled = !val;
                        });
                      } finally {
                        setState(() {
                          _isLoadingBiometric = false;
                        });
                      }
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
              onChanged: _isLoadingBiometric ? null : onChanged,
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
