import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ikebank/screens/home/saku_celengan/pindah_dana_celengan_screen.dart'; 
import '../../../widgets/action_square_button.dart';
import '../../../widgets/transaction_card.dart';
import '../../../widgets/filter_bottom_sheet.dart';
import 'tambah_dana_nabung_ai_screen.dart';
import '../promo_screen.dart';
import '../reward_screen.dart';
import '../../bottomnav/lainnya/undang_teman_screen.dart'; 
import '../saku_utama/riwayat_transaksi_screen.dart';

class SakuCelenganScreen extends StatefulWidget {
  const SakuCelenganScreen({super.key});

  @override
  State<SakuCelenganScreen> createState() => _SakuCelenganScreenState();
}

class _SakuCelenganScreenState extends State<SakuCelenganScreen> {
  bool isAutoIsi = true; 
  bool hasAddedFund = false; // TAMBAHAN: State untuk nge-cek apakah sudah tambah dana

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
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black, size: 28),
            onPressed: () {
              _showInfoSakuBottomSheet(context);
            },
          ),
        ],
        centerTitle: true,
        title: const Text(
          "Saku Celengan",
          style: TextStyle(fontFamily: 'AlumniSans', fontWeight: FontWeight.w800, fontSize: 24, color: Colors.black),
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
              padding: const EdgeInsets.only(top: 8.0, bottom: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.grey.shade300, width: 1.5),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width: 80, height: 80,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFD6CFFF),
                                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
                                    ),
                                    alignment: Alignment.center,
                                    child: Image.asset('assets/images/celengan.png', width: 65),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text("Total Dana", style: TextStyle(fontSize: 25, color: Colors.black87)),
                                  const SizedBox(height: 4),
                                  const Text(
                                    "Rp 8.000.000",
                                    style: TextStyle(fontFamily: 'AlumniSans', fontSize: 30, fontWeight: FontWeight.w900, color: Color(0xFFFF7F00)),
                                  ),
                                  const SizedBox(height: 1),
                                  
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Container(
                                              height: 12,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                                border: Border.all(color: const Color(0x4D000000), width: 1), 
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(9), 
                                                child: const LinearProgressIndicator(
                                                  value: 0.8, 
                                                  backgroundColor: Colors.white,
                                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF8C471)),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 1),
                                            const Text("10jt", style: TextStyle(fontSize: 18, color: Colors.black)),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      GestureDetector(
                                        onTap: () {
                                          _showPindahDanaBottomSheet(context);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: const Color(0x4DF69500),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            children: const [
                                              Icon(Icons.arrow_forward, color: Color(0xFFFF7F00), size: 16),
                                              SizedBox(width: 4),
                                              Text("Pindahkan Dana", style: TextStyle(color: Color(0xFFFF7F00), fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            
                            Positioned(
                              top: -1, right: -1,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 4),
                                decoration: const BoxDecoration(
                                  color: Color(0x80FF7F00),
                                  borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomLeft: Radius.circular(16)),
                                ),
                                child: const Text("10% p.a", style: TextStyle(color: const Color(0xFF01008A), fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        const Text(
                          "Cara Meningkatkan Dana Saku Celengan",
                          style: TextStyle(fontFamily: 'AlumniSans', fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFFFF7F00)),
                        ),
                        const SizedBox(height: 16),

                        // ==========================================
                        // CONTAINER NABUNG AI (YANG DIUBAH HANYA BAGIAN DALAM SINI)
                        // ==========================================
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade300, width: 1.5),
                          ),
                          child: Column(
                            children: [
                              const Text("Nabung AI", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
                              const SizedBox(height: 16),
                              
                              // LOGIKA PERUBAHAN TAMPILAN
                              if (!hasAddedFund) ...[
                                // BELUM DITAMBAH: Menampilkan nominal
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Expanded(
                                      child: Text(
                                        "Dana yang dapat kamu\nmasukkan ke Saku",
                                        style: TextStyle(fontSize: 18, color: Color(0xFFFF7F00)),
                                      ),
                                    ),
                                    const Text(
                                      "Rp 500.000",
                                      style: TextStyle(fontFamily: 'AlumniSans', fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFFFF7F00)),
                                    ),
                                  ],
                                ),
                              ] else ...[
                                // SUDAH DITAMBAH: Menampilkan Countdown
                                const Text(
                                  "Waktu untuk menabung kembali",
                                  style: TextStyle(fontSize: 14, color: Color(0xFFFF7F00)),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildCountdownBox("6", "Hari"),
                                    const SizedBox(width: 12),
                                    _buildCountdownBox("23", "Jam"),
                                    const SizedBox(width: 12),
                                    _buildCountdownBox("58", "Menit"),
                                    const SizedBox(width: 12),
                                    _buildCountdownBox("30", "Detik"),
                                  ],
                                ),
                              ],
                              
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: ElevatedButton(
                                      // JIKA SUDAH TAMBAH DANA, TOMBOL DISABLE (null)
                                      onPressed: hasAddedFund ? null : () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const TambahDanaNabungAiScreen()),
                                        ).then((result) {
                                          if (!mounted) return;
                                          // KETIKA KEMBALI DARI LAYAR TAMBAH DANA, UBAH STATE JADI TRUE
                                          // HANYA JIKA LAYAR TAMBAH DANA MENGEMBALIKAN `true`
                                          if (result == true) {
                                            setState(() {
                                              hasAddedFund = true;
                                            });
                                          }
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFF8C471),
                                        disabledBackgroundColor: Colors.grey.shade300, // Warna tombol saat disabled
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add, 
                                            // Warna icon jadi abu-abu kalau disable
                                            color: hasAddedFund ? Colors.grey.shade500 : const Color(0xFFFF7F00), 
                                            size: 20
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "Tambah dana ke Saku", 
                                            style: TextStyle(
                                              // Warna teks jadi abu-abu kalau disable
                                              color: hasAddedFund ? Colors.grey.shade500 : const Color(0xFFFF7F00), 
                                              fontWeight: FontWeight.bold
                                            )
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Row(
                                    children: [
                                      Switch(
                                        value: isAutoIsi,
                                        onChanged: (val) {
                                          setState(() { isAutoIsi = val; });
                                        },
                                        activeColor: Colors.white,
                                        activeTrackColor: const Color(0x80F69500),
                                      ),
                                      const Text("Auto isi", style: TextStyle(fontSize: 14, color: Color(0xFFFF7F00), fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // ==========================================
                        // BATAS CONTAINER NABUNG AI
                        // ==========================================

                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ActionSquareButton(
                              imageAsset: 'assets/images/cashback.png', 
                              label: "Promo Cashback", 
                              imageHeight: 32, 
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const PromoScreen()));
                              }
                            ),
                            ActionSquareButton(
                              imageAsset: 'assets/images/misi.png', 
                              label: "Ikut Misi", 
                              imageHeight: 45, 
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const RewardScreen()));
                              }
                            ),
                            ActionSquareButton(
                              imageAsset: 'assets/images/teman3.png', 
                              label: "Undang Teman", 
                              imageHeight: 45, 
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const UndangTemanScreen()));
                              }
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),

                  Divider(color: Colors.grey.shade400, thickness: 1.5, height: 1),
                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Sabtu, 31 Januari 2026",
                              style: TextStyle(fontFamily: 'AlumniSans', fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFFFF7F00)),
                            ),
                            GestureDetector(
                              onTap: () {
                                showFilterBottomSheet(context); 
                              },
                              child: SvgPicture.asset(
                                'assets/images/history.svg',
                                width: 28,
                                colorFilter: const ColorFilter.mode(Color(0xFFFF7F00), BlendMode.srcIn),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const RiwayatTransaksiScreen()));
                          },
                          child: const TransactionCard(
                            title: "Nabung otomatis dengan AI",
                            subTitle: "Nabung AI",
                            amount: "+Rp 500.000",
                            time: "23:59 WIB",
                            imageAsset: 'assets/images/celengan.png',
                            isExpense: false, 
                          ),
                        ),
                        
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const RiwayatTransaksiScreen()));
                          },
                          child: const TransactionCard(
                            title: "Bunga Tabungan",
                            subTitle: "Bunga",
                            amount: "+Rp 57.377",
                            time: "23:59 WIB",
                            imageAsset: 'assets/images/bunga.png',
                            isExpense: false, 
                          ),
                        ),
                        
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const RiwayatTransaksiScreen()));
                          },
                          child: const TransactionCard(
                            title: "Pajak atas Bunga",
                            subTitle: "Pajak",
                            amount: "-Rp 14.754",
                            time: "23:59 WIB",
                            imageAsset: 'assets/images/tax.png',
                            isExpense: true, 
                          ),
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

  void _showPindahDanaBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 16.0, bottom: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50, height: 5,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 24),
              
              const Text(
                "Pindahkan ke",
                style: TextStyle(fontFamily: 'AlumniSans', fontSize: 26, fontWeight: FontWeight.w800, color: Colors.black),
              ),
              const SizedBox(height: 20),

              GestureDetector(
                onTap: () {
                  Navigator.pop(context); 
                  Navigator.push( 
                    context,
                    MaterialPageRoute(builder: (context) => const PindahDanaCelenganScreen(
                      destName: "Saku Utama",
                      destBalance: "Rp 3.000.000",
                      destIconPath: "assets/images/IKEHome.png",
                    )),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8F0), 
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFFDBB7), width: 1.5), 
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50, height: 55,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD6E4FF), 
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
                        ),
                        alignment: Alignment.center,
                        child: Image.asset('assets/images/IKEHome.png', height: 28, fit: BoxFit.contain, errorBuilder: (c, e, s) => const Icon(Icons.account_balance, color: Colors.blue)),
                      ),
                      const SizedBox(width: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Saku Utama", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                          SizedBox(height: 4),
                          Text("Rp 3.000.000", style: TextStyle(fontSize: 16, color: Colors.black)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 12), 

              GestureDetector(
                onTap: () {
                  Navigator.pop(context); 
                  Navigator.push( 
                    context,
                    MaterialPageRoute(builder: (context) => const PindahDanaCelenganScreen(
                      destName: "Uang Belanja",
                      destBalance: "Rp 5.000.000",
                      destIconPath: 'assets/images/bag.svg',
                      isSvg: true,
                    )),
                  );
                },
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8F0), 
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFFDBB7), width: 1.5), 
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50, height: 55,
                            decoration: const BoxDecoration(
                              color: Color(0xFFD6CFFF),
                              borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
                            ),
                            alignment: Alignment.center,
                            child: SvgPicture.asset(
                              'assets/images/bag.svg', 
                              height: 36, 
                              colorFilter: const ColorFilter.mode(Color(0xFFFF7F00), BlendMode.srcIn)
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Uang Belanja", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                              SizedBox(height: 4),
                              Text("Rp 5.000.000", style: TextStyle(fontSize: 16, color: Colors.black)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 0, right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF7F00),
                          borderRadius: BorderRadius.only(topRight: Radius.circular(14), bottomLeft: Radius.circular(12)),
                        ),
                        child: const Text("Nabung", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
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

  void _showInfoSakuBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              const Text(
                "Saku Saya",
                style: TextStyle(
                  fontFamily: 'AlumniSans', 
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 55,
                                height: 55,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFD6CFFF), 
                                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
                                ),
                                alignment: Alignment.center,
                                child: Image.asset('assets/images/celengan.png', height: 50, fit: BoxFit.contain),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "Saku Celengan", 
                                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "Rp 8.000.000", 
                                      style: TextStyle(fontSize: 18, color: Colors.black)
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: const Text(
                              "*Kamu tidak dapat menambahkan dana langsung ke saku ini",
                              style: TextStyle(fontSize: 13, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    Divider(height: 1, color: Colors.grey.shade400),
                    
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
                      decoration: const BoxDecoration(
                        color: const Color(0x1AFFCA96),
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "Saku Celengan - Bunga 10% p.a.", 
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24), 
            ],
          ),
        );
      },
    );
  }

  Widget _buildCountdownBox(String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade400, width: 1.0),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFFF7F00)),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFFFF7F00)),
        ),
      ],
    );
  }
}