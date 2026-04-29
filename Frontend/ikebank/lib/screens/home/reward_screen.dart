import 'package:flutter/material.dart';
import '../../../core/colors.dart';
import '../bottomnav/qris/qris_screen.dart';
import 'saku_deposito/saku_deposito_screen.dart';

class RewardScreen extends StatelessWidget {
  const RewardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextStyle alumniSansBold = const TextStyle(
      fontWeight: FontWeight.w700,
      fontFamily: 'AlumniSans',
    );

    // Data Dummy 
    final List<Map<String, dynamic>> rewards = [
      {
        'target': 'deposito',
        'title': 'Cashback Rp50.000',
        'desc': 'Buka Deposito dengan tenor 3 Bulan minimum penempatan Rp100.000.000 dan tahan investasimu hingga jatuh tempo.',
        'badge': '1x',
      },
      {
        'target': 'qris',
        'title': 'Cashback Rp1.500',
        'desc': 'Transaksi dengan QRIS minimal Rp50.000 dan dapatkan cashback Rp1.500.\nMaksimal 1x/hari dan 3x/bulan',
        'badge': '3x',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Reward",
          style: alumniSansBold.copyWith(fontSize: 28, color: Colors.black),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 5.0),
        itemCount: rewards.length,
        itemBuilder: (context, index) {
          final reward = rewards[index];
          return _buildRewardCard(
            context: context,
            title: reward['title'],
            desc: reward['desc'],
            badge: reward['badge'],
            titleStyle: alumniSansBold,
            onTapMisi: () {
              if (reward['target'] == 'deposito') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SakuDepositoScreen()),
                );
              } else if (reward['target'] == 'qris') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QrisScreen()),
                );
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildRewardCard({
    required BuildContext context,
    required String title,
    required String desc,
    required String badge,
    required TextStyle titleStyle,
    required VoidCallback onTapMisi,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: titleStyle.copyWith(fontSize: 24, color: Colors.black),
                ),
                const SizedBox(height: 8),
                
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center, 
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        desc,
                        style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: onTapMisi, 
                        child: const Text(
                          "Ikuti Misi",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: AppColors.primaryOrange,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: const BoxDecoration(
                color: AppColors.primaryOrange,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(16), 
                  bottomLeft: Radius.circular(12), 
                ),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Color(0xFF01008A), 
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}