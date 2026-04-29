import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LaporanKeuanganScreen extends StatefulWidget {
  const LaporanKeuanganScreen({super.key});

  @override
  State<LaporanKeuanganScreen> createState() => _LaporanKeuanganScreenState();
}

class _LaporanKeuanganScreenState extends State<LaporanKeuanganScreen> {
  int _selectedTab = 0;

  final TextStyle alumniSansBold = const TextStyle(
    fontWeight: FontWeight.w800, 
    fontFamily: 'AlumniSans',
  );

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
          "Laporan Keuangan",
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                children: [
                  _buildTabButton(title: "e-Statement", index: 0),
                  const SizedBox(width: 12),
                  _buildTabButton(title: "Pajak", index: 1),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _selectedTab == 0 
                    ? _buildEStatementContent() 
                    : _buildPajakContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton({required String title, required int index}) {
    bool isActive = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFF7F00) : const Color(0xFFF0F0F0), 
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildEStatementContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("E-Statement bulanan", style: alumniSansBold.copyWith(fontSize: 18, color: const Color(0xFFFF7F00))),
        const SizedBox(height: 2),
        RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 15, color: Colors.grey.shade800, height: 1.4),
            children: const [
              TextSpan(text: "Download e-Statement untuk memantau seluruh transaksi kamu. Password yang perlu kamu masukkan adalah tanggal lahirmu dalam format "),
              TextSpan(text: "DD-MM-YYYY.", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFF7F00),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: const Text(
                  "Kami hanya menampilkan e-Statement dari 12 bulan terakhir",
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        _buildYearSection(
          year: "2026",
          initiallyExpanded: true,
          months: [
            "Januari 2026",
          ],
        ),
        
        _buildYearSection(
          year: "2025",
          initiallyExpanded: false,
          months: [
            "Desember 2025",
            "November 2025",
            "Oktober 2025",
            "September 2025",
          ],
        ),
        
        const SizedBox(height: 40), 
      ],
    );
  }

  Widget _buildPajakContent() {
    return Column(
      children: [
        const SizedBox(height: 90), 
        
        Center(
          child: SvgPicture.asset(
            'assets/images/BoxPajak.svg', 
            height: 320, 
            fit: BoxFit.contain,
          ),
        ),
        
        const SizedBox(height: 40), 
        
        Center(
          child: SizedBox(
            width: 320, 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                Text(
                  "Dokumen pendukung\nlaporan SPT belum tersedia",
                  textAlign: TextAlign.left, 
                  style: alumniSansBold.copyWith(
                    fontSize: 22, 
                    color: Colors.black, 
                    height: 1.1, 
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  "Riwayat pajak akan tersedia setiap awal\ntahun",
                  textAlign: TextAlign.left, 
                  style: TextStyle(
                    fontSize: 20, 
                    color: Colors.grey.shade800, 
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 40), 
      ],
    );
  }

  Widget _buildYearSection({required String year, required bool initiallyExpanded, required List<String> months}) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.black),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        tilePadding: EdgeInsets.zero, 
        iconColor: const Color(0xFF01008A),
        collapsedIconColor: const Color(0xFF01008A),
        title: Text(
          year,
          style: alumniSansBold.copyWith(fontSize: 24, color: Colors.black),
        ),
        children: months.map((month) => _buildMonthItem(month)).toList(),
      ),
    );
  }

  Widget _buildMonthItem(String monthYear) {
    return InkWell(
      onTap: () {
        // TODO: Aksi download/buka PDF e-statement
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Mengunduh $monthYear...")));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEAD1), 
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.description, color: Colors.black87, size: 28),
            ),
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    monthYear,
                    style: const TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "e-Statement",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
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