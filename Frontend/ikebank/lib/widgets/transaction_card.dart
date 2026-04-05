import 'package:flutter/material.dart';

class TransactionCard extends StatelessWidget {
  final String title;
  final String subTitle;
  final String amount;
  final String time;
  final IconData? icon;
  final String? imageAsset;
  final bool isExpense;

  const TransactionCard({
    super.key,
    required this.title,
    required this.subTitle,
    required this.amount,
    required this.time,
    this.icon,
    this.imageAsset,
    this.isExpense = true, 
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: const Color(0x80F69500), 
              borderRadius: BorderRadius.circular(16),
            ),
            child: imageAsset != null
                ? Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Image.asset(imageAsset!, fit: BoxFit.contain),
                  )
                : Icon(icon ?? Icons.arrow_forward, color: const Color(0xFFFF7F00), size: 28),
          ),
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 4),
                Text(
                  subTitle,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              ],
            ),
          ),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isExpense ? Colors.grey : const Color(0xFF00B14F), 
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: const TextStyle(fontSize: 14, color: Colors.black),
              ),
            ],
          ),
        ],
      ),
    );
  }
}