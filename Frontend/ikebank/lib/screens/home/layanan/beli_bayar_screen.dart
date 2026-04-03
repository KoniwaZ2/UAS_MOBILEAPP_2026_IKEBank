import 'package:flutter/material.dart';
import '../saku_utama/transfer_dana_screen.dart'; 
import '../../bottomnav/qris/qris_screen.dart'; 

class BeliBayarScreen extends StatelessWidget {
  const BeliBayarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0x1AFFCA96), 
        elevation: 0,
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Beli & Bayar",
          style: TextStyle(
            fontFamily: 'AlumniSans',
            fontWeight: FontWeight.w800,
            fontSize: 24,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Transfer",
                style: TextStyle(
                  fontFamily: 'AlumniSans',
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              _buildMenuButton(
                iconWidget: const Icon(Icons.arrow_forward, color: Colors.white, size: 36),
                label: "Transfer Keluar",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TransferDanaScreen()),
                  );
                },
              ),

              const SizedBox(height: 32), 

              const Text(
                "QRIS",
                style: TextStyle(
                  fontFamily: 'AlumniSans',
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              _buildMenuButton(
                iconWidget: Image.asset(
                  'assets/images/Qris.png', 
                  width: 50, 
                  color: Colors.white, 
                ),
                label: "QRIS",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const QrisScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required Widget iconWidget,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, 
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0x80F69500), 
              borderRadius: BorderRadius.circular(20), 
            ),
            alignment: Alignment.center,
            child: iconWidget,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 18, color: Colors.black),
          ),
        ],
      ),
    );
  }
}