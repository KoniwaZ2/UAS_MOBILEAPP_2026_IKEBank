import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AturBatasRtolScreen extends StatefulWidget {
  const AturBatasRtolScreen({super.key});

  @override
  State<AturBatasRtolScreen> createState() => _AturBatasRtolScreenState();
}

class _AturBatasRtolScreenState extends State<AturBatasRtolScreen> {
  final TextEditingController _harianController = TextEditingController(text: "50.000.000");
  final TextEditingController _tunggalController = TextEditingController(text: "50.000.000");

  @override
  void dispose() {
    _harianController.dispose();
    _tunggalController.dispose();
    super.dispose();
  }

  // Fungsi validasi untuk Batas Harian (Maks 50 Juta)
  void _formatHarian(String value) {
    String cleanText = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanText.isEmpty) {
      _harianController.text = '';
      return;
    }
    int amount = int.parse(cleanText);
    if (amount > 50000000) amount = 50000000;

    String formatted = amount.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    _harianController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  // Fungsi validasi untuk Batas Transaksi Tunggal (Maks 50 Juta)
  void _formatTunggal(String value) {
    String cleanText = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanText.isEmpty) {
      _tunggalController.text = '';
      return;
    }
    int amount = int.parse(cleanText);
    if (amount > 50000000) amount = 50000000;

    String formatted = amount.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    _tunggalController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
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
          "Atur batas transaksi RTOL",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22, fontFamily: 'AlumniSans'),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Untuk keamanan akunmu, transaksi yang melebihi\njumlah ini akan otomatis dibatalkan.",
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade800, height: 1.4),
                    ),
                    const SizedBox(height: 24),

                    _buildInputSection(
                      title: "Batas harian",
                      controller: _harianController,
                      onChanged: _formatHarian,
                      maxText: "Batas maksimum: Rp50.000.000",
                    ),
                    const SizedBox(height: 10),

                    _buildInputSection(
                      title: "Batas transaksi tunggal",
                      controller: _tunggalController,
                      onChanged: _formatTunggal,
                      maxText: "Batas maksimum: Rp50.000.000",
                    ),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: const BoxDecoration(color: Colors.white),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Batas transaksi RTOL berhasil disimpan!")),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7F00), // Oranye
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    elevation: 0,
                  ),
                  child: const Text("Simpan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection({
    required String title,
    required TextEditingController controller,
    required Function(String) onChanged,
    required String maxText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5), 
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Text("Rupiah", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              
              const Spacer(), 
              
              const Text("Rp", style: TextStyle(fontSize: 16, color: Colors.black87)),
              SizedBox(
                width: 90, 
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: onChanged,
                  textAlign: TextAlign.right, 
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(maxText, style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
      ],
    );
  }
}