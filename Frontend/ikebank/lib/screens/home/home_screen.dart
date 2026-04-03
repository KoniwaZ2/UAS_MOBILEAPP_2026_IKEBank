import 'package:flutter/material.dart';
import '../../../core/colors.dart'; 
import 'package:flutter/services.dart'; 
import 'package:flutter_svg/flutter_svg.dart';
import 'notification_screen.dart';
import 'reward_screen.dart'; 
import 'tambah_dana_screen.dart';
import 'tips_info_screen.dart';
import 'promo_screen.dart';
import 'saku_utama/saku_utama_screen.dart';
import 'layanan/cash_flow_screen.dart';
import 'layanan/beli_bayar_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextStyle alumniSansBold = const TextStyle(
    fontWeight: FontWeight.w700,
    fontFamily: 'AlumniSans',
  );

  bool _isBalanceVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(), 
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 120, 
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
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/IKEHome.png',
                              height:65,
                              width: 85,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  "Jacob Sins",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18  , 
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'AlumniSans',
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Clipboard.setData(const ClipboardData(text: "10095653346")).then((_) {
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xCCD9D9D9),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const Text(
                                          "10095653346",
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
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const RewardScreen()),
                                );
                              },
                              child: SvgPicture.asset(
                                'assets/images/present.svg',
                                height: 26,
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const NotificationScreen()),
                                );
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

                  const SizedBox(height: 16),

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
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                              gradient: LinearGradient(
                                colors: [Color(0xFF01008A), Color(0xFF5D5CF6)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Total dana", style: TextStyle(fontSize: 30, color: Colors.black)),
                                const SizedBox(height: 4),
                                
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center, 
                                  children: [
                                    Text(
                                      _isBalanceVisible ? "Rp 200.000.000" : "Rp •••••••••",
                                      style: alumniSansBold.copyWith(fontSize: 30, color: Colors.black),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _isBalanceVisible = !_isBalanceVisible;
                                        });
                                      },
                                      child: Icon(
                                        _isBalanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
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
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => const TambahDanaScreen()),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _buildActionBtn(
                                        icon: Icons.arrow_forward, 
                                        label: "Transfer & Bayar",
                                        onTap: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text("Menuju Transfer & Bayar...")),
                                          );
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
                        Text("Layanan", style: alumniSansBold.copyWith(fontSize: 20, color: Colors.black)),
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
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const SakuUtamaScreen()),
                                );
                              }
                            ),
                            _buildServiceItem(imagePath: 'assets/images/celengan.png', label: "Saku Celengan", iconSize: 38),
                            _buildServiceItem(imagePath: 'assets/images/deposito.png', label: "Saku Deposito", iconSize: 38),
                            _buildServiceItem(
                              imagePath: 'assets/images/CashF.png', 
                              label: "Cash Flow", 
                              iconSize: 38,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const CashFlowScreen()),
                                );
                              }
                            ),

                            _buildServiceItem(
                              imagePath: 'assets/images/bill.png', 
                              label: "Beli & Bayar",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const BeliBayarScreen()),
                                );
                              }
                            ),
                            _buildServiceItem(imagePath: 'assets/images/CS.png', label: "Bantuan CS"),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 4),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Promo buat kamu 👀", style: alumniSansBold.copyWith(fontSize: 18, color: Colors.black)),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const PromoScreen()),
                            );
                          },
                          child: const Text("Lihat Semua", style: TextStyle(color: AppColors.primaryOrange, fontSize: 18)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 90,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      scrollDirection: Axis.horizontal,
                      itemCount: 2,
                      itemBuilder: (context, index) {
                        return _buildPromoCard();
                      },
                    ),
                  ),

                  const SizedBox(height: 14),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Tips & Info", style: alumniSansBold.copyWith(fontSize: 18, color: Colors.black)),
                        
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const TipsInfoScreen()),
                            );
                          },
                          child: const Text(
                            "Lihat Semua", 
                            style: TextStyle(color: AppColors.primaryOrange, fontSize: 18)
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
                          Text("Waspada penipuan digital", style: alumniSansBold.copyWith(fontSize: 16, color: Colors.black)),
                          const SizedBox(height: 4),
                          const Text(
                            "Jangan pernah membagikan OTP, PIN dan Password ke orang yang tidak dikenal",
                            style: TextStyle(fontSize: 15, color: Colors.black87),
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
    );
  }

  Widget _buildActionBtn({required IconData icon, required String label, required VoidCallback onTap}) {
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
            Text(label, style: const TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceItem({required String imagePath, required String label, double iconSize = 28, VoidCallback? onTap}) {
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
            child: Image.asset(imagePath, height: iconSize, fit: BoxFit.contain), 
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PromoScreen()),
        );
      },
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias, 
        child: Image.asset(
          'assets/images/promo.png', 
          fit: BoxFit.cover, 
          errorBuilder: (context, error, stackTrace) {
            return Container(color: Colors.grey.shade300);
          },
        ),
      ),
    );
  }
}