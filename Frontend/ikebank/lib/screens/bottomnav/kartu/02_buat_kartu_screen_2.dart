import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '03_buat_kartu_screen_3.dart';
import '04_pin_screen.dart';

class BuatKartuScreen2 extends StatefulWidget {
  const BuatKartuScreen2({super.key});

  @override
  State<BuatKartuScreen2> createState() => _BuatKartuScreen2State();
}

class _BuatKartuScreen2State extends State<BuatKartuScreen2> {
  final TextEditingController namaController = TextEditingController();

  String selectedSaku = "Saku Utama";
  String saldo = "Rp 3.000.000";
  String alamatUser = "Belum diisi";

  void showSakuPopup() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          decoration: const BoxDecoration(
            color: Color(0xFFF5F5F5),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Sumber dana",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // SAKU UTAMA
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedSaku = "Saku Utama";
                    saldo = "Rp 3.000.000";
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBD7C3),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Image.asset(
                            "assets/images/IKEHome.png",
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Saku Utama",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Rp 3.000.000",
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // UANG BELANJA
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedSaku = "Uang Belanja";
                    saldo = "Rp 5.000.000";
                  });
                  Navigator.pop(context);
                },
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBD7C3),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 55,
                            height: 55,
                            decoration: BoxDecoration(
                              color: Colors.purple[100],
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: SvgPicture.asset(
                                "assets/images/Uangbelanja.svg",
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Uang Belanja",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Rp 5.000.000",
                                style: TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(18),
                            bottomLeft: Radius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "Transaksi",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget boxField({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2C),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
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
                      "Buat Kartu Baru",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset("assets/images/debit.png"),
                    ),
                    const SizedBox(height: 20),

                    boxField(
                      child: TextField(
                        controller: namaController,
                        style: const TextStyle(fontSize: 22),
                        decoration: const InputDecoration(
                          hintText: "Nama yang dicetak di kartu",
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    GestureDetector(
                      onTap: showSakuPopup,
                      child: boxField(
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Saku yang terhubung",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black, 
                                  ),
                                ),

                                Text(
                                  selectedSaku,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  saldo,
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black, 
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: showSakuPopup,
                              child: const Text(
                                "Ganti",
                                style: TextStyle(
                                  color: Color(0xFFFF7F00),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const BuatKartuScreen3(),
                          ),
                        );

                        if (result != null) {
                          setState(() {
                            alamatUser = result["alamat"];
                          });
                        }
                      },
                      child: boxField(
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Alamat Pengiriman Kartu",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black, 
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  alamatUser,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(Icons.arrow_forward_ios,
                                size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // BUTTON
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF7F00),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PinScreen(nama: namaController.text),
                        ),
                      );
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