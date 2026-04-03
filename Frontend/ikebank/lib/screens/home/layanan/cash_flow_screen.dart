import 'package:flutter/material.dart';
import 'detail_status_screen.dart';
import 'riwayat_cash_flow_screen.dart'; 

class CashFlowScreen extends StatelessWidget {
  const CashFlowScreen({super.key});

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
          "Cash Flow",
          style: TextStyle(
            fontFamily: 'AlumniSans',
            fontWeight: FontWeight.w800,
            fontSize: 24,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: 155, 
              color: const Color(0x1AFFCA96), 
            ),
            
            SingleChildScrollView(
              padding: const EdgeInsets.all(20.0), 
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade400, width: 1.5),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/status.png',
                                width: 50, 
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 40, color: Colors.grey),
                              ),
                              const SizedBox(width: 12),
                              
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text("Status Keuangan", style: TextStyle(fontSize: 20, color: Colors.black)),
                                    SizedBox(height: 0.1),
                                    Text("Optimal", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                                  ],
                                ),
                              ),
                              
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const DetailStatusScreen()),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0x80F69500), 
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: const [
                                      Text("Detail", style: TextStyle(fontSize: 12, color: Color(0xFFFF7F00), fontWeight: FontWeight.bold)),
                                      SizedBox(width: 4),
                                      Icon(Icons.arrow_forward, color: Color(0xFFFF7F00), size: 14),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RiwayatCashFlowScreen()),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: const BoxDecoration(
                              color: Color(0x1AFF7F00), 
                              borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text("Riwayat Status Keuangan", style: TextStyle(fontSize: 16, color: Colors.black87)),
                                Icon(Icons.arrow_forward, color: Color(0xFFFF7F00), size: 18),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40), 

                  _buildInfoCard(
                    title: "Transaksi Terbanyak Bulan Lalu",
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("Makanan & Minuman", style: TextStyle(fontSize: 18, color: Colors.black87)),
                        Text(
                          "-Rp 12.837.678", 
                          style: TextStyle(fontFamily: 'AlumniSans', fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFFFF7F00)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildInfoCard(
                    title: "Kamu Berhasil Menabung",
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("Saku Celengan", style: TextStyle(fontSize: 18, color: Colors.black87)),
                        Text(
                          "+ Rp 1.532.981", 
                          style: TextStyle(fontFamily: 'AlumniSans', fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFFFF7F00)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildInfoCard(
                    title: "Perolehan Bungamu",
                    content: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text("Bunga Tabungan", style: TextStyle(fontSize: 18, color: Colors.black)),
                            Text(
                              "+ Rp 132.247", 
                              style: TextStyle(fontFamily: 'AlumniSans', fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFFFF7F00)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text("Bunga Deposito", style: TextStyle(fontSize: 18, color: Colors.black)),
                            Text(
                              "+ Rp 40.574.394", 
                              style: TextStyle(fontFamily: 'AlumniSans', fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFFFF7F00)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade400, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Nasihat IKE Bank",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Wah, keuangan kamu sebulan ini sudah optimal. Bulan ini kamu paling banyak transaksi di merchant Starbucks. Jangan lupa minggu ini kamu bisa masukin Rp 500.000 ke Saku Celengan ya!",
                          style: TextStyle(fontSize: 18, color: Colors.black, height: 1.4),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 0.5),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24), 
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required Widget content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28), 
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade400, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black), 
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }
}