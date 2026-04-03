import 'package:flutter/material.dart';

class RiwayatCashFlowScreen extends StatelessWidget {
  const RiwayatCashFlowScreen({super.key});

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
          "Riwayat Cash Flow",
          style: TextStyle(
            fontFamily: 'AlumniSans',
            fontWeight: FontWeight.w800,
            fontSize: 24,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 20.0),
          child: Column(
            children: [
              _buildHistoryCard(
                monthYear: "Januari 2026",
                statusText: "Optimal",
                statusColor: const Color(0xFF00B14F),
                pemasukkan: "+Rp 50.057.863",
                pengeluaran: "-Rp 12.837.678",
              ),
              const SizedBox(height: 28),
              _buildHistoryCard(
                monthYear: "Desember 2025",
                statusText: "Sangat Optimal",
                statusColor: const Color(0xFF008000),
                pemasukkan: "+Rp 25.000.000",
                pengeluaran: "-Rp 2.000.000",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard({
    required String monthYear,
    required String statusText,
    required Color statusColor,
    required String pemasukkan,
    required String pengeluaran,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade400, width: 1.5),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
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
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Status Keuangan $monthYear", style: const TextStyle(fontSize: 18, color: Colors.black)),
                      const SizedBox(height: 2),
                      Text(statusText, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: statusColor)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            decoration: const BoxDecoration(
              color: Color(0x1AFF7F00), 
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Pemasukkan", style: TextStyle(fontSize: 18, color: Colors.black)),
                    Text(
                      pemasukkan, 
                      style: const TextStyle(fontFamily: 'AlumniSans', fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFFFF7F00)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Pengeluaran", style: TextStyle(fontSize: 18, color: Colors.black)),
                    Text(
                      pengeluaran, 
                      style: const TextStyle(fontFamily: 'AlumniSans', fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFFFF7F00)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}