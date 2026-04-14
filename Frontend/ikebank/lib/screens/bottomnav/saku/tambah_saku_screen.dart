import 'package:flutter/material.dart';
import 'buat_saku_form_screen.dart';
import '../../home/saku_deposito/saku_deposito_screen.dart';

class TambahSakuScreen extends StatelessWidget {
  const TambahSakuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: const Color(0xFFFF7F00),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Pilih Saku yang pas buat Anda",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            fontFamily: 'AlumniSans',
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          children: [
            _buildSakuOptionCard(
              context: context,
              title: "Saku Nabung",
              description: "Kembangkan danamu\ndengan bunga 3.5% p.a.",
              imagePath: 'assets/images/stonks.png',
              isPopOut: false,
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const BuatSakuFormScreen(type: "Nabung"),
                  ), // atau "Transaksi"
                );

                // --- TAMBAHKAN PENGAMAN INI ---
                if (!context.mounted) return;

                if (result != null) {
                  Navigator.pop(context, result);
                }
              },
            ),

            _buildSakuOptionCard(
              context: context,
              title: "Saku Deposito",
              description:
                  "Wujudkan impianmu\ndengan Deposito sebesar\n8.8% p.a.!",
              imagePath: 'assets/images/deposito.png',
              isPopOut: false,
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SakuDepositoScreen(),
                  ),
                );

                if (!context.mounted) return;

                if (result != null) {
                  Navigator.pop(context, result);
                }
              },
            ),

            _buildSakuOptionCard(
              context: context,
              title: "Saku Transaksi",
              description:
                  "Pisah pengeluaranmu\nsesuai kebutuhan sehari-\nhari",
              imagePath: 'assets/images/transaksi.png',
              isPopOut: true,
              onTap: () async {
                // TUNGGU DATA DARI FORM
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const BuatSakuFormScreen(type: "Transaksi"),
                  ),
                );
                // JIKA ADA DATA
                if (result != null) {
                  Navigator.pop(context, result);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSakuOptionCard({
    required BuildContext context,
    required String title,
    required String description,
    required String imagePath,
    required bool isPopOut,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        margin: const EdgeInsets.only(bottom: 24),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFFEBEBEB),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontFamily: 'AlumniSans',
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            description,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF01008A),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.zero,
                          bottomLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: isPopOut
                          ? null
                          : Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  imagePath,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            if (isPopOut)
              Positioned(
                right: 10,
                top: -20,
                bottom: 0,
                child: IgnorePointer(
                  child: Image.asset(imagePath, fit: BoxFit.contain),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
