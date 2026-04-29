import 'package:flutter/material.dart';

class PortfolioCard extends StatelessWidget {
  final String imageAsset;
  final String amount;
  final String title;
  final String rate;
  final VoidCallback onTap;
  final EdgeInsetsGeometry margin;

  const PortfolioCard({
    super.key,
    required this.imageAsset,
    required this.amount,
    required this.title,
    required this.rate,
    required this.onTap,
    this.margin = const EdgeInsets.only(right: 36),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: margin,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8F0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Transform.scale(
                    scale: 1.4,
                    child: Image.asset(
                      imageAsset,
                      height: 45,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    amount,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 1),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              rate,
              style: const TextStyle(fontSize: 18, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
