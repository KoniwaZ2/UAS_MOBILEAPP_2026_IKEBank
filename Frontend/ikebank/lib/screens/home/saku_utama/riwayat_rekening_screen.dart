import 'package:flutter/material.dart';

import '../../../api/banking.dart';
import '../../../models/beneficial_account.dart';
import 'transfer_riwayat_screen.dart';

class RiwayatRekeningScreen extends StatefulWidget {
  const RiwayatRekeningScreen({super.key});

  @override
  State<RiwayatRekeningScreen> createState() => _RiwayatRekeningScreenState();
}

class _RiwayatRekeningScreenState extends State<RiwayatRekeningScreen> {
  late Future<List<BeneficialAccount>> _rekeningFuture;

  @override
  void initState() {
    super.initState();
    _rekeningFuture = BankingService.fetchRekeningList();
  }

  Future<void> _reloadRekeningList() async {
    setState(() {
      _rekeningFuture = BankingService.fetchRekeningList();
    });
  }

  String _formatAddedAt(String rawValue) {
    if (rawValue.trim().isEmpty) {
      return '';
    }

    final parsed = DateTime.tryParse(rawValue);
    if (parsed == null) {
      return rawValue;
    }

    const months = <String>[
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

    return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
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
          'Transfer Dana',
          style: TextStyle(
            fontFamily: 'AlumniSans',
            fontWeight: FontWeight.w800,
            fontSize: 24,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Riwayat Rekening',
              style: TextStyle(
                fontFamily: 'AlumniSans',
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black87, width: 1),
                ),
                child: FutureBuilder<List<BeneficialAccount>>(
                  future: _rekeningFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                snapshot.error.toString().replaceFirst('Exception: ', ''),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: _reloadRekeningList,
                                child: const Text('Coba lagi'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final rekeningList = snapshot.data ?? <BeneficialAccount>[];
                    if (rekeningList.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Text(
                            'Belum ada rekening tersimpan',
                            style: TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _reloadRekeningList,
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: rekeningList.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: Colors.grey.shade300,
                        ),
                        itemBuilder: (context, index) {
                          final rekening = rekeningList[index];
                          return _buildRekeningItem(context, rekening);
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRekeningItem(
    BuildContext context,
    BeneficialAccount rekening,
  ) {
    final bankName = rekening.bankName.trim().isEmpty ? 'IKE Bank' : rekening.bankName;
    final holderName = rekening.accountHolderName.trim().isEmpty
        ? 'Nama tidak tersedia'
        : rekening.accountHolderName;
    final addedAtLabel = _formatAddedAt(rekening.addedAt);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransferRiwayatScreen(
              namaPenerima: holderName,
              nomorRekening: rekening.accountNumber,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              alignment: Alignment.center,
              child: Image.asset(
                'assets/images/IKEHome.png',
                width: 50,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    holderName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$bankName: ${rekening.accountNumber}',
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  if (addedAtLabel.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Ditambahkan $addedAtLabel',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
