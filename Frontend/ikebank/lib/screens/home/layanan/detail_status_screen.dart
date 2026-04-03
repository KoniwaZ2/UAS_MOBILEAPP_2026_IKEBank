import 'package:flutter/material.dart';

class DetailStatusScreen extends StatelessWidget {
  const DetailStatusScreen({super.key});

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
        titleSpacing: 0, 
        title: const Text(
          "Apa itu Status Keuangan?",
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
              padding: const EdgeInsets.fromLTRB(20.0, 1.0, 20.0, 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  const Text(
                    "Saat ini:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 6),
                  
                  _buildStatusCard(
                    title: "Status Keuangan Kamu Saat Ini",
                    statusText: "Optimal",
                    statusColor: const Color(0xFF00B14F), 
                    description: "Pengeluaran kamu berada di level 26-50%",
                  ),
                  
                  const SizedBox(height: 20), 
                  
                  const Text(
                    "Tipe-Tipe Status Keuangan versi IKE Bank",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 12),

                  _buildStatusCard(
                    title: "Status Keuangan",
                    statusText: "Sangat Optimal",
                    statusColor: const Color(0xFF008000), 
                    description: "Pengeluaran kamu berada di level 0-25%",
                  ),
                  const SizedBox(height: 12),
                  
                  _buildStatusCard(
                    title: "Status Keuangan",
                    statusText: "Optimal",
                    statusColor: const Color(0xFF00B14F), 
                    description: "Pengeluaran kamu berada di level 26-50%",
                  ),
                  const SizedBox(height: 12),
                  
                  _buildStatusCard(
                    title: "Status Keuangan",
                    statusText: "Cukup Optimal",
                    statusColor: const Color(0xFFE8D000), 
                    description: "Pengeluaran kamu berada di level 51-75%",
                  ),
                  const SizedBox(height: 12),
                  
                  _buildStatusCard(
                    title: "Status Keuangan",
                    statusText: "Belum Optimal",
                    statusColor: Colors.red, 
                    description: "Pengeluaran kamu berada di atas 75%",
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

  Widget _buildStatusCard({
    required String title,
    required String statusText,
    required Color statusColor,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4.0), 
            child: Image.asset(
              'assets/images/status.png',
              width: 45,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 40, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, color: Colors.black)),
                const SizedBox(height: 0.1),
                Text(statusText, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: statusColor)),
                const SizedBox(height: 0.1),
                Text(description, style: const TextStyle(fontSize: 18, color: Colors.black)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}