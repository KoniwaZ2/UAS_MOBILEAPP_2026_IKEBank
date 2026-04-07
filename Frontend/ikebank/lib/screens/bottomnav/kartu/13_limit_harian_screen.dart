import 'package:flutter/material.dart';
import '13.1_pin_limit_harian_screen.dart';

class LimitHarianScreen extends StatefulWidget {
  const LimitHarianScreen({super.key});

  @override
  State<LimitHarianScreen> createState() =>
      _LimitHarianScreenState();
}

class _LimitHarianScreenState extends State<LimitHarianScreen> {
  final TextEditingController harian = TextEditingController();
  final TextEditingController tunggal = TextEditingController();
  final TextEditingController tarik = TextEditingController();

  final int maxHarian = 50000000;
  final int maxTunggal = 50000000;
  final int maxTarik = 15000000;

  String format(dynamic val) {
    if (val == null) return "0";

    int number = 0;

    if (val is int) {
      number = val;
    } else {
      number = int.tryParse(val.toString()) ?? 0;
    }

    return number.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');
  }

  int parse(String val) {
    return int.tryParse(val.replaceAll('.', '')) ?? 0;
  }

  void setupController(TextEditingController controller, int max) {
    controller.addListener(() {
      int val = parse(controller.text);

      if (val > max) val = max;

      final formatted = format(val);

      if (controller.text != formatted) {
        controller.value = TextEditingValue(
          text: formatted,
          selection:
              TextSelection.collapsed(offset: formatted.length),
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();

    harian.text = "0";
    tunggal.text = "0";
    tarik.text = "0";

    setupController(harian, maxHarian);
    setupController(tunggal, maxTunggal);
    setupController(tarik, maxTarik);
  }

  Widget field(String title, TextEditingController controller, int max) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Text(
                "Rupiah",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 10),

              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "0",
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 6),

        Text(
          "Batas maksimum: Rp${format(max)}",
          style: const TextStyle(
            fontSize: 20,
            color: Colors.black54,
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              color: const Color(0xFFFF7F00),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.white),
                  ),
                  const Expanded(
                    child: Text(
                      "Atur batas transaksi BI-Fast",
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
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Untuk keamanan akunmu, transaksi yang melebihi jumlah ini akan otomatis dibatalkan.",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 24),

                    field("Batas harian", harian, maxHarian),
                    field("Batas transaksi tunggal", tunggal, maxTunggal),
                    field("Batas tarik tunai harian", tarik, maxTarik),

                    const Spacer(),

                    // BUTTON
                    Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF7F00),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const PinLimitHarianScreen(),
                              ),
                            );
                          },
                          child: const Center(
                            child: Text(
                              "Simpan",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}