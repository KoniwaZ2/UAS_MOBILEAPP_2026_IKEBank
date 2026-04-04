import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../models/wallet_source.dart';
import '../../../api/banking.dart';
import 'qris_pin_screen.dart';

class QrisKonfirmasiScreen extends StatefulWidget {
  final String qrisNumber;
  final String merchantName;
  final String location;
  final String aquirer;
  final String panId;

  const QrisKonfirmasiScreen({
    super.key,
    required this.qrisNumber,
    required this.merchantName,
    required this.location,
    required this.aquirer,
    required this.panId,
  });

  @override
  State<QrisKonfirmasiScreen> createState() => _QrisKonfirmasiScreenState();
}

class _QrisKonfirmasiScreenState extends State<QrisKonfirmasiScreen> {
  final TextEditingController _amountController = TextEditingController();
  List<WalletSource> _walletSources = [];
  WalletSource? _selectedSource;

  final TextStyle alumniSansBold = const TextStyle(
    fontWeight: FontWeight.w800,
    fontFamily: 'AlumniSans',
  );

  @override
  void initState() {
    super.initState();
    _loadWalletSources();
  }

  WalletSource? _resolveDefaultSource(List<WalletSource> sources) {
    if (sources.isEmpty) {
      return null;
    }
    return sources.firstWhere(
      (source) => source.category == WalletCategory.utama,
      orElse: () => sources.first,
    );
  }

  Future<void> _loadWalletSources() async {
    try {
      final fetchedSources = await BankingService.fetchQrisFundingSources();
      if (!mounted) return;

      if (fetchedSources.isEmpty) {
        setState(() {
          _walletSources = [];
          _selectedSource = null;
        });
        return;
      }

      final defaultSource = _resolveDefaultSource(fetchedSources);

      setState(() {
        _walletSources = fetchedSources;
        _selectedSource = defaultSource;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal memuat sumber dana')));
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _showSumberDanaBottomSheet() {
    final allowedSources = _walletSources
        .where(
          (source) =>
              source.category == WalletCategory.utama ||
              source.category == WalletCategory.transaksi,
        )
        .toList();

    if (allowedSources.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sumber dana belum tersedia.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.only(
            top: 12,
            left: 24,
            right: 24,
            bottom: 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                "Sumber dana",
                style: alumniSansBold.copyWith(
                  fontSize: 28,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),

              ...allowedSources.asMap().entries.map((entry) {
                final index = entry.key;
                final source = entry.value;

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == allowedSources.length - 1 ? 0 : 12,
                  ),
                  child: _buildBottomSheetItem(
                    title: source.name,
                    balance: source.balance,
                    imagePath: source.imagePath,
                    tag: source.tag,
                    onTap: () {
                      setState(() {
                        _selectedSource = source;
                      });
                      Navigator.pop(context);
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetItem({
    required String title,
    required String balance,
    required String imagePath,
    String? tag,
    required VoidCallback onTap,
  }) {
    bool isSvg = imagePath.toLowerCase().endsWith('.svg');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9F2),
          border: Border.all(color: const Color(0xFFFFCAA3), width: 1.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFD6CFFF),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(8),
              child: isSvg
                  ? SvgPicture.asset(imagePath, fit: BoxFit.contain)
                  : Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) =>
                          const Icon(Icons.image, color: Colors.grey),
                    ),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: alumniSansBold.copyWith(
                      fontSize: 22,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    balance,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
            ),

            if (tag != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF7F00), // Oranye
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "QRIS",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 24,
            fontFamily: 'AlumniSans',
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Konfirmasi Pembayaran",
                      style: alumniSansBold.copyWith(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 1. INFO MERCHANT (Otomatis dari Scan)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.merchantName,
                            style: TextStyle(
                              fontSize: 28,
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.qrisNumber,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9D9D9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Jumlah pembayaran",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Row(
                            children: [
                              const Text(
                                "Rp",
                                style: TextStyle(
                                  fontSize: 28,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _amountController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    color: Colors.black,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Sumber dana",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _selectedSource?.name ?? '-',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  _selectedSource?.balance ?? 'Rp0',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: _showSumberDanaBottomSheet,
                            child: const Text(
                              "Ganti",
                              style: TextStyle(
                                color: Color(0xFFFF7F00),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    final amount = _amountController.text.trim();
                    if (amount.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Masukkan jumlah pembayaran terlebih dahulu.',
                          ),
                        ),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QrisPinScreen(
                          qrisNumber: widget.qrisNumber,
                          amount: amount,
                          merchantName: widget.merchantName,
                          location: widget.location,
                          aquirer: widget.aquirer,
                          panId: widget.panId,
                          walletName: _selectedSource?.name ?? 'Saku Utama',
                          walletBalance: _selectedSource?.balance ?? 'Rp0',
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7F00),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Konfirmasi",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
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
