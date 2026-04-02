import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'dibantu@ikebank.co.id',
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      debugPrint("Gagal membuka aplikasi email.");
    }
  }

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
          "Tentang Kami",
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Image.asset('assets/images/IKEBank.png', fit: BoxFit.contain), 
              ),
              const SizedBox(height: 24),

              Text(
                "Buka seluruh potensimu dan mulailah dengan\nIKE Bank. Bank digital yang didesain untuk\nsemua hal hebat yang kamu lakukan.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey.shade800, height: 1.4),
              ),
              const SizedBox(height: 32),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Informasi Detail",
                  style: TextStyle(
                    fontFamily: 'AlumniSans',
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              _buildContactBox(icon: Icons.phone, text: "+6267 676767 6969"),
              _buildContactBox(icon: Icons.phone, text: "1500678"),
              _buildContactBox(
                icon: Icons.mail, 
                text: "dibantu@ikebank.co.id", 
                isLink: true, 
                onTap: _launchEmail, 
              ),
              _buildContactBox(icon: Icons.language, text: "https://www.ikebank.co.id/"),
              _buildContactBox(icon: Icons.camera_alt, text: "ikebank"), 

              const SizedBox(height: 40),

              const Text(
                "Versi 1.0",
                style: TextStyle(
                  color: Colors.blue, 
                  fontWeight: FontWeight.bold, 
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactBox({required IconData icon, required String text, bool isLink = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEAD1), 
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFFF7F00), size: 28), 
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  decoration: isLink ? TextDecoration.underline : TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 