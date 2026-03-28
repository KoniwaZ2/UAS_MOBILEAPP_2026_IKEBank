import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:share_plus/share_plus.dart'; 
import 'package:flutter_svg/flutter_svg.dart';

class UndangTemanScreen extends StatelessWidget {
  const UndangTemanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextStyle alumniSansBold = const TextStyle(
      fontWeight: FontWeight.w800, 
      fontFamily: 'AlumniSans',
    );

    // Dummy kode referral (Nanti ini didapat dari Backend)
    const String kodeReferral = "JACMA92F";

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
          "Undang Teman",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22, fontFamily: 'AlumniSans'),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Stack(
                  children: [
                    Container(
                      height: 180,
                      width: double.infinity,
                      color: const Color(0xFFFF7F00),
                    ),
                    
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Total bonus referral", style: alumniSansBold.copyWith(fontSize: 24, color: Colors.white)),
                                  Text("Rp60.000", style: alumniSansBold.copyWith(fontSize: 36, color: Colors.white, height: 1.0)),
                                  const SizedBox(height: 4),
                                  const Text("Maks. Rp500.000", style: TextStyle(fontSize: 16, color: Colors.white)),
                                ],
                              ),
                              SvgPicture.asset(
                                'assets/images/teman.svg', 
                                height: 70,
                              ), 
                            ],
                          ),
                        ),

                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
                            ],
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              const Text("Kode referral kamu", style: TextStyle(fontSize: 16, color: Colors.black87)),
                              const SizedBox(height: 8),
                              
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    kodeReferral, 
                                    style: alumniSansBold.copyWith(fontSize: 36, color: const Color(0xFF01008A), letterSpacing: 1.5)
                                  ),
                                  const SizedBox(width: 12),
                                  GestureDetector(
                                    onTap: () {
                                      Clipboard.setData(const ClipboardData(text: kodeReferral));
                                    },
                                    child: const Icon(Icons.copy, color: Color(0xFFFF7F00), size: 28),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              
                              Divider(color: Colors.grey.shade300, height: 1, thickness: 1),
                              
                              InkWell(
                                onTap: () {
                                  // TODO: Navigasi ke halaman detail siapa saja yang sudah diundang
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Melihat daftar teman...")));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Text("Teman undangan", style: TextStyle(fontSize: 16, color: Colors.black87)),
                                      Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black87),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Cara kerja", style: alumniSansBold.copyWith(fontSize: 20, color: Colors.black)),
                              const SizedBox(height: 1),
                              _buildInstructionRow("1", "Tap tombol Ajak Teman di bawah untuk membagikan kode referral kamu ke temanmu."),
                              _buildInstructionRow("2", "Pastikan temanmu sudah men-download aplikasi IKE Bank dan memasukkan kode referral kamu saat dia membuka akun."),
                              _buildInstructionRow("3", "Temanmu harus mempertahankan dana minimum Rp1.000.000 selama 14 hari di Saku Utama. Dana harus ditambahkan paling lama 1 hari setelah membuka akun."),
                              _buildInstructionRow("4", "Jika dia berhasil, kamu akan mendapatkan Rp20.000 dan temanmu akan mendapatkan Rp30.000."),
                              _buildInstructionRow("5", "Bonus dana maksimum yang bisa kamu dapatkan adalah Rp500.000."),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: const BoxDecoration(color: Colors.white),
              child: SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    final String shareMessage = "Hei! Buka rekening di IKE Bank lebih cuan pakai kode referral saya: *$kodeReferral*. Yuk download sekarang dan dapatkan bonus saldonya!";
                    Share.share(shareMessage);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7F00), 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    elevation: 0,
                  ),
                  child: const Text("Ajak Teman", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionRow(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0.1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$number. ", style: const TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text, 
              style: const TextStyle(fontSize: 18, color: Colors.black, height: 1.4)
            ),
          ),
        ],
      ),
    );
  }
}