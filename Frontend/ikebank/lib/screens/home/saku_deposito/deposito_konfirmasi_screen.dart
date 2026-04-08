import 'package:flutter/material.dart';
import '../../../api/banking.dart';
import 'deposito_detail_screen.dart';

class DepositoKonfirmasiScreen extends StatefulWidget {
  final int depositoId;
  final int sourceSakuId;
  final double jumlahPenempatan;
  final double sukuBunga;
  final int jangkaWaktuBulan;

  const DepositoKonfirmasiScreen({
    super.key,
    required this.depositoId,
    required this.sourceSakuId,
    required this.jumlahPenempatan,
    required this.sukuBunga,
    required this.jangkaWaktuBulan,
  });

  @override
  State<DepositoKonfirmasiScreen> createState() =>
      _DepositoKonfirmasiScreenState();
}

class _DepositoKonfirmasiScreenState extends State<DepositoKonfirmasiScreen> {
  final double pajakBunga = 20.0;
  bool _isSubmitting = false;

  late DateTime tanggalMulai;
  late DateTime tanggalJatuhTempo;
  late int jumlahHari;

  late double bungaSebelumPajak;
  late double nominalPajak;
  late double bungaSetelahPajak;
  late double estimasiTotal;

  @override
  void initState() {
    super.initState();
    _kalkulasiDeposito();
  }

  DateTime _tambahBulanDenganClamp(DateTime tanggal, int bulanTambahan) {
    final int totalBulan = (tanggal.month - 1) + bulanTambahan;
    final int targetYear = tanggal.year + (totalBulan ~/ 12);
    final int targetMonth = (totalBulan % 12) + 1;
    final int hariTerakhirBulanTarget = DateTime(
      targetYear,
      targetMonth + 1,
      0,
    ).day;
    final int targetDay = tanggal.day > hariTerakhirBulanTarget
        ? hariTerakhirBulanTarget
        : tanggal.day;

    return DateTime(
      targetYear,
      targetMonth,
      targetDay,
      tanggal.hour,
      tanggal.minute,
      tanggal.second,
      tanggal.millisecond,
      tanggal.microsecond,
    );
  }

  void _kalkulasiDeposito() {
    tanggalMulai = DateTime.now();
    tanggalJatuhTempo = _tambahBulanDenganClamp(
      tanggalMulai,
      widget.jangkaWaktuBulan,
    );
    jumlahHari = tanggalJatuhTempo.difference(tanggalMulai).inDays;

    bungaSebelumPajak =
        (widget.jumlahPenempatan * (widget.sukuBunga / 100) * jumlahHari) / 365;
    nominalPajak = bungaSebelumPajak * (pajakBunga / 100);
    bungaSetelahPajak = bungaSebelumPajak - nominalPajak;
    estimasiTotal = widget.jumlahPenempatan + bungaSetelahPajak;
  }

  String _formatRp(double value) {
    String strValue = value.toInt().toString();
    String result = '';
    int count = 0;
    for (int i = strValue.length - 1; i >= 0; i--) {
      result = strValue[i] + result;
      count++;
      if (count % 3 == 0 && i != 0) {
        result = '.$result';
      }
    }
    return "Rp$result";
  }

  String _formatTanggal(DateTime date) {
    List<String> namaBulan = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return "${date.day} ${namaBulan[date.month]} ${date.year}";
  }

  Future<void> _submitDeposito() async {
    if (_isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final result = await BankingService.buatDeposito(
        depositoId: widget.depositoId,
        sourceSakuId: widget.sourceSakuId,
        amount: widget.jumlahPenempatan.round(),
      );

      if (!mounted) {
        return;
      }

      final namaDeposito = (result['deposito_name'] ?? 'Deposito').toString();
      final rawStartDate = (result['start_date'] ?? '').toString();
      final rawEndDate = (result['end_date'] ?? '').toString();
      final parsedStartDate = DateTime.tryParse(rawStartDate) ?? tanggalMulai;
      final parsedEndDate = DateTime.tryParse(rawEndDate) ?? tanggalJatuhTempo;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DepositoDetailScreen(
            namaDeposito: namaDeposito,
            jumlahPenempatan: widget.jumlahPenempatan,
            bungaSetelahPajak: bungaSetelahPajak,
            tanggalMulai: _formatTanggal(parsedStartDate),
            tanggalJatuhTempo: _formatTanggal(parsedEndDate),
            sukuBunga: widget.sukuBunga,
            jangkaWaktuBulan: widget.jangkaWaktuBulan,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Deposito Spesial",
          style: TextStyle(
            fontFamily: 'AlumniSans',
            fontWeight: FontWeight.w800,
            fontSize: 24,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        "Cek lagi sebelum konfirmasi, ya",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    const Text(
                      "Estimasi dana saat jatuh tempo",
                      style: TextStyle(fontSize: 24, color: Colors.black),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatRp(estimasiTotal),
                      style: const TextStyle(
                        fontFamily: 'AlumniSans',
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFFF7F00),
                      ),
                    ),
                    const SizedBox(height: 32),

                    const Text(
                      "Rincian Deposito",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildDetailRow(
                      "Jumlah penempatan",
                      _formatRp(widget.jumlahPenempatan),
                    ),
                    _buildDetailRow("Suku bunga (p.a)", "${widget.sukuBunga}%"),
                    _buildDetailRow(
                      "Bunga sebelum pajak",
                      _formatRp(bungaSebelumPajak),
                    ),
                    _buildDetailRow(
                      "Pajak bunga (20%)",
                      "-${_formatRp(nominalPajak)}",
                    ),
                    _buildDetailRow(
                      "Bunga setelah pajak",
                      _formatRp(bungaSetelahPajak),
                    ),
                    _buildDetailRow(
                      "Jangka waktu",
                      "${widget.jangkaWaktuBulan} Bulan",
                    ),
                    _buildDetailRow(
                      "Tanggal mulai",
                      _formatTanggal(tanggalMulai),
                    ),
                    _buildDetailRow(
                      "Tanggal jatuh tempo",
                      _formatTanggal(tanggalJatuhTempo),
                    ),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitDeposito,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7F00),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          "Konfirmasi",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 22, color: Colors.black),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
