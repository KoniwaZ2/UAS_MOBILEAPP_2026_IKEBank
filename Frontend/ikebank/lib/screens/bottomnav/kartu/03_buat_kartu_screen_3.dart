import 'package:flutter/material.dart';

class BuatKartuScreen3 extends StatefulWidget {
  const BuatKartuScreen3({super.key});

  @override
  State<BuatKartuScreen3> createState() => _BuatKartuScreen3State();
}

class _BuatKartuScreen3State extends State<BuatKartuScreen3> {
  final nama = TextEditingController();
  final nomor = TextEditingController();
  final alamat = TextEditingController();
  final provinsi = TextEditingController();
  final kota = TextEditingController();
  final kecamatan = TextEditingController();
  final kelurahan = TextEditingController();
  final kodepos = TextEditingController();

  Widget field(String hint, TextEditingController c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2C),

      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              color: const Color(0xFFFF7F00),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon:
                        const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Expanded(
                    child: Text(
                      "Alamat pengiriman kartu",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    field("Nama Penerima", nama),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "⚠ Sesuai nama yang terdaftar di sistem bank",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 18,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    field("Nomor penerima", nomor),
                    field("Alamat Lengkap", alamat),
                    field("Provinsi", provinsi),
                    field("Kota/Kabupaten", kota),
                    field("Kecamatan", kecamatan),
                    field("Kelurahan", kelurahan),
                    field("Kode Pos", kodepos),
                  ],
                ),
              ),
            ),

            // BUTTON
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                height: 65,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF7F00),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () {
                      Navigator.pop(context, {
                        "alamat":
                            "${alamat.text}, ${kecamatan.text}, ${kota.text}",
                      });
                    },
                    child: const Center(
                      child: Text(
                        "Lanjut",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}