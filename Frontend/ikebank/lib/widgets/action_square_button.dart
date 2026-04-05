import 'package:flutter/material.dart';

class ActionSquareButton extends StatelessWidget {
  final String imageAsset; 
  final String label;
  final VoidCallback onTap;
  final double imageHeight; 

  const ActionSquareButton({
    super.key,
    required this.imageAsset,
    required this.label,
    required this.onTap,
    this.imageHeight = 50, 
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 105, 
        height: 110, 
        padding: const EdgeInsets.only(left: 4, right: 4, bottom: 12), 
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), 
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end, 
          children: [
            Image.asset(imageAsset, height: imageHeight, fit: BoxFit.contain), 
            const SizedBox(height: 10), 
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}