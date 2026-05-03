import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../api/banking.dart';
import '../layanan/bantuan_cs_screen.dart';

class DepositoDetailScreen extends StatefulWidget {
  final String namaDeposito;
  final double jumlahPenempatan;
  final double bungaSetelahPajak;
  final String tanggalMulai;
  final String tanggalJatuhTempo;
  final bool isFromPortfolio;
  final double sukuBunga;
  final int jangkaWaktuBulan;
  final String depositoUUID;
  String get depositoAccountId => depositoUUID;

  const DepositoDetailScreen({
    super.key,
    this.namaDeposito = "Deposito 1",
    this.jumlahPenempatan = 0,
    this.bungaSetelahPajak = 0,
    this.tanggalMulai = '-',
    this.tanggalJatuhTempo = '-',
    this.isFromPortfolio = false,
    this.sukuBunga = 8.8,
    this.jangkaWaktuBulan = 1,
    String depositoUUID = '',
    String? depositoAccountId,
  }) : depositoUUID = depositoAccountId ?? depositoUUID;

  @override
  State<DepositoDetailScreen> createState() => _DepositoDetailScreenState();
}

class _DepositoDetailScreenState extends State<DepositoDetailScreen> {
  late String _namaDeposito;
  late TextEditingController _nameController;
  bool _isSavingName = false;

  @override
  void initState() {
    super.initState();
    _namaDeposito = widget.namaDeposito;
    _nameController = TextEditingController(text: _namaDeposito);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _formatRp(double value) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }

  void _showEditNameBottomSheet(BuildContext context) {
    _nameController.text = _namaDeposito;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD6CFFF),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(100),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/images/deposito.png',
                    width: 65,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _nameController,
                style: const TextStyle(fontSize: 18, color: Colors.black),
                decoration: InputDecoration(
                  labelText: "Nama deposito",
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFFFF7F00),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSavingName
                      ? null
                      : () async {
                          final newName = _nameController.text.trim();
                          if (newName.isEmpty) {
                            if (mounted) {
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Nama deposito tidak boleh kosong.',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                            return;
                          }

                          final depositoId = widget.depositoUUID.trim();
                          if (depositoId.isEmpty) {
                            if (mounted) {
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'ID deposito tidak ditemukan. Coba buka ulang detail deposito.',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                            return;
                          }

                          setState(() {
                            _isSavingName = true;
                          });

                          try {
                            await BankingService.editDeposito(
                              depositoUUID: depositoId,
                              nama: newName,
                            );

                            if (!mounted) {
                              return;
                            }

                            setState(() {
                              _namaDeposito = newName;
                            });

                            if (mounted && context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Nama deposito berhasil diperbarui.',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e.toString().replaceFirst(
                                      'Exception: ',
                                      '',
                                    ),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isSavingName = false;
                              });
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7F00),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _isSavingName ? 'Menyimpan...' : 'Simpan',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double totalEstimasi =
        widget.jumlahPenempatan + widget.bungaSetelahPajak;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black, size: 28),
          onPressed: () {
            if (widget.isFromPortfolio) {
              Navigator.pop(context);
            } else {
              int count = 0;
              Navigator.of(context).popUntil((_) => count++ >= 3);
            }
          },
        ),
        centerTitle: true,
        title: Text(
          _namaDeposito,
          style: const TextStyle(
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
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD6CFFF),
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(100),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Image.asset(
                          'assets/images/deposito.png',
                          width: 65,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Text(
                          _namaDeposito,
                          style: const TextStyle(
                            fontFamily: 'AlumniSans',
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _showEditNameBottomSheet(context),
                          child: SvgPicture.asset(
                            'assets/images/pensil.svg',
                            width: 20,
                            height: 20,
                            colorFilter: const ColorFilter.mode(
                              Colors.black,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Jumlah penempatan",
                      style: TextStyle(fontSize: 24, color: Colors.black),
                    ),
                    Text(
                      _formatRp(widget.jumlahPenempatan),
                      style: const TextStyle(
                        fontFamily: 'AlumniSans',
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFFF7F00),
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                        children: [
                          const TextSpan(text: "Kamu akan mendapatkan "),
                          TextSpan(
                            text: _formatRp(totalEstimasi),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF7F00),
                            ),
                          ),
                          const TextSpan(text: " saat jatuh tempo"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      "Rincian Deposito",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      "Jumlah penempatan",
                      _formatRp(widget.jumlahPenempatan),
                    ),
                    _buildDetailRow(
                      "Suku bunga (p.a)",
                      "${widget.sukuBunga.toStringAsFixed(widget.sukuBunga == widget.sukuBunga.roundToDouble() ? 0 : 2)}%",
                    ),
                    _buildDetailRow(
                      "Bunga setelah pajak",
                      _formatRp(widget.bungaSetelahPajak),
                    ),
                    _buildDetailRow(
                      "Jangka waktu",
                      "${widget.jangkaWaktuBulan} Bulan",
                    ),
                    _buildDetailRow("Tanggal mulai", widget.tanggalMulai),
                    _buildDetailRow(
                      "Tanggal jatuh tempo",
                      widget.tanggalJatuhTempo,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Pencairan sebelum jatuh tempo, hanya dapat dilakukan melalui bantuan CS dan sertakan No Rekening Deposito.",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BantuanCsScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Bantuan CS",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF7F00),
                      ),
                    ),
                  ),
                ],
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
            style: const TextStyle(fontSize: 18, color: Colors.black87),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
