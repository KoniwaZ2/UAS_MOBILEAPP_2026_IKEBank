import 'package:flutter/material.dart';
import 'transfer_riwayat_screen.dart'; 

class RiwayatRekeningScreen extends StatelessWidget {
  const RiwayatRekeningScreen({super.key});

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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Riwayat Rekening",
              style: TextStyle(
                fontFamily: 'AlumniSans',
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black87, width: 1), 
                ),
                child: ListView(
                  padding: EdgeInsets.zero,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildRekeningItem("Ivan Ibrahim", "10095324564", context),

                    _buildRekeningItem("Kelvin Kian Tanto", "10045322459", context),

                    _buildRekeningItem("Ericson Wen", "10024509271", context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRekeningItem(String nama, String nomorRekening, BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransferRiwayatScreen(
              namaPenerima: nama,
              nomorRekening: nomorRekening,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0), 
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300), 
              ),
              alignment: Alignment.center,
              child: Image.asset(
                'assets/images/IKEHome.png',
                width: 50, 
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nama,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "IKE Bank: $nomorRekening",
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}