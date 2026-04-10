import 'package:flutter/material.dart';
import '../../../api/banking.dart';

class BuatSakuFormScreen extends StatefulWidget {
  final String type;
  const BuatSakuFormScreen({super.key, required this.type});

  @override
  State<BuatSakuFormScreen> createState() => _BuatSakuFormScreenState();
}

class _BuatSakuFormScreenState extends State<BuatSakuFormScreen> {
  late final TextEditingController _nameController;
  bool _isSubmitting = false;

  final TextStyle alumniSansBold = const TextStyle(
    fontWeight: FontWeight.w800,
    fontFamily: 'AlumniSans',
  );

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submitBuatSaku() async {
    final namaSaku = _nameController.text.trim().isEmpty
        ? 'Saku Baru'
        : _nameController.text.trim();

    setState(() {
      _isSubmitting = true;
    });

    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Memproses pembuatan saku...')),
        );
      }

      await BankingService.tambahSaku(
        sakuName: namaSaku,
        category: widget.type.toLowerCase(),
        isPrimary: false,
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(context, <String, String>{
        'title': namaSaku,
        'amount': 'Rp0',
        'imageAsset':
            'assets/images/tabung.png', // Harus benerin sesuai dengan kategori
        'type': widget.type,
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membuat saku. Silakan coba lagi.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: const Color(0xFFFF7F00),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Saku ${widget.type}",
          style: alumniSansBold.copyWith(
            color: Colors.white,
            fontSize: 32,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),

                      Center(
                        child: Container(
                          width: 250,
                          height: 180,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD9D9D9),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.all(24),
                          child: Image.asset(
                            'assets/images/tabung.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      const SizedBox(height: 150),

                      Text(
                        "Kasih nama buat Saku ini",
                        style: alumniSansBold.copyWith(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),

                      Container(
                        height: 55,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9D9D9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.centerLeft,
                        child: TextField(
                          controller: _nameController,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            hintText: "Contoh: Tabungan Liburan",
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                          FocusScope.of(context).unfocus();
                          await _submitBuatSaku();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC085),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _isSubmitting ? 'Membuat...' : 'Buat Saku',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
