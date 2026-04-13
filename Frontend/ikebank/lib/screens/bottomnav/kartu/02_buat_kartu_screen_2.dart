import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../api/banking.dart';
import '../../../models/wallet_source.dart';
import '03_buat_kartu_screen_3.dart';
import '04_pin_screen.dart';

class BuatKartuScreen2 extends StatefulWidget {
  const BuatKartuScreen2({super.key});

  @override
  State<BuatKartuScreen2> createState() => _BuatKartuScreen2State();
}

class _BuatKartuScreen2State extends State<BuatKartuScreen2> {
  final nama = TextEditingController();

  String selectedSaku = 'Saku Utama';
  String saldo = 'Rp 3.000.000';
  String alamatUser = 'Belum diisi';
  String _sourceFundsId = '';
  String? _selectedSakuId;
  bool _isLoadingSaku = true;
  List<WalletSource> _availableSakus = <WalletSource>[];

  @override
  void initState() {
    super.initState();
    _loadEligibleSakus();
    _prefillNamaPenerima();
  }

  Future<void> _prefillNamaPenerima() async {
    try {
      final accountDetails = await BankingService.fetchAccountDetails();
      final fetchedName = accountDetails.isNotEmpty
          ? accountDetails.first.username.trim()
          : '';
      final fetchedSourceFundsId = accountDetails.isNotEmpty
          ? accountDetails.first.userid.toString().trim()
          : '';

      if (!mounted) {
        return;
      }

      setState(() {
        nama.text = fetchedName;
        _sourceFundsId = fetchedSourceFundsId;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {});
    }
  }

  Future<void> _loadEligibleSakus() async {
    try {
      final raw = await BankingService.sakuList();
      final dynamic payload = raw is Map<String, dynamic>
          ? (raw['data'] ?? raw['results'] ?? raw['sakus'] ?? raw)
          : raw;

      final sources = payload is List
          ? payload
                .whereType<Map<String, dynamic>>()
                .map(WalletSource.fromJson)
                .where(
                  (source) =>
                      source.category == WalletCategory.utama ||
                      source.category == WalletCategory.nabung ||
                      source.category == WalletCategory.transaksi,
                )
                .where((source) => source.id.trim().isNotEmpty)
                .toList()
          : <WalletSource>[];

      if (!mounted) {
        return;
      }

      setState(() {
        _availableSakus = sources;

        final defaultSource = _availableSakus.firstWhere(
          (source) => source.category == WalletCategory.utama,
          orElse: () => _availableSakus.isNotEmpty
              ? _availableSakus.first
              : const WalletSource(
                  id: '',
                  name: 'Saku Utama',
                  balance: '0',
                  imagePath: 'assets/images/IKEHome.png',
                  category: WalletCategory.utama,
                ),
        );

        if (defaultSource.id.isNotEmpty) {
          _selectedSakuId = defaultSource.id;
          _sourceFundsId = defaultSource.id;
          selectedSaku = defaultSource.name;
          saldo = _formatRupiah(defaultSource.balance);
        }

        _isLoadingSaku = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _availableSakus = <WalletSource>[];
        _isLoadingSaku = false;
      });
    }
  }

  String _formatRupiah(String raw) {
    final numeric = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (numeric.isEmpty) {
      return 'Rp 0';
    }

    final reversed = numeric.split('').reversed.join();
    final chunks = <String>[];
    for (var i = 0; i < reversed.length; i += 3) {
      final end = (i + 3 < reversed.length) ? i + 3 : reversed.length;
      chunks.add(reversed.substring(i, end));
    }
    final grouped = chunks.join('.').split('').reversed.join();
    return 'Rp $grouped';
  }

  Widget _buildSakuItem(WalletSource source) {
    final isSelected = source.id == _selectedSakuId;
    final isSvg = source.imagePath.toLowerCase().endsWith('.svg');
    final showTransaksiBadge = source.category == WalletCategory.transaksi;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSakuId = source.id;
          _sourceFundsId = source.id;
          selectedSaku = source.name;
          saldo = _formatRupiah(source.balance);
        });
        Navigator.pop(context);
      },
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEBD7C3),
              borderRadius: BorderRadius.circular(18),
              border: isSelected
                  ? Border.all(color: const Color(0xFFFF7F00), width: 1.5)
                  : null,
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
                    child: isSvg
                        ? SvgPicture.asset(source.imagePath)
                        : Image.asset(source.imagePath),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        source.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatRupiah(source.balance),
                        style: const TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (showTransaksiBadge)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(18),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
                child: const Text(
                  'Transaksi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

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
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              if (_isLoadingSaku)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: CircularProgressIndicator(color: Color(0xFFFF7F00)),
                )
              else if (_availableSakus.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'Tidak ada saku nabung/transaksi/utama yang tersedia',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                )
              else
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _availableSakus.map(_buildSakuItem).toList(),
                    ),
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
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                        controller: nama,
                        readOnly: true,
                        style: const TextStyle(fontSize: 22),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    GestureDetector(
                      onTap: showSakuPopup,
                      child: boxField(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                    fontWeight: FontWeight.bold,
                                  ),
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
                                style: TextStyle(color: Color(0xFFFF7F00)),
                              ),
                            ),
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
                                BuatKartuScreen3(sourceFundsId: _sourceFundsId),
                          ),
                        );

                        if (result != null) {
                          setState(() {
                            alamatUser = result["alamat"];
                            _sourceFundsId =
                                (result["source_funds_id"] ?? _sourceFundsId)
                                    .toString();
                          });
                        }
                      },
                      child: boxField(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.arrow_forward_ios, size: 16),
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
                      if (alamatUser == 'Belum diisi' ||
                          alamatUser.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Silakan isi alamat pengiriman kartu terlebih dahulu!",
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return; // Hentikan, jangan biarkan pindah ke PinScreen
                      }

                      // Jika aman, baru boleh lanjut buat PIN
                      print(
                        'Navigating to PinScreen with sourceFundsId: $_sourceFundsId',
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PinScreen(
                            nama: nama.text,
                            sourceFundsId: _sourceFundsId,
                            entrySource: PinEntrySource.buatKartu,
                          ),
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

  @override
  void dispose() {
    nama.dispose();
    super.dispose();
  }
}
