import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DetailKartu2Screen extends StatelessWidget {
  final Map<String, dynamic> cardDetails;

  const DetailKartu2Screen({super.key, required this.cardDetails});

  static const primaryColor = Color(0xFFFF7F00);
  static const boxColor = Color(0xFFEBD7C3);

  String _formatCardNumber(String cardNumber) {
    final digits = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 16) {
      return cardNumber;
    }

    final parts = [
      digits.substring(0, 4),
      digits.substring(4, 8),
      digits.substring(8, 12),
      digits.substring(12, 16),
    ];

    return parts.join(' - ');
  }

  String _formatExpiryDate(String rawDate) {
    final value = rawDate.trim();
    if (value.isEmpty) {
      return '-';
    }

    if (value.contains('-')) {
      final parts = value.split('-');
      if (parts.length == 3) {
        final year = parts[0];
        final month = parts[1];
        if (year.length >= 4 && month.length == 2) {
          return '$month/${year.substring(2, 4)}';
        }
      }
    }

    return value;
  }

  Widget infoBox(
    BuildContext context,
    String label,
    String value, {
    bool copy = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 20)),

        const SizedBox(height: 6),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: boxColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: copy ? Colors.blueAccent : Colors.black,
                  letterSpacing: copy ? 1.5 : 0,
                ),
              ),

              if (copy)
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: value));

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Nomor kartu disalin"),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: SvgPicture.asset(
                    "assets/images/copypaste.svg",
                    width: 20,
                    colorFilter: const ColorFilter.mode(
                      Colors.black,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 18),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardNumberRaw = (cardDetails['card_number'] ?? '').toString().trim();
    final expiryRaw = (cardDetails['expiry_date'] ?? '').toString().trim();
    final ccvRaw = (cardDetails['ccv'] ?? cardDetails['cvv'] ?? '')
        .toString()
        .trim();
    final cardStatus = (cardDetails['card_status'] ?? '-').toString().trim();

    final cardNumber = cardNumberRaw.isEmpty
        ? '-'
        : _formatCardNumber(cardNumberRaw);
    final expiryDate = expiryRaw.isEmpty ? '-' : _formatExpiryDate(expiryRaw);
    final ccv = ccvRaw.isEmpty ? '-' : ccvRaw;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              color: primaryColor,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Expanded(
                    child: Text(
                      "Detail Kartu Debit IKE Bank",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // BODY
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // 🔥 CARD
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.asset(
                          "assets/images/debit.png",
                          width: double.infinity,
                          height: 280,
                          fit: BoxFit.cover,
                        ),
                      ),

                      const SizedBox(height: 24),

                      infoBox(context, "No. Kartu", cardNumber, copy: true),

                      infoBox(context, "Masa Berlaku", expiryDate),

                      infoBox(context, "Kode CVV", ccv),
                    ],
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
