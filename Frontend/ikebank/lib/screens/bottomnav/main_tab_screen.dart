import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../api/banking.dart';
import '../home/home_screen.dart';
import 'saku/saku_screen.dart';
import 'qris/qris_screen.dart';
import 'kartu/buat_kartu_screen.dart';
import 'kartu/05_kartu_berhasil_screen.dart';
import 'kartu/08_detail_kartu_screen.dart';
import 'lainnya/lainnya_screen.dart';
import 'kartu/11_detail_kartu_blokir_screen.dart';

class MainTabScreen extends StatefulWidget {
  final int initialIndex;
  final HomeEntrySource homeEntrySource;

  const MainTabScreen({
    super.key,
    this.initialIndex = 0,
    this.homeEntrySource = HomeEntrySource.login,
  });

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  late int _selectedIndex;
  String _cardStatus = 'none';
  bool _hasKartu = false;
  bool _isCheckingKartu = false;

  Widget get _kartuPage {
    if (!_hasKartu) {
      return const BuatKartuScreen();
    }

    if (_cardStatus.contains('requested') ||
        _cardStatus.contains('delivered')) {
      return const KartuBerhasilScreen();
    }

    if (_cardStatus.contains('active')) {
      return const DetailKartuScreen();
    }

    if (_cardStatus.contains('blocked_temporary')) {
      return const DetailKartuBlokirScreen();
    }

    return const BuatKartuScreen();
  }

  List<Widget> get _pages => [
    HomeScreen(entrySource: widget.homeEntrySource),
    const SakuScreen(),
    const Scaffold(
      body: Center(child: Text("Halaman QRIS (Dalam Pengembangan)")),
    ),
    _kartuPage,
    const LainnyaScreen(),
  ];

  Future<void> _handleKartuTabTap() async {
    if (_isCheckingKartu) {
      return;
    }

    setState(() {
      _isCheckingKartu = true;
    });

    try {
      final accountDetails = await BankingService.fetchAccountDetails();
      final hasCardNumber = accountDetails.any(
        (account) => account.cardnumber?.trim().isNotEmpty ?? false,
      );
      bool resolvedHasKartu = hasCardNumber;
      String resolvedCardStatus = hasCardNumber ? 'requested' : 'none';

      try {
        final detail = await BankingService.cardDetails();
        if (detail is Map<String, dynamic>) {
          final status = (detail['card_status'] ?? 'none')
              .toString()
              .trim()
              .toLowerCase();
          final cardNumber = (detail['card_number'] ?? '').toString().trim();
          final hasStatusKartu =
              status == 'active' ||
              status == 'requested' ||
              status == 'delivered' ||
              status == 'blocked_temporary' ||
              status == 'blocked_permanent';

          resolvedCardStatus = status.isEmpty ? 'none' : status;
          resolvedHasKartu =
              hasCardNumber || cardNumber.isNotEmpty || hasStatusKartu;

          if (!resolvedHasKartu) {
            resolvedCardStatus = 'none';
          }
        }
      } catch (_) {
        // Keep fallback from account-details when card-details is unavailable.
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _hasKartu = resolvedHasKartu;
        _cardStatus = resolvedCardStatus.isEmpty ? 'none' : resolvedCardStatus;
        _selectedIndex = 3;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memuat data kartu. Silakan coba lagi.'),
        ),
      );
    } finally {
      if (!mounted) {
        return;
      }

      setState(() {
        _isCheckingKartu = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex.clamp(0, 4);

    if (_selectedIndex == 3) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleKartuTabTap();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade400, width: 1.0),
          ),
        ),
        child: SafeArea(
          child: Container(
            height: 75,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _buildNavItem(
                  svgPath: 'assets/images/beranda.svg',
                  label: "Beranda",
                  index: 0,
                ),
                _buildNavItem(
                  svgPath: 'assets/images/saku.svg',
                  label: "Saku",
                  index: 1,
                ),
                _buildQrisNavItem(),
                _buildNavItem(
                  svgPath: 'assets/images/kartu.svg',
                  label: "Kartu",
                  index: 3,
                  onTap: _handleKartuTabTap,
                  isLoading: _isCheckingKartu,
                ),
                _buildNavItem(
                  svgPath: 'assets/images/lainnya.svg',
                  label: "Lainnya",
                  index: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required String svgPath,
    required String label,
    required int index,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    bool isSelected = _selectedIndex == index;

    Color activeColor = const Color(0xFFFF7F00);
    Color inactiveColor = Colors.black87;

    Color currentColor = isSelected ? activeColor : inactiveColor;

    return GestureDetector(
      onTap:
          onTap ??
          () {
            setState(() {
              _selectedIndex = index;
            });
          },
      child: Container(
        width: 50,
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(currentColor),
                    ),
                  )
                : SvgPicture.asset(
                    svgPath,
                    height: 30,
                    colorFilter: ColorFilter.mode(
                      currentColor,
                      BlendMode.srcIn,
                    ),
                  ),

            const SizedBox(height: 0.1),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: currentColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrisNavItem() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const QrisScreen()),
        );
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [Color(0xFFFF7F00), Color(0xFFFFCA96)],
          ),
        ),
        alignment: Alignment.center,
        child: Image.asset(
          'assets/images/Qris.png',
          height: 20,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
