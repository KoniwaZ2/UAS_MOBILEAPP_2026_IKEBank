import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DetailKartu2Screen extends StatelessWidget {
  const DetailKartu2Screen({super.key});

  static const primaryColor = Color(0xFFFF7F00);
  static const boxColor = Color(0xFFEBD7C3);

  Widget infoBox(
    BuildContext context,
    String label,
    String value, {
    bool copy = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 20,
          ),
        ),

        const SizedBox(height: 6),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
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
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              color: primaryColor,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.white),
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

                      infoBox(
                        context,
                        "No. Kartu",
                        "6067 - 6769 - 1789 - 6767",
                        copy: true,
                      ),

                      infoBox(
                        context,
                        "Masa Berlaku",
                        "03/31",
                      ),

                      infoBox(
                        context,
                        "Kode CVV",
                        "690",
                      ),
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