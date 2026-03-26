import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PromoDetailScreen extends StatelessWidget {
  const PromoDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextStyle alumniSansBold = const TextStyle(
      fontWeight: FontWeight.w700,
      fontFamily: 'AlumniSans',
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 80, 
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, 
        
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 0.5),
            Image.asset(
              'assets/images/IKEHome.png',
              height: 45,
              fit: BoxFit.contain,
            ),
          ],
        ),
        centerTitle: false,
        
        actions: [
          IconButton(
            padding: const EdgeInsets.only(right: 20),
            icon: SvgPicture.asset(
              'assets/images/lainnya.svg',
              height: 40,
              colorFilter: const ColorFilter.mode(
                Colors.black,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 0.5),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ClipRRect(
                child: Image.asset(
                  'assets/images/promo.png',
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 150,
                    color: Colors.grey.shade300,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)), 
                border: Border.all(color: Colors.grey.shade300, width: 1.0), 
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4), 
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 40, color: Colors.black),
                  const SizedBox(height: 16),
                  
                  Text(
                    "IKE BANK",
                    style: alumniSansBold.copyWith(fontSize: 25, color: Colors.black),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Nikmati Bunga hingga 8.8% di IKE Bank!!!!",
                    style: TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                  const SizedBox(height: 32),

                  Text(
                    "Mekanisme",
                    style: alumniSansBold.copyWith(fontSize: 25, color: Colors.black),
                  ),
                  const SizedBox(height: 12),
                  _buildOrderedList([
                    "Deposito Dadakan akan muncul sewaktu-waktu secara dadakan pada aplikasi IKE Bank",
                    "Waktu tunggu Deposito Dadakan dapat berbeda, sesuai dengan ketentuan yang ditetapkan oleh Bank.",
                    "Suku Bunga Deposito Dadakan dapat berbeda, sesuai dengan ketentuan yang ditetapkan oleh Bank.",
                    "Suku Bunga pada program Deposito Dadakan juga bisa lebih tinggi daripada Deposito biasa.",
                    "Jumlah nasabah maksimum dalam Deposito Dadakan dapat berbeda, sesuai dengan ketentuan yang ditetapkan oleh Bank."
                  ]),
                  
                  const SizedBox(height: 32),

                  Text(
                    "Syarat & Ketentuan",
                    style: alumniSansBold.copyWith(fontSize: 25, color: Colors.black),
                  ),
                  const SizedBox(height: 12),
                  _buildOrderedList([
                    "Saldo simpanan nasabah yang terdapat di Bank baik dalam rekening maupun deposito berjangka dijamin berdasarkan ketentuan-ketentuan dalam Lembaga Penjamin Simpanan (“LPS”). Nasabah dengan ini mengetahui dan menyetujui bahwa sesuai ketentuan dan peraturan yang berlaku maka simpanan yang dijamin oleh LPS adalah terbatas pada simpanan yang meliputi nilai pokok simpanan dan bunga dengan jumlah maksimum tertentu serta dengan ketentuan maksimum tingkat suku bunga yang berlaku oleh LPS secara periodik.",
                    "Apabila simpanan Nasabah yang meliputi nilai pokok simpanan dan bunga melebihi jumlah maksimum simpanan yang dijamin oleh LPS dan/atau apabila Nasabah menerima bunga simpanan efektif dari Bank yang melebihi maksimum tingkat suku bunga penjaminan yang ditetapkan oleh LPS, maka simpanan Nasabah tersebut tidak termasuk dalam program penjaminan simpanan oleh LPS.",
                    "Bank setiap saat berhak untuk melakukan analisis terhadap kewajaran transaksi dan berhak untuk membatalkan transaksi dan/atau menghentikan program sewaktu-waktu apabila ditemukan indikasi penyalahgunaan ataupun kecurangan. Sanksi lain yang akan diberlakukan kepada Nasabah yang terlibat dalam indikasi kecurangan ataupun penyalahgunaan dapat mencakup, namun tidak terbatas pada, diskualifikasi dari Program, pembekuan atau pembatalan hak atas cashback yang diperoleh secara tidak sah, serta tindakan hukum sesuai dengan ketentuan yang berlaku.",
                    "Syarat dan ketentuan Deposito berlaku juga untuk Deposito Dadakan selain yang diatur khusus dalam Program ini."
                  ]),
                  
                  const SizedBox(height: 40), 
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderedList(List<String> items) {
    return Column(
      children: items.asMap().entries.map((entry) {
        int index = entry.key + 1;
        String text = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("$index. ", style: const TextStyle(fontSize: 15, color: Colors.black)),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 15, color: Colors.black, height: 1.0),
                  textAlign: TextAlign.justify,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}