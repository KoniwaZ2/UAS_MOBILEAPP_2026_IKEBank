import 'package:flutter/material.dart';
import '../../../core/colors.dart';
import 'login_page.dart';

class FaceRecogScreen extends StatelessWidget {
  const FaceRecogScreen({super.key});

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
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => const LoginPage())
                );
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