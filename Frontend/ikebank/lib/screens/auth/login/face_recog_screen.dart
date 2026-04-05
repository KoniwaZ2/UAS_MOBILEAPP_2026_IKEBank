import 'package:flutter/material.dart';
import '../../../core/colors.dart';
import 'login_page.dart';
import '../register/buat_pass_screen.dart';

class FaceRecogScreen extends StatelessWidget {
  // 1. Tangkap sinyal dari Verifikasi Wajah
  final bool isFromRegister;
  final bool isFromCS;

  // 2. Beri default false
  const FaceRecogScreen({super.key, 
  this.isFromRegister = false,
  this.isFromCS = false, 
  });

  @override
  Widget build(BuildContext context) {
    const TextStyle alumniSansBold = TextStyle(fontWeight: FontWeight.w700);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textBlack, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            // TEKS INSTRUKSI 
            Text(
              "Buka Mulutmu",
              style: alumniSansBold.copyWith(
                fontSize: 32,
                color: AppColors.textBlack,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 60),

            // WADAH KAMERA (DUMMY FACE)
            GestureDetector(
              onTap: () {
                // LOGIKA PERCABANGAN TIGA JALUR
                if (isFromCS) {
                  // JIKA DARI CS: Cukup kembali (pop) ke halaman chat!
                  Navigator.pop(context);
                } else if (isFromRegister) {
                  // JIKA DARI REGISTER: Lari ke Buat Password!
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => const BuatPassScreen() 
                    )
                  );
                } else {
                  // JIKA DARI LOGIN: Lari ke halaman Login
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const LoginPage())
                  );
                }
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Lingkaran luar (Simulasi garis pinggir seperti di Figma)
                  Container(
                    width: MediaQuery.of(context).size.width * 0.85, 
                    height: MediaQuery.of(context).size.width * 0.85,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.75, 
                    height: MediaQuery.of(context).size.width * 0.75,
                    decoration: const BoxDecoration(
                      color: Colors.grey, 
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person,
                        size: 200,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100), 
          ],
        ),
      ),
    );
  }
}