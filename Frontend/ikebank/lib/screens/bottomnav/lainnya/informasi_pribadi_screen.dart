import 'package:flutter/material.dart';
import '../../home/layanan/bantuan_cs_screen.dart';
import '../../../api/auth.dart';

class InformasiPribadiScreen extends StatefulWidget {
  const InformasiPribadiScreen({super.key});

  @override
  State<InformasiPribadiScreen> createState() => _InformasiPribadiScreenState();
}

class _InformasiPribadiScreenState extends State<InformasiPribadiScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _userInfo;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final result = await AuthService.getProfile();
      setState(() {
        _userInfo = result;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat informasi pribadi';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle alumniSansBold = const TextStyle(
      fontWeight: FontWeight.w800,
      fontFamily: 'AlumniSans',
    );

    final result = _userInfo;
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
          "Informasi Pribadi",
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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 24.0,
                ),
                child: Column(
                  children: [
                    _buildInfoCard(
                      title: "Informasi Personal",
                      data: [
                        {
                          "label": "Nama",
                          "value": result != null && result["name"] != null
                              ? result["name"].toString()
                              : "-",
                        },
                        {
                          "label": "Alamat",
                          "value": result != null && result["alamat"] != null
                              ? result["alamat"].toString()
                              : "-",
                        },
                      ],
                      alumniSansStyle: alumniSansBold,
                    ),

                    _buildInfoCard(
                      title: "Informasi Kontak",
                      data: [
                        {
                          "label": "Alamat Email",
                          "value": result != null && result["email"] != null
                              ? result["email"].toString()
                              : "-",
                        },
                        {
                          "label": "Nomor Ponsel",
                          "value":
                              result != null && result["phone_number"] != null
                              ? result["phone_number"].toString()
                              : "-",
                        },
                      ],
                      alumniSansStyle: alumniSansBold,
                    ),

                    _buildInfoCard(
                      title: "Informasi Ketenagakerjaan",
                      data: [
                        {"label": "Tujuan Pembukaan Akun", "value": "Tabungan"},
                        {"label": "Sumber Dana", "value": "Gaji/Upah"},
                        {
                          "label": "Penghasilan per Bulan",
                          "value": "Rp4.500.000",
                        },
                        {"label": "Jabatan", "value": "Staff"},
                      ],
                      alumniSansStyle: alumniSansBold,
                    ),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              decoration: const BoxDecoration(color: Colors.white),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEAD1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Fitur Ubah Data belum tersedia"),
                          ),
                        );
                      },
                      child: const Text(
                        "Ubah Data",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BantuanCsScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Bantuan CS",
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFFFF7F00),
                          fontWeight: FontWeight.w500,
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
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Map<String, String>> data,
    required TextStyle alumniSansStyle,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black87, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: alumniSansStyle.copyWith(
              fontSize: 20,
              color: const Color(0xFFFF7F00),
            ),
          ),
          const SizedBox(height: 1),

          ...data.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['label']!,
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  const SizedBox(height: 0.5),
                  Text(
                    item['value']!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
