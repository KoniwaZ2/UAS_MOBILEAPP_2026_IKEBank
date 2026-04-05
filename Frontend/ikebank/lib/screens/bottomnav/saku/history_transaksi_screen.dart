import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../home/saku_utama/pindah_dana_screen.dart';
import '../../home/saku_utama/tambah_dana_saku_screen.dart';
import '../../home/saku_utama/transfer_dana_screen.dart';
import '../../home/tambah_dana_screen.dart';

class HistoryTransaksiScreen extends StatefulWidget {
  final String title;
  final String amount;
  final String imageAsset;

  const HistoryTransaksiScreen({
    super.key,
    required this.title,
    required this.amount,
    required this.imageAsset,
  });

  @override
  State<HistoryTransaksiScreen> createState() => _HistoryTransaksiScreenState();
}

class _HistoryTransaksiScreenState extends State<HistoryTransaksiScreen> {
  late String _currentAmount;
  late bool _isSvg;
  bool _shouldReturnRefresh = false;

  @override
  void initState() {
    super.initState();
    _currentAmount = widget.amount;
    _isSvg = widget.imageAsset.toLowerCase().endsWith('.svg');
  }

  Future<void> _openAndTrack(Widget page) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
    if (result == true && mounted) {
      _shouldReturnRefresh = true;
    }
  }

  void _showInfoSakuBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
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
                'Saku Saya',
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
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(16),
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
                              borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(25),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: _isSvg
                                ? SvgPicture.asset(
                                    widget.imageAsset,
                                    height: 30,
                                    fit: BoxFit.contain,
                                  )
                                : Image.asset(
                                    widget.imageAsset,
                                    height: 30,
                                    fit: BoxFit.contain,
                                    errorBuilder: (c, e, s) => const Icon(
                                      Icons.image,
                                      color: Colors.grey,
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.title,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _currentAmount,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: Colors.grey.shade300,
                      thickness: 1,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Bunga 0.5% p.a.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
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
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
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
                'Tambah dana dari mana?',
                style: TextStyle(
                  fontFamily: 'AlumniSans',
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              _buildTambahDanaOption(
                iconWidget: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Image.asset(
                    'assets/images/IKEHome.png',
                    fit: BoxFit.contain,
                  ),
                ),
                title: 'Dari Saku kamu',
                subtitle: 'Pindahkan dari Saku lain',
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _openAndTrack(const TambahDanaSakuScreen());
                },
              ),
              const SizedBox(height: 16),
              _buildTambahDanaOption(
                iconWidget: SvgPicture.asset(
                  'assets/images/bank2.svg',
                  width: 36,
                ),
                title: 'Dari luar IKE Bank',
                subtitle: 'Kirim dana dari bank atau aplikasi lain',
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _openAndTrack(const TambahDanaScreen());
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
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFDBB7), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              alignment: Alignment.center,
              child: iconWidget,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.55],
          colors: [Color(0x1AFFDBB7), Color(0x33FF7F00)],
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
            onPressed: () => Navigator.pop(context, _shouldReturnRefresh),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_horiz, color: Colors.black, size: 28),
              onPressed: () => _showInfoSakuBottomSheet(context),
            ),
          ],
          centerTitle: true,
          title: Transform.translate(
            offset: const Offset(0, 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
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
                      'Nomor rekening  ',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(255, 107, 107, 107),
                      ),
                    ),
                    const Text(
                      '10095653677 ',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(
                          const ClipboardData(text: '10095653677'),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Nomor rekening disalin!'),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: SvgPicture.asset(
                          'assets/images/copy.svg',
                          height: 14,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFFFF7F00),
                            BlendMode.srcIn,
                          ),
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
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                        top: 60,
                        bottom: 24,
                        left: 16,
                        right: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
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
                          const Text(
                            'Dana tersedia',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _currentAmount,
                            style: const TextStyle(
                              fontFamily: 'AlumniSans',
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFFF7F00),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildActionButton(
                                icon: Icons.add,
                                label: 'Tambah dana',
                                onTap: () =>
                                    _showTambahDanaBottomSheet(context),
                              ),
                              _buildActionButton(
                                svgPath: 'assets/images/pindah.svg',
                                label: 'Pindah dana',
                                onTap: () async {
                                  await _openAndTrack(const PindahDanaScreen());
                                },
                              ),
                              _buildActionButton(
                                icon: Icons.arrow_forward,
                                label: 'Kirim & bayar',
                                onTap: () async {
                                  await _openAndTrack(
                                    const TransferDanaScreen(),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: -30,
                      child: Container(
                        width: 70,
                        height: 75,
                        decoration: const BoxDecoration(
                          color: Color(0xFFCCCCFF),
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(35),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: _isSvg
                            ? SvgPicture.asset(
                                widget.imageAsset,
                                height: 50,
                                fit: BoxFit.contain,
                              )
                            : Image.asset(
                                widget.imageAsset,
                                height: 50,
                                fit: BoxFit.contain,
                                errorBuilder: (c, e, s) =>
                                    const Icon(Icons.image, color: Colors.grey),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 24.0,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 45,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade400),
                              ),
                              child: const TextField(
                                decoration: InputDecoration(
                                  hintText: 'Cari transaksi',
                                  hintStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: Colors.black87,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () => _showInfoSakuBottomSheet(context),
                            child: SvgPicture.asset(
                              'assets/images/history.svg',
                              height: 28,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      SvgPicture.asset(
                        'assets/images/BoxPajak.svg',
                        height: 200,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Belum ada transaksi, yuk gunakan\nsaku ini untuk bertransaksi',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const Spacer(),
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

  Widget _buildActionButton({
    IconData? icon,
    String? svgPath,
    required String label,
    required VoidCallback onTap,
  }) {
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
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  )
                : Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFF7F00),
            ),
          ),
        ],
      ),
    );
  }
}
