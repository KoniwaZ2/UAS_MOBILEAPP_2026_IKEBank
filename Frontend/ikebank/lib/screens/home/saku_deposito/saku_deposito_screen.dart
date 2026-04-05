import 'package:flutter/material.dart';
import '../../../widgets/deposito_offer_card.dart';
import '../../../widgets/portfolio_card.dart';
import 'deposito_special_screen.dart'; 
import 'deposito_detail_screen.dart';

class SakuDepositoScreen extends StatefulWidget {
  const SakuDepositoScreen({super.key});

  @override
  State<SakuDepositoScreen> createState() => _SakuDepositoScreenState();
}

class _SakuDepositoScreenState extends State<SakuDepositoScreen> {
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
          "Saku Deposito",
          style: TextStyle(fontFamily: 'AlumniSans', fontWeight: FontWeight.w800, fontSize: 24, color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: 80,
              color: const Color(0x1AFFCA96),
            ),

            SingleChildScrollView(
              padding: const EdgeInsets.only(top: 8.0, bottom: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Container(
                      width: double.infinity,
                      height: 90, 
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300, width: 1.5), 
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3)),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14.5), 
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text("Dana Deposito", style: TextStyle(fontSize: 20, color: Colors.black87)),
                                    SizedBox(height: 2),
                                    Text(
                                      "Rp 100.000.000",
                                      style: TextStyle(fontFamily: 'AlumniSans', fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFFFF7F00)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: 90,
                              height: double.infinity,
                              margin: const EdgeInsets.only(right: 20),
                              decoration: const BoxDecoration(
                                color: Color(0xFFCCCCFF),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(80),
                                  bottomRight: Radius.circular(80), 
                                ), 
                              ),
                              alignment: Alignment.center,
                              child: Image.asset('assets/images/deposito.png', width: 65, fit: BoxFit.contain),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24), 

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Penawaran Deposito",
                          style: TextStyle(fontFamily: 'AlumniSans', fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFFFF7F00)),
                        ),
                        const SizedBox(height: 12),

                        DepositoOfferCard(
                          isSpecial: true,
                          rate: "8.8% p.a",
                          tenor: "1 Bulan",
                          specialBadgeLeft: "Deposito Spesial CNY",
                          specialBadgeRight: "Sisa 100 Kuota",
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const DepositoSpesialScreen(
                              sukuBunga: 8.8, jangkaWaktuBulan: 1, isSpecial: true,
                            )));
                          },
                        ),

                        DepositoOfferCard(
                          rate: "7% p.a.",
                          tenor: "6 Bulan",
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const DepositoSpesialScreen(
                              sukuBunga: 7.0, jangkaWaktuBulan: 6, isSpecial: false,
                            )));
                          },
                        ),
                        DepositoOfferCard(
                          rate: "6% p.a.",
                          tenor: "3 Bulan",
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const DepositoSpesialScreen(
                              sukuBunga: 6.0, jangkaWaktuBulan: 3, isSpecial: false,
                            )));
                          },
                        ),
                        DepositoOfferCard(
                          rate: "5% p.a.",
                          tenor: "1 Bulan",
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const DepositoSpesialScreen(
                              sukuBunga: 5.0, jangkaWaktuBulan: 1, isSpecial: false,
                            )));
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 1),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      "Portofolio",
                      style: TextStyle(fontFamily: 'AlumniSans', fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFFFF7F00)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      children: [
                        PortfolioCard(
                          imageAsset: 'assets/images/deposito.png',
                          amount: "Rp 100.000.000",
                          title: "Deposito 1",
                          rate: "Bunga 8.80%p.a",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DepositoDetailScreen(
                                  namaDeposito: "Deposito 1", 
                                  jumlahPenempatan: 100000000,
                                  bungaSetelahPajak: 540055,
                                  tanggalMulai: "19 Februari 2026",
                                  tanggalJatuhTempo: "19 Maret 2026",
                                  isFromPortfolio: true, 
                                ),
                              ),
                            );
                          },
                        ),
                        PortfolioCard(
                          imageAsset: 'assets/images/deposito.png',
                          amount: "Rp 100.000.000",
                          title: "Deposito 2",
                          rate: "Bunga 8.80%p.a",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DepositoDetailScreen(
                                  namaDeposito: "Deposito 2",
                                  jumlahPenempatan: 100000000,
                                  bungaSetelahPajak: 540055,
                                  tanggalMulai: "19 Februari 2026",
                                  tanggalJatuhTempo: "19 Maret 2026",
                                  isFromPortfolio: true, 
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
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