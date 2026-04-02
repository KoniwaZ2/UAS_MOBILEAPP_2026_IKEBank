import 'package:flutter/material.dart';
import '../../../core/colors.dart'; 

class TipsInfoScreen extends StatelessWidget {
  const TipsInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextStyle alumniSansBold = const TextStyle(
      fontWeight: FontWeight.w700,
      fontFamily: 'AlumniSans',
    );

    final List<Map<String, String>> tipsData = [
      {
        'title': 'Waspada penipuan digital',
        'desc': 'Jangan pernah membagikan OTP, PIN dan Password ke orang yang tidak dikenal',
      },
      {
        'title': 'Gratis Biaya Admin',
        'desc': 'Semua layanan bebas biaya di IKE Bank',
      },
      {
        'title': 'Waspada penipuan digital',
        'desc': 'Jangan pernah membagikan OTP, PIN dan Password ke orang yang tidak dikenal',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: AppColors.primaryOrange,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28), 
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Tips & Info",
          style: alumniSansBold.copyWith(fontSize: 28, color: Colors.white), 
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        itemCount: tipsData.length,
        itemBuilder: (context, index) {
          final tip = tipsData[index];
          return _buildTipCard(
            title: tip['title']!,
            desc: tip['desc']!,
            titleStyle: alumniSansBold,
          );
        },
      ),
    );
  }

  Widget _buildTipCard({
    required String title,
    required String desc,
    required TextStyle titleStyle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), 
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: titleStyle.copyWith(fontSize: 18, color: Colors.black),
          ),
          const SizedBox(height: 3),
          Text(
            desc,
            style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.4),
          ),
        ],
      ),
    );
  }
}