import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; 
import 'rekening_baru_screen.dart';
import 'riwayat_rekening_screen.dart';

class TransferDanaScreen extends StatelessWidget {
  const TransferDanaScreen({super.key});

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
          "Transfer Dana",
          style: TextStyle(
            fontFamily: 'AlumniSans',
            fontWeight: FontWeight.w800,
            fontSize: 24,
            color: Colors.black,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white, 
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Transfer",
              style: TextStyle(
                fontFamily: 'AlumniSans',
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 _buildTransferMenu(
               label: "Rekening Baru",
               iconWidget: Stack(
                 clipBehavior: Clip.none,
                 children: [
                   SvgPicture.asset('assets/images/bank.svg', height: 36, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
                   const Positioned(top: -4, right: -10, child: Icon(Icons.add, color: Colors.white, size: 22)), 
                 ],
               ),
               onTap: () {
                 Navigator.push(
                   context,
                   MaterialPageRoute(builder: (context) => const RekeningBaruScreen()),
                 );
               },
             ),
                
                const SizedBox(width: 24), 
                
                _buildTransferMenu(
                  label: "Riwayat Rekening",
                  iconWidget: SvgPicture.asset(
                    'assets/images/riwayat.svg',
                    height: 36,
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RiwayatRekeningScreen()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransferMenu({required String label, required Widget iconWidget, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              color: const Color(0x80F69500), 
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: iconWidget,
          ),
          const SizedBox(height: 2), 
          SizedBox(
            width: 90,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14, 
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}