import 'package:flutter/material.dart';
import '13.1_pin_limit_harian_screen.dart';
import '../../../api/banking.dart';

class LimitHarianScreen extends StatefulWidget {
  const LimitHarianScreen({super.key});

  @override
  State<LimitHarianScreen> createState() => _LimitHarianScreenState();
}

class _LimitHarianScreenState extends State<LimitHarianScreen> {
  final TextEditingController harian = TextEditingController();
  final TextEditingController tunggal = TextEditingController();
  final TextEditingController tarik = TextEditingController();
  bool _isLoading = false;
  int _dailyTransactionLimit = 0;
  int _dailySingleTransactionLimit = 0;
  int _dailyWithdrawalLimit = 0;

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
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => '.',
    );
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
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    });
  }

  void _syncControllers() {
    harian.text = format(_dailyTransactionLimit);
    tunggal.text = format(_dailySingleTransactionLimit);
    tarik.text = format(_dailyWithdrawalLimit);
  }

  Future<void> _loadDailyLimit() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await BankingService.getDailyLimit();
      if (!mounted) {
        return;
      }

      if (result is Map<String, dynamic>) {
        _dailyTransactionLimit =
            int.tryParse(result['daily_transaction_limit']?.toString() ?? '') ??
            0;
        _dailySingleTransactionLimit =
            int.tryParse(
              result['daily_single_transaction_limit']?.toString() ?? '',
            ) ??
            0;
        _dailyWithdrawalLimit =
            int.tryParse(result['daily_withdrawal_limit']?.toString() ?? '') ??
            0;

        _syncControllers();
      }
    } catch (_) {
      // Keep default values when API is unavailable.
    } finally {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });
    }
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

    _loadDailyLimit();
  }

  @override
  void dispose() {
    harian.dispose();
    tunggal.dispose();
    tarik.dispose();
    super.dispose();
  }

  Widget field(String title, TextEditingController controller, int max) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),

        const SizedBox(height: 1),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Text(
                "Rupiah",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
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

        const SizedBox(height: 1),

        Text(
          "Batas maksimum: Rp${format(max)}",
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),

        const SizedBox(height: 10),
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              color: const Color(0xFFFF7F00),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Expanded(
                    child: Text(
                      "Atur batas transaksi",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Untuk keamanan akunmu, transaksi yang melebihi jumlah ini akan otomatis dibatalkan.",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black87,
                                  height: 1.5,
                                ),
                              ),

                              const SizedBox(height: 24),

                              field("Batas harian", harian, maxHarian),
                              field("Batas transaksi tunggal", tunggal, maxTunggal),
                              field("Batas tarik tunai harian", tarik, maxTarik),

                              const Spacer(),

                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Container(
                                  width: double.infinity,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: _isLoading
                                        ? Colors.grey
                                        : const Color(0xFFFF7F00),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(30),
                                      onTap: _isLoading
                                          ? null
                                          : () {
                                              _dailyWithdrawalLimit = parse(tarik.text);
                                              _dailyTransactionLimit = parse(harian.text);
                                              _dailySingleTransactionLimit = parse(tunggal.text);

                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => PinLimitHarianScreen(
                                                    dailyWithdrawalLimit: _dailyWithdrawalLimit,
                                                    dailyTransactionLimit: _dailyTransactionLimit,
                                                    dailySingleTransactionLimit: _dailySingleTransactionLimit,
                                                  ),
                                                ),
                                              );
                                            },
                                      child: Center(
                                        child: _isLoading
                                            ? const SizedBox(
                                                height: 24,
                                                width: 24,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2.5,
                                                  valueColor: AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                                ),
                                              )
                                            : const Text(
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
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}