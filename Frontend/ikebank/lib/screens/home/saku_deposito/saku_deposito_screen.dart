import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../api/banking.dart';
import '../../../widgets/deposito_offer_card.dart';
import '../../../widgets/portfolio_card.dart';
import 'deposito_special_screen.dart';
import 'deposito_detail_screen.dart';

class SakuDepositoScreen extends StatefulWidget {
  const SakuDepositoScreen({super.key});

  @override
  State<SakuDepositoScreen> createState() => _SakuDepositoScreenState();
}

class _SakuDepositoScreenState extends State<SakuDepositoScreen> {
  String _totalAssetDeposito = 'Rp 0';
  bool _isLoadingDeposito = true;
  List<Map<String, dynamic>> _depositoUser = [];
  bool _isLoadingOffers = true;
  List<Map<String, dynamic>> _depositoOffers = [];

  @override
  void initState() {
    super.initState();
    _loadTotalAssetDeposito();
    _loadDepositoOffers();
  }

  Future<void> _loadTotalAssetDeposito() async {
    try {
      final response = await BankingService.depositoUser();
      if (response is! List) {
        return;
      }

      final depositos = response.whereType<Map<String, dynamic>>().toList();
      double total = 0;
      for (final item in depositos) {
        total += _parseAmount(item['balance']);
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _depositoUser = depositos;
        _totalAssetDeposito = _formatRupiah(total);
        _isLoadingDeposito = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingDeposito = false;
      });
      // Keep fallback value when request fails.
    }
  }

  double _parseAmount(dynamic value) {
    final cleaned = (value ?? '0').toString().replaceAll(',', '.').trim();
    return double.tryParse(cleaned) ?? 0;
  }

  String _formatRupiah(double amount) {
    final rounded = amount.round();
    final digits = rounded.toString();

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      final remaining = digits.length - i;
      buffer.write(digits[i]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write('.');
      }
    }
    return 'Rp ${buffer.toString()}';
  }

  String _formatInterestRate(dynamic rawInterestRate) {
    final value = _parseAmount(rawInterestRate);
    final asText = value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value
              .toStringAsFixed(2)
              .replaceFirst(RegExp(r'0+$'), '')
              .replaceFirst(RegExp(r'\.$'), '');

    return '$asText% p.a.';
  }

  String _formatDate(dynamic rawDate) {
    if (rawDate == null) {
      return '-';
    }

    final text = rawDate.toString().trim();
    final parsed = DateTime.tryParse(text);
    if (parsed == null) {
      return text;
    }

    return DateFormat('d MMMM yyyy', 'id_ID').format(parsed);
  }

  int _extractTenorMonths(dynamic rawName) {
    final text = rawName?.toString() ?? '';
    final match = RegExp(r'(\d+)').firstMatch(text);
    return int.tryParse(match?.group(1) ?? '') ?? 1;
  }

  double _estimateAfterTaxInterest(
    double principal,
    double interestRate,
    int tenorMonths,
  ) {
    if (principal <= 0 || interestRate <= 0 || tenorMonths <= 0) {
      return 0;
    }

    const taxFactor = 0.8;
    return principal * (interestRate / 100) * (tenorMonths / 12) * taxFactor;
  }

  Future<void> _loadDepositoOffers() async {
    try {
      final response = await BankingService.DepositoList();
      if (response is! List) {
        return;
      }

      final offers = response
          .whereType<Map<String, dynamic>>()
          .where(
            (offer) =>
                (offer['status']?.toString().toLowerCase() ?? 'active') ==
                'active',
          )
          .toList();

      if (!mounted) {
        return;
      }

      setState(() {
        _depositoOffers = offers;
        _isLoadingOffers = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingOffers = false;
      });
    }
  }

  int _extractQuota(dynamic rawQuota) {
    if (rawQuota == null) {
      return 0;
    }

    if (rawQuota is int) {
      return rawQuota;
    }

    return int.tryParse(rawQuota.toString().trim()) ?? 0;
  }

  String _formatOfferRate(dynamic interestRate) {
    final value = _parseAmount(interestRate);
    final asText = value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value
              .toStringAsFixed(2)
              .replaceFirst(RegExp(r'0+$'), '')
              .replaceFirst(RegExp(r'\.$'), '');

    return '$asText% p.a.';
  }

  String _formatOfferTenor(dynamic months) {
    final tenorMonths = _extractQuota(months);
    return '$tenorMonths Bulan';
  }

  String? _buildSpecialQuotaLabel(dynamic quota) {
    final value = _extractQuota(quota);
    if (value <= 0) {
      return 'Kuota habis';
    }

    return 'Sisa $value Kuota';
  }

  Widget _buildOfferSection() {
    if (_isLoadingOffers) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12.0),
        child: SizedBox(
          height: 120,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_depositoOffers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 4.0),
        child: Text(
          'Belum ada penawaran deposito aktif.',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      );
    }

    return Column(
      children: _depositoOffers.map((offer) {
        final depositoId = _extractQuota(offer['deposito_id']);
        final interestRate = _parseAmount(offer['interest_rate']);
        final tenorMonths = _extractQuota(offer['duratuion_months']);
        final isSpecial = offer['isSpecial'] == true;
        final remainingQuota = _extractQuota(offer['quota']);
        final quotaLabel = _buildSpecialQuotaLabel(offer['quota']);
        final rateText = _formatOfferRate(offer['interest_rate']);
        final tenorText = _formatOfferTenor(offer['duratuion_months']);

        return DepositoOfferCard(
          isSpecial: isSpecial,
          rate: rateText,
          tenor: tenorText,
          specialBadgeLeft: isSpecial ? 'Deposito Spesial' : null,
          specialBadgeRight: isSpecial ? quotaLabel : null,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DepositoSpesialScreen(
                  depositoId: depositoId,
                  sukuBunga: interestRate,
                  jangkaWaktuBulan: tenorMonths,
                  isSpecial: isSpecial,
                  sisaKuota: isSpecial ? remainingQuota : null,
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildPortfolioSection() {
    if (_isLoadingDeposito) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: SizedBox(
          height: 120,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_depositoUser.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: Text(
          'Belum ada deposito aktif.',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: _depositoUser.map((deposito) {
          final namaDeposito =
              deposito['deposito_name']?.toString().trim().isNotEmpty == true
              ? deposito['deposito_name'].toString()
              : 'Deposito';
          final jumlahPenempatan = _parseAmount(deposito['balance']);
          final interestRateValue = _parseAmount(deposito['interest_rate']);
          final tenorMonths = _extractTenorMonths(deposito['deposito_name']);
          final bungaRate = _formatInterestRate(deposito['interest_rate']);
          final tanggalMulai = _formatDate(deposito['start_date']);
          final tanggalJatuhTempo = _formatDate(deposito['end_date']);
          final bungaSetelahPajak = _estimateAfterTaxInterest(
            jumlahPenempatan,
            interestRateValue,
            tenorMonths,
          );

          return PortfolioCard(
            imageAsset: 'assets/images/deposito.png',
            amount: _formatRupiah(jumlahPenempatan),
            title: namaDeposito,
            rate: bungaRate,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DepositoDetailScreen(
                    namaDeposito: namaDeposito,
                    jumlahPenempatan: jumlahPenempatan,
                    bungaSetelahPajak: bungaSetelahPajak,
                    tanggalMulai: tanggalMulai,
                    tanggalJatuhTempo: tanggalJatuhTempo,
                    isFromPortfolio: true,
                    sukuBunga: interestRateValue,
                    jangkaWaktuBulan: tenorMonths,
                    depositoUUID:
                        deposito['deposito_account_id']?.toString() ??
                        deposito['deposito_uuid']?.toString() ??
                        '',
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0x1AFFCA96),
        elevation: 0,
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Saku Deposito",
          style: TextStyle(
            fontFamily: 'AlumniSans',
            fontWeight: FontWeight.w800,
            fontSize: 24,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: 80,
              color: const Color(0x1AFFCA96),
            ),

            SingleChildScrollView(
              padding: const EdgeInsets.only(top: 8.0, bottom: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Container(
                      width: double.infinity,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14.5),
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Dana Deposito",
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _totalAssetDeposito,
                                      style: const TextStyle(
                                        fontFamily: 'AlumniSans',
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFFFF7F00),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: 90,
                              height: double.infinity,
                              margin: const EdgeInsets.only(right: 20),
                              decoration: const BoxDecoration(
                                color: Color(0xFFCCCCFF),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(80),
                                  bottomRight: Radius.circular(80),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Image.asset(
                                'assets/images/deposito.png',
                                width: 65,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Penawaran Deposito",
                          style: TextStyle(
                            fontFamily: 'AlumniSans',
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFFF7F00),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildOfferSection(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 1),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      "Portofolio",
                      style: TextStyle(
                        fontFamily: 'AlumniSans',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFFF7F00),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPortfolioSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
