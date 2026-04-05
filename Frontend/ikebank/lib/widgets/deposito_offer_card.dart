import 'package:flutter/material.dart';

class DepositoOfferCard extends StatelessWidget {
  final bool isSpecial;
  final String rate;
  final String tenor;
  final VoidCallback onTap;
  final String? specialBadgeLeft;
  final String? specialBadgeRight;

  const DepositoOfferCard({
    super.key,
    this.isSpecial = false,
    required this.rate,
    required this.tenor,
    required this.onTap,
    this.specialBadgeLeft,
    this.specialBadgeRight,
  });

  @override
  Widget build(BuildContext context) {
    if (isSpecial) {
      return Container(
        margin: const EdgeInsets.only(top: 8, bottom: 12), 
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16), 
                decoration: BoxDecoration(
                  color: const Color(0xFFFF7F00), 
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE67300), width: 1.5), 
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rate,
                          style: const TextStyle(fontFamily: 'AlumniSans', fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF1A36DF)), 
                        ),
                        Text(
                          tenor,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A36DF)),
                        ),
                      ],
                    ),
                    Row(
                      children: const [
                        Text("Buka Deposito", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A36DF))),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios, size: 1, color: Color(0xFF1A36DF)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (specialBadgeLeft != null)
              Positioned(
                top: -10, left: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A36DF),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                  ),
                  child: Text(specialBadgeLeft!, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                ),
              ),
            if (specialBadgeRight != null)
              Positioned(
                top: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A36DF),
                    borderRadius: BorderRadius.only(topRight: Radius.circular(16), bottomLeft: Radius.circular(12)),
                  ),
                  child: Text(specialBadgeRight!, style: const TextStyle(color: Color(0xFFFF7F00), fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300, width: 1.5), 
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 3)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rate,
                  style: const TextStyle(fontFamily: 'AlumniSans', fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFFFF7F00)),
                ),
                Text(
                  tenor,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ],
            ),
            Row(
              children: const [
                Text("Buka Deposito", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFFF7F00))),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFFF7F00)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}