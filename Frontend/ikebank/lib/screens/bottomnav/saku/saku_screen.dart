import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'tambah_saku_screen.dart';
import '../../home/saku_utama/saku_utama_screen.dart';
import 'history_transaksi_screen.dart';
import '../../../api/banking.dart';
import '../../../models/wallet_source.dart';

class SakuScreen extends StatefulWidget {
  const SakuScreen({super.key});

  @override
  State<SakuScreen> createState() => _SakuScreenState();
}

class _SakuScreenState extends State<SakuScreen> {
  int _selectedTab = 0;
  bool _isLoadingSakus = true;
  String? _sakuError;
  List<WalletSource> _wallets = [];

  Future<void> _refreshIfChanged(dynamic result) async {
    if (result == true && mounted) {
      await _loadSakuList();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSakuList();
  }

  Future<void> _loadSakuList() async {
    setState(() {
      _isLoadingSakus = true;
      _sakuError = null;
    });

    try {
      final raw = await BankingService.sakuList();
      final fetchedWallets = _parseWalletsFromSakuList(raw);

      if (!mounted) {
        return;
      }

      setState(() {
        _wallets = fetchedWallets;
        _isLoadingSakus = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _sakuError = e.toString().replaceFirst('Exception: ', '');
        _isLoadingSakus = false;
      });
    }
  }

  List<WalletSource> _parseWalletsFromSakuList(dynamic raw) {
    final dynamic payload = raw is Map<String, dynamic>
        ? (raw['data'] ?? raw['results'] ?? raw['sakus'] ?? raw)
        : raw;

    if (payload is! List) {
      return <WalletSource>[];
    }

    return payload
        .whereType<Map<String, dynamic>>()
        .map(WalletSource.fromJson)
        .where((wallet) => wallet.name.trim().isNotEmpty)
        .toList();
  }

  List<WalletSource> _filteredWallets() {
    if (_selectedTab == 2) {
      return _wallets
          .where((wallet) => wallet.category == WalletCategory.transaksi)
          .toList();
    }

    if (_selectedTab == 0) {
      return _wallets;
    }

    if (_selectedTab == 1) {
      return _wallets
          .where((wallet) => wallet.category == WalletCategory.nabung)
          .toList();
    }

    return _wallets;
  }

  bool _isSakuUtama(String title) {
    return title.trim().toLowerCase() == 'saku utama';
  }

  int _parseBalanceToInt(String rawBalance) {
    final normalized = rawBalance
        .replaceAll('Rp', '')
        .replaceAll('.', '')
        .replaceAll(',', '')
        .replaceAll(RegExp(r'\s+'), '')
        .trim();
    return int.tryParse(normalized) ?? 0;
  }

  String _formatRupiah(int amount) {
    final digits = amount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      final remaining = digits.length - i;
      buffer.write(digits[i]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write('.');
      }
    }
    return 'Rp ${buffer.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle alumniSansBold = const TextStyle(
      fontWeight: FontWeight.w800,
      fontFamily: 'AlumniSans',
    );

    final visibleWallets = _filteredWallets();
    final totalAmount = visibleWallets.fold<int>(
      0,
      (sum, wallet) => sum + _parseBalanceToInt(wallet.balance),
    );

    String bannerTitle = "Total dana";
    String bannerImage = 'assets/images/stonks.png';

    if (_selectedTab == 1) {
      bannerTitle = "Dana Tabungan";
      bannerImage = 'assets/images/nabung.png';
    } else if (_selectedTab == 2) {
      bannerTitle = "Dana Transaksi";
      bannerImage = 'assets/images/transaksi.png';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Saku",
                      style: alumniSansBold.copyWith(
                        fontSize: 40,
                        color: Colors.black,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTabButton(title: "Semua", index: 0),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTabButton(title: "Nabung", index: 1),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTabButton(title: "Transaksi", index: 2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (_selectedTab == 2)
                      SizedBox(
                        height: 160,
                        width: double.infinity,
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.bottomCenter,
                          children: [
                            Container(
                              height: 160,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.black87,
                                  width: 1.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 16.0,
                                        top: 16.0,
                                        bottom: 16.0,
                                        right: 8.0,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            bannerTitle,
                                            style: const TextStyle(
                                              fontSize: 26,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              _formatRupiah(totalAmount),
                                              style: alumniSansBold.copyWith(
                                                fontSize: 24,
                                                color: Colors.black,
                                                height: 1.0,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          const Text(
                                            "Jumlah dana dari\nsemua saku kamu",
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              height: 1.1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Container(
                                      height: double.infinity,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF01008A),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.zero,
                                          bottomLeft: Radius.circular(23),
                                          topRight: Radius.circular(23),
                                          bottomRight: Radius.circular(23),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              right: 10,
                              bottom: 0,
                              child: IgnorePointer(
                                child: Image.asset(
                                  bannerImage,
                                  height: 180,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        height: 160,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.black87, width: 1.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 16.0,
                                  top: 16.0,
                                  bottom: 16.0,
                                  right: 8.0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      bannerTitle,
                                      style: const TextStyle(
                                        fontSize: 26,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        _formatRupiah(totalAmount),
                                        style: alumniSansBold.copyWith(
                                          fontSize: 24,
                                          color: Colors.black,
                                          height: 1.0,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
                                      "Jumlah dana dari\nsemua saku kamu",
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.black,
                                        height: 1.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Container(
                                height: double.infinity,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF01008A),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.zero,
                                    bottomLeft: Radius.circular(23),
                                    topRight: Radius.circular(23),
                                    bottomRight: Radius.circular(23),
                                  ),
                                ),
                                alignment: Alignment.center,
                                padding: const EdgeInsets.only(
                                  left: 1.0,
                                  right: 1.0,
                                  top: 16.0,
                                  bottom: 16.0,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.asset(
                                    bannerImage,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                padding: const EdgeInsets.fromLTRB(24.0, 32.0, 24.0, 100.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: _buildWhiteBoxContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWhiteBoxContent() {
    if (_isLoadingSakus) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_sakuError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _sakuError!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadSakuList,
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      );
    }

    if (_selectedTab == 2) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.90,
            children: _buildWalletCards(includeTambahCard: false),
          ),
          const SizedBox(height: 0.5),
          const Text(
            "Atur Pengeluaranmu",
            style: TextStyle(
              fontFamily: 'AlumniSans',
              fontWeight: FontWeight.w800,
              fontSize: 26,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Mau lebih bijak kelola keuangan kamu? Atur\npengeluaranmu dengan bantuan AI kami sesuai\nkebutuhanmu",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, color: Colors.black, height: 1.3),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7F00),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: const Text(
                "AI Agent",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TambahSakuScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF01008A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Tambah Saku",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 0.90,
        children: _buildWalletCards(includeTambahCard: true),
      );
    }
  }

  List<Widget> _buildWalletCards({required bool includeTambahCard}) {
    final cards = <Widget>[];

    if (includeTambahCard) {
      cards.add(_buildTambahSakuCard());
    }

    for (final wallet in _filteredWallets()) {
      cards.add(
        _buildSakuCard(
          title: wallet.name,
          amount: _formatRupiah(_parseBalanceToInt(wallet.balance)),
          imageAsset: wallet.imagePath,
        ),
      );
    }

    return cards;
  }

  Widget _buildTabButton({required String title, required int index}) {
    bool isActive = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFFAE00) : const Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildTambahSakuCard() {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TambahSakuScreen()),
        );

        if (!context.mounted) return;

        await _refreshIfChanged(result);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF9F9),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 55,
                  height: 55,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF7F00),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 35),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Tambah Saku",
                  style: TextStyle(
                    color: Color(0xFFFF7F00),
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSakuCard({
    required String title,
    required String amount,
    required String imageAsset,
  }) {
    bool isSvg = imageAsset.toLowerCase().endsWith('.svg');
    return GestureDetector(
      onTap: () async {
        dynamic result;
        if (_isSakuUtama(title)) {
          result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SakuUtamaScreen()),
          );
        } else {
          result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HistoryTransaksiScreen(
                title: title,
                amount: amount,
                imageAsset: imageAsset,
              ),
            ),
          );
        }

        await _refreshIfChanged(result);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF9F9),
              borderRadius: BorderRadius.circular(24),
            ),
            alignment: Alignment.topCenter,
            child: Container(
              width: 95,
              height: 85,
              decoration: const BoxDecoration(
                color: Color(0xFFD6CFFF),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(45),
                ),
              ),
              alignment: Alignment.center,
              child: isSvg
                  ? SvgPicture.asset(
                      imageAsset,
                      height: 90,
                      fit: BoxFit.contain,
                    )
                  : Image.asset(
                      imageAsset,
                      height: 90,
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) =>
                          const Icon(Icons.image, color: Colors.grey),
                    ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'AlumniSans',
              fontWeight: FontWeight.w800,
              fontSize: 22,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 0.5),
          Text(
            amount,
            style: const TextStyle(fontSize: 28, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
