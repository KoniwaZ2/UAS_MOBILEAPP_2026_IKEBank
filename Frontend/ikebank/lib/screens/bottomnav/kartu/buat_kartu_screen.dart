import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ikebank/screens/bottomnav/kartu/01.1_saldo_rata_rata.dart';

import '02_buat_kartu_screen_2.dart';

class BuatKartuScreen extends StatelessWidget {
  const BuatKartuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextStyle alumniSansBold = const TextStyle(
      fontWeight: FontWeight.w800, 
      fontFamily: 'AlumniSans',
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 40.0), 
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFCA96).withOpacity(0.5), 
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  border: Border(
                    left: BorderSide(color: Colors.black, width: 1.0),
                    right: BorderSide(color: Colors.black, width: 1.0),
                    bottom: BorderSide(color: Colors.black, width: 1.0),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 12, bottom: 28, left: 4, right: 4), 
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF7F00), 
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(40), 
                          bottomRight: Radius.circular(40),
                        ),
                      ),
                      child: Center(
                        child: Transform.scale(
                          scale: 1.20, 
                          child: Image.asset(
                            'assets/images/debit.png', 
                            width: double.infinity, 
                            fit: BoxFit.fitWidth, 
                          ),
                        ),
                      ),
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Biaya pembuatan kartu:", 
                                style: TextStyle(fontSize: 13, color: Colors.black87)
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Rp 50.000", 
                                style: alumniSansBold.copyWith(fontSize: 32, color: const Color(0xFFFF7F00), height: 1.1)
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const BuatKartuScreen2(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF7F00),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              elevation: 0,
                            ),
                            child: const Text(
                              "Buat kartu", 
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SaldoRataRataScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFCA96).withOpacity(0.1), 
                    borderRadius: BorderRadius.circular(30), 
                    border: Border.all(color: Colors.black, width: 1.2),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/images/kartu.svg',
                        colorFilter: const ColorFilter.mode(Color(0xFFFF7F00), BlendMode.srcIn),
                        height: 24,
                        width: 24,
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          "Mau kartu debit gratis? Gini caranya!",
                          style: TextStyle(color: Color(0xFFFF7F00), fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      const Icon(Icons.arrow_forward, color: Color(0xFFFF7F00)), 
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.black, width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Keuntungan punya Kartu Debit IKE Bank:",
                      style: TextStyle(color: Color(0xFFFF7F00), fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    
                    _buildBenefitItem(svgPath: 'assets/images/uang.svg', text: "Tarik tunai di ATM mana pun"),
                    const SizedBox(height: 20),
                    _buildBenefitItem(svgPath: 'assets/images/kunci.svg', text: "Kunci dan blokir kartu lewat aplikasi"),
                    const SizedBox(height: 20),
                    _buildBenefitItem(svgPath: 'assets/images/arrow.svg', text: "Terintegrasi dengan sistem AI kami"),
                  ],
                ),
              ),
              
              const SizedBox(height: 40), 
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem({required String svgPath, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          svgPath,
          colorFilter: const ColorFilter.mode(Color(0xFFFF7F00), BlendMode.srcIn),
          height: 32, 
          width: 32,  
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Color(0xFFFF7F00), fontSize: 15, fontWeight: FontWeight.w500, height: 1.3),
          ),
        ),
      ],
    );
  }
}