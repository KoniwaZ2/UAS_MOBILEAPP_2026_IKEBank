import 'package:flutter/material.dart';
import '../../../core/colors.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'notification_screen.dart';
import 'tambah_dana_screen.dart';
import 'tips_info_screen.dart';
import 'saku_utama/saku_utama_screen.dart';
import 'saku_celengan/saku_celengan_screen.dart';
import 'saku_deposito/saku_deposito_screen.dart';
import 'layanan/cash_flow_screen.dart';
import 'layanan/beli_bayar_screen.dart';
import 'layanan/bantuan_cs_screen.dart';
import '../../api/banking.dart';
import '../../models/account_detail.dart';

enum HomeEntrySource { register, login }

class HomeScreen extends StatefulWidget {
  final HomeEntrySource entrySource;

  const HomeScreen({super.key, this.entrySource = HomeEntrySource.login});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextStyle alumniSansBold = const TextStyle(
    fontWeight: FontWeight.w700,
    fontFamily: 'AlumniSans',
  );

  bool _isBalanceVisible = true;
  AccountDetail? _primaryAccount;

  void _handleAccountDataChanged() {
    if (!mounted) {
      return;
    }
    _runInitialHomeApi();
  }

  Future<void> _openAndRefresh(Future<dynamic> Function() openRoute) async {
    await openRoute();

    if (mounted) {
      await _runInitialHomeApi();
    }
  }

  @override
  void initState() {
    super.initState();
    BankingService.accountDataRevision.addListener(_handleAccountDataChanged);
    _runInitialHomeApi();
  }

  @override
  void dispose() {
    BankingService.accountDataRevision.removeListener(
      _handleAccountDataChanged,
    );
    super.dispose();
  }

  Future<void> _runInitialHomeApi() async {
    try {
      // if (widget.entrySource == HomeEntrySource.register) {
      //   await BankingService.registerAccount();
      // }

      final accountDetails = await BankingService.fetchAccountDetails();

      if (mounted) {
        setState(() {
          _primaryAccount = accountDetails.isNotEmpty
              ? accountDetails.first
              : null;
        });
      }
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatRupiah(String rawBalance) {
    final clean = rawBalance.replaceAll(',', '.').trim();
    final value = double.tryParse(clean) ?? 0;
    final rounded = value.round();
    final digits = rounded.toString();

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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),

      body: RefreshIndicator(
        onRefresh: _runInitialHomeApi,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 140,
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.primaryOrange,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(55),
                      bottomRight: Radius.circular(55),
                    ),
                  ),
                ),
              ),

              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 8.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/IKEHome.png',
                                height: 65,
                                width: 85,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    (_primaryAccount?.username.isNotEmpty ??
                                            false)
                                        ? _primaryAccount!.username
                                        : 'Pengguna',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'AlumniSans',
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Clipboard.setData(
                                        ClipboardData(
                                          text:
                                              _primaryAccount?.accountnumber ??
                                              '-',
                                        ),
                                      ).then((_) {});
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xCCD9D9D9),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            _primaryAccount?.accountnumber ??
                                                '-',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'AlumniSans',
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          SvgPicture.asset(
                                            'assets/images/copy.svg',
                                            height: 14,
                                            colorFilter: const ColorFilter.mode(
                                              Colors.white,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  await _openAndRefresh(() {
                                    return Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const NotificationScreen(),
                                      ),
                                    );
                                  });
                                },
                                child: SvgPicture.asset(
                                  'assets/images/notif.svg',
                                  height: 26,
                                  colorFilter: const ColorFilter.mode(
                                    Colors.white,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 2),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 15,
                              spreadRadius: 2,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 25,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF01008A),
                                    Color(0xFF5D5CF6),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                16.0,
                                12.0,
                                16.0,
                                16.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Total dana",
                                    style: TextStyle(
                                      fontSize: 26,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        _isBalanceVisible
                                            ? _formatRupiah(
                                                _primaryAccount?.balance ?? '0',
                                              )
                                            : "Rp •••••••••",
                                        style: alumniSansBold.copyWith(
                                          fontSize: 28,
                                          color: Colors.black,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _isBalanceVisible =
                                                !_isBalanceVisible;
                                          });
                                        },
                                        child: Icon(
                                          _isBalanceVisible
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          color: Colors.black87,
                                          size: 28,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildActionBtn(
                                          icon: Icons.add,
                                          label: "Tambah dana",
                                          onTap: () async {
                                            await _openAndRefresh(() {
                                              return Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const TambahDanaScreen(),
                                                ),
                                              );
                                            });
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: _buildActionBtn(
                                          icon: Icons.arrow_forward,
                                          label: "Transfer & Bayar",
                                          onTap: () async {
                                            await _openAndRefresh(() {
                                              return Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const BeliBayarScreen(),
                                                ),
                                              );
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Layanan",
                            style: alumniSansBold.copyWith(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 10),
                          GridView.count(
                            crossAxisCount: 3,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 3,
                            crossAxisSpacing: 5,
                            childAspectRatio: 1.3,
                            children: [
                              _buildServiceItem(
                                imagePath: 'assets/images/IKEHome.png',
                                label: "Saku Utama",
                                onTap: () async {
                                  await _openAndRefresh(() {
                                    return Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SakuUtamaScreen(),
                                      ),
                                    );
                                  });
                                },
                              ),
                              _buildServiceItem(
                                imagePath: 'assets/images/celengan.png',
                                label: "Saku Celengan",
                                iconSize: 38,
                                onTap: () async {
                                  await _openAndRefresh(() {
                                    return Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SakuCelenganScreen(),
                                      ),
                                    );
                                  });
                                },
                              ),

                              _buildServiceItem(
                                imagePath: 'assets/images/deposito.png',
                                label: "Saku Deposito",
                                iconSize: 38,
                                onTap: () async {
                                  await _openAndRefresh(() {
                                    return Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SakuDepositoScreen(),
                                      ),
                                    );
                                  });
                                },
                              ),
                              _buildServiceItem(
                                imagePath: 'assets/images/CashF.png',
                                label: "Cash Flow",
                                iconSize: 38,
                                onTap: () async {
                                  await _openAndRefresh(() {
                                    return Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const CashFlowScreen(),
                                      ),
                                    );
                                  });
                                },
                              ),

                              _buildServiceItem(
                                imagePath: 'assets/images/bill.png',
                                label: "Beli & Bayar",
                                onTap: () async {
                                  await _openAndRefresh(() {
                                    return Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const BeliBayarScreen(),
                                      ),
                                    );
                                  });
                                },
                              ),
                              _buildServiceItem(
                                imagePath: 'assets/images/CS.png',
                                label: "Bantuan CS",
                                onTap: () async {
                                  await _openAndRefresh(() {
                                    return Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const BantuanCsScreen(),
                                      ),
                                    );
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 4),
                    const SizedBox(height: 14),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Tips & Info",
                            style: alumniSansBold.copyWith(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),

                          GestureDetector(
                            onTap: () async {
                              await _openAndRefresh(() {
                                return Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const TipsInfoScreen(),
                                  ),
                                );
                              });
                            },
                            child: const Text(
                              "Lihat Semua",
                              style: TextStyle(
                                color: AppColors.primaryOrange,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Waspada penipuan digital",
                              style: alumniSansBold.copyWith(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Jangan pernah membagikan OTP, PIN dan Password ke orang yang tidak dikenal",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // HELPER WIDGETS

  Widget _buildActionBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primaryOrange.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primaryOrange, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.primaryOrange,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceItem({
    required String imagePath,
    required String label,
    double iconSize = 28,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 52,
            decoration: const BoxDecoration(
              color: Color(0xFFDCD6FF),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(10),
                bottom: Radius.circular(25),
              ),
            ),
            alignment: Alignment.center,
            child: Image.asset(
              imagePath,
              height: iconSize,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
