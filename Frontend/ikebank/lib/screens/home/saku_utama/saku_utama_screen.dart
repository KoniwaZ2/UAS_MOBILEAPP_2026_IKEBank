import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'riwayat_transaksi_screen.dart';
import '../tambah_dana_screen.dart';
import 'tambah_dana_saku_screen.dart';
import 'pindah_dana_screen.dart';
import 'transfer_dana_screen.dart';

class SakuUtamaScreen extends StatelessWidget {
  final String title;
  final String amount;
  final String imageAsset;

  const SakuUtamaScreen({
    super.key,
    this.title = "Saku Utama",
    this.amount = "Rp 3.000.000",
    this.imageAsset = 'assets/images/IKEHome.png', 
  });

  @override
  Widget build(BuildContext context) {
    bool isSvg = imageAsset.toLowerCase().endsWith('.svg');

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white, 
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.55], 
            colors: [
              Color(0x1AFFDBB7), 
              Color(0x33FF7F00), 
            ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, 
        appBar: AppBar(
          toolbarHeight: 50, 
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_horiz, color: Colors.black, size: 28),
              onPressed: () {
                _showSakuBottomSheet(context);
              },
            ),
          ],
          centerTitle: true,
          title: Transform.translate(
            offset: const Offset(0, 6), 
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'AlumniSans',
                    fontWeight: FontWeight.w800,
                    fontSize: 26,
                    color: Colors.black,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 4), 
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Nomor rekening  ",
                      style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 107, 107, 107)),
                    ),
                    const Text(
                      "10095653346 ", 
                      style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(const ClipboardData(text: "10095653346"));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Nomor rekening berhasil disalin!")),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4.0), 
                        child: SvgPicture.asset(
                          'assets/images/copy.svg',
                          height: 14,
                          colorFilter: const ColorFilter.mode(Color(0xFFFF7F00), BlendMode.srcIn), 
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 50), 
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 60, bottom: 24, left: 16, right: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text("Dana tersedia", style: TextStyle(fontSize: 16, color: Colors.black)),
                          const SizedBox(height: 4),
                          Text(
                            amount, 
                            style: const TextStyle(
                              fontFamily: 'AlumniSans', 
                              fontSize: 32, 
                              fontWeight: FontWeight.w900, 
                              color: Color(0xFFFF7F00)
                            ),
                          ),
                          const SizedBox(height: 2), 
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildActionButton(icon: Icons.add, label: "Tambah dana", onTap: () {
                                _showTambahDanaBottomSheet(context);
                              }),
                              _buildActionButton(svgPath: 'assets/images/pindah.svg', label: "Pindah dana", onTap: () {
                                _showPindahkanKeBottomSheet(context);
                              }),
                              _buildActionButton(icon: Icons.arrow_forward, label: "Kirim & bayar", onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const TransferDanaScreen()),
                                );
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    Positioned(
                      top: -30,
                      child: Container(
                        width: 70, height: 75,
                        decoration: const BoxDecoration(
                          color: Color(0xFFCCCCFF),
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(35)),
                        ),
                        alignment: Alignment.center,
                        child: isSvg
                            ? SvgPicture.asset(imageAsset, height: 50, fit: BoxFit.contain)
                            : Image.asset(imageAsset, height: 50, fit: BoxFit.contain, errorBuilder: (c, e, s) => const Icon(Icons.image, color: Colors.grey)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24.0),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/images/kartu.svg',
                      height: 24, 
                      colorFilter: const ColorFilter.mode(Color(0xFFFF7F00), BlendMode.srcIn), 
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text("**** **** **** 2706", style: TextStyle(fontSize: 16, color: Colors.black87)),
                    ),
                    Icon(Icons.arrow_forward_ios, color: const Color(0xFFFF7F00).withOpacity(0.7), size: 18),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0),
                  decoration: const BoxDecoration(
                    color: Colors.white, 
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 45,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: const TextField(
                                decoration: InputDecoration(
                                  hintText: "Cari transaksi",
                                  hintStyle: TextStyle(color: Colors.black87, fontSize: 16),
                                  prefixIcon: Icon(Icons.search, color: Colors.black87),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () {
                              _showFilterBottomSheet(context); 
                            },
                            child: SvgPicture.asset(
                              'assets/images/history.svg', 
                              height: 28,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      const Text(
                        "Kamis, 26 Februari 2026", 
                        style: TextStyle(
                          color: Color(0xFFFF7F00), 
                          fontSize: 18, 
                          fontFamily: 'AlumniSans', 
                          fontWeight: FontWeight.w800,
                        )
                      ),
                      
                      const SizedBox(height: 16),

                      // dummy history transaksi
                      Expanded(
                        child: ListView(
                          physics: const BouncingScrollPhysics(),
                          children: [
                            _buildTransactionItem(
                              icon: Icons.add, 
                              title: "Dana Masuk dari Ericson Wen", 
                              subtitle: "Bank BCA", 
                              amount: "+Rp 250.000", 
                              time: "11:00 WIB", 
                              isIncome: true,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const RiwayatTransaksiScreen()),
                                );
                              }
                            ),
                            _buildTransactionItem(
                              icon: Icons.arrow_forward, 
                              title: "Transfer ke Ivan Ibrahim", 
                              subtitle: "Seabank", 
                              amount: "-Rp 100.000", 
                              time: "09:00 WIB", 
                              isIncome: false
                            ),
                            _buildTransactionItem(
                              imagePath: 'assets/images/deposito.png', 
                              title: "Penempatan Deposito - Kelvin K", 
                              subtitle: "Deposito 1 Bulan", 
                              amount: "-Rp 5.000.000", 
                              time: "08:00 WIB", 
                              isIncome: false
                            ),
                            _buildTransactionItem(
                              imagePath: 'assets/images/deposito.png',
                              title: "Pencairan Deposito - Kelvin K", 
                              subtitle: "Deposito 1 Bulan", 
                              amount: "+Rp 5.000.000", 
                              time: "04:00 WIB", 
                              isIncome: true
                            ),
                            _buildTransactionItem(
                              imagePath: 'assets/images/bunga.png', 
                              title: "Bunga Deposito - Kelvin K", 
                              subtitle: "Bunga", 
                              amount: "+Rp 16.986", 
                              time: "04:00 WIB", 
                              isIncome: true
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({IconData? icon, String? svgPath, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: const Color(0x80F69500), 
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: svgPath != null
                ? SvgPicture.asset(
                    svgPath,
                    height: 50,
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  )
                : Icon(icon, color: Colors.white, size: 28), 
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFFF7F00)),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem({
  IconData? icon, // Sekarang nullable
  String? imagePath, // Tambahan untuk gambar
  required String title, 
  required String subtitle, 
  required String amount, 
  required String time, 
  required bool isIncome,
  VoidCallback? onTap, // Tambahan agar bisa diklik
}) {
  return GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFFFCA96).withOpacity(0.5), 
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            // Jika ada imagePath, gunakan gambar. Jika tidak, gunakan Icon.
            child: imagePath != null
                ? Image.asset(imagePath, height: 28, fit: BoxFit.contain)
                : Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount, 
                style: TextStyle(
                  fontWeight: FontWeight.w600, 
                  fontSize: 14, 
                  color: isIncome ? const Color(0xFF00B14F) : Colors.grey.shade600
                )
              ),
              const SizedBox(height: 4),
              Text(time, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
        ],
      ),
    ),
  );
}

  void _showSakuBottomSheet(BuildContext context) {
    bool isSvg = imageAsset.toLowerCase().endsWith('.svg');

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
                      child: Row(
                        children: [
                          Container(
                            width: 55,
                            height: 55,
                            decoration: const BoxDecoration(
                              color: Color(0xFFCCCCFF),
                              borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
                            ),
                            alignment: Alignment.center,
                            child: isSvg
                                ? SvgPicture.asset(imageAsset, height: 30, fit: BoxFit.contain)
                                : Image.asset(imageAsset, height: 30, fit: BoxFit.contain, errorBuilder: (c, e, s) => const Icon(Icons.image, color: Colors.grey)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title, 
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  amount, 
                                  style: const TextStyle(fontSize: 16, color: Colors.black)
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    Divider(height: 1, color: Colors.grey.shade400),
                    
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                      decoration: const BoxDecoration(
                        color: Color(0x1AFFCA96), 
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "$title - Bunga 0.5% p.a.", 
                        style: const TextStyle(fontSize: 18, color: Colors.black),
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

  void _showTambahDanaBottomSheet(BuildContext context) {
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
              // 1. Drag Handle
              Center(
                child: Container(
                  width: 50, height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              const Text(
                "Tambah dana dari mana?",
                style: TextStyle(
                  fontFamily: 'AlumniSans', 
                  fontSize: 26, 
                  fontWeight: FontWeight.w800, 
                  color: Colors.black
                ),
              ),
              const SizedBox(height: 20),

             _buildTambahDanaOption(
             iconWidget: Container(
               width: 45, height: 45,
               decoration: BoxDecoration(
                 color: const Color(0xFFCCCCFF), 
                 borderRadius: BorderRadius.circular(12),
               ),
               alignment: Alignment.center,
               child: Image.asset('assets/images/IKEHome.png', height: 24, fit: BoxFit.contain),
             ),
             title: "Dari Saku kamu",
             subtitle: "Pindahkan dari Saku lain",
             onTap: () {
               Navigator.pop(context); 

               Navigator.push(
                 context,
                 MaterialPageRoute(builder: (context) => const TambahDanaSakuScreen()),
               );
             },
           ),
              
              const SizedBox(height: 16),

              _buildTambahDanaOption(
                iconWidget: SvgPicture.asset(
                  'assets/images/bank2.svg', 
                  width: 36, 
                ),
                title: "Dari luar IKE Bank",
                subtitle: "Kirim dana dari bank atau aplikasi lain",
                onTap: () {
                  Navigator.pop(context); 
                  
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TambahDanaScreen()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTambahDanaOption({
    required Widget iconWidget, 
    required String title, 
    required String subtitle, 
    required VoidCallback onTap
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8F0), 
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFDBB7), width: 1.5), 
        ),
        child: Row(
          children: [
            iconWidget,
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 16, color: Colors.black)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

void _showPindahkanKeBottomSheet(BuildContext context) {
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
                    MaterialPageRoute(builder: (context) => const PindahDanaScreen()),
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

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        String selectedPeriode = ''; 
        String selectedJenis = '';
        
        String? tanggalDari; 
        String? tanggalSampai; 

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24.0, right: 24.0, top: 16.0,
                bottom: MediaQuery.of(context).padding.bottom + 24.0 
              ),
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
                  
                  const Text("Filter transaksi", style: TextStyle(fontFamily: 'AlumniSans', fontSize: 28, fontWeight: FontWeight.w800, color: Colors.black)),
                  const SizedBox(height: 24),

                  const Text("Periode", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 8),
                  
                  _buildRadioOption("7 hari terakhir", selectedPeriode, (val) => setState(() => selectedPeriode = val)),
                  _buildRadioOption("30 hari terakhir", selectedPeriode, (val) => setState(() => selectedPeriode = val)),
                  _buildRadioOption("Pilih tanggal", selectedPeriode, (val) => setState(() => selectedPeriode = val)),

                  //Dropdown muncul kalo "Pilih tanggal" aktif
                  if (selectedPeriode == "Pilih tanggal") ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDatePickerBox("Dari", tanggalDari, (val) {
                            setState(() {
                              tanggalDari = val;
                            });
                          })
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDatePickerBox("Sampai", tanggalSampai, (val) {
                            setState(() {
                              tanggalSampai = val;
                            });
                          })
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),
                  
                  const Text("Jenis transaksi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 8),

                  _buildRadioOption("Dana masuk", selectedJenis, (val) => setState(() => selectedJenis = val)),
                  _buildRadioOption("Dana keluar", selectedJenis, (val) => setState(() => selectedJenis = val)),

                  const SizedBox(height: 32),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context), 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF7F00),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text("Lihat Hasil", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  )
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildRadioOption(String title, String groupValue, Function(String) onChanged) {
    bool isSelected = title == groupValue;
    return GestureDetector(
      onTap: () => onChanged(title),
      behavior: HitTestBehavior.opaque, 
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, color: Colors.black87)),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? const Color(0xFFFF7F00) : Colors.black87,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePickerBox(String title, String? selectedValue, Function(String?) onChanged) {
    List<String> days = List.generate(31, (index) => (index + 1).toString());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F0), 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFDBB7), width: 1.5), 
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFFF7F00))),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              isDense: true,
              value: selectedValue,
              hint: Text("Pilih", style: TextStyle(fontSize: 14, color: Colors.grey.shade400)),
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFFFF7F00), size: 18),
              items: days.map((String day) {
                return DropdownMenuItem<String>(
                  value: day,
                  child: Text(day, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}