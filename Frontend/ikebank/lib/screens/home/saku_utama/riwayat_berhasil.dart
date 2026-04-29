import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart'; 

class RiwayatBerhasilScreen extends StatelessWidget {
  final String namaPenerima;
  final String nomorRekening;
  final String jumlah;
  final String sumberDana;

  const RiwayatBerhasilScreen({
    super.key,
    this.namaPenerima = "Ivan Ibrahim",
    this.nomorRekening = "10095324564",
    this.jumlah = "250.000",
    this.sumberDana = "Saku Utama",
  });

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
          onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
        ),
        centerTitle: true,
        title: const Text(
          "Transfer Dana",
          style: TextStyle(
            fontFamily: 'AlumniSans',
            fontWeight: FontWeight.w800,
            fontSize: 28,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Text(
                      "Transfer Berhasil",
                      style: TextStyle(
                        fontFamily: 'AlumniSans',
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Icon(
                      Icons.verified,
                      color: Color(0xFF00C853), 
                      size: 100,
                    ),
                    const SizedBox(height: 32),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade400, width: 1),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50, height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            alignment: Alignment.center,
                            child: Image.asset('assets/images/IKEHome.png', width: 50, fit: BoxFit.contain),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(namaPenerima, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                                const SizedBox(height: 0.1),
                                Text("IKE Bank: $nomorRekening", style: const TextStyle(fontSize: 20, color: Colors.black)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade400, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Jumlah pembayaran", style: TextStyle(fontSize: 18, color: Colors.black)),
                          const SizedBox(height: 4),
                          Text(
                            "Rp $jumlah",
                            style: const TextStyle(
                              fontFamily: 'AlumniSans',
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade400, width: 1),
                      ),
                      child: Column( 
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Sumber dana", style: TextStyle(fontSize: 16, color: Colors.black45)),
                          const SizedBox(height: 8),
                          Text(sumberDana, style: const TextStyle(fontSize: 18, color: Colors.black)), 
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade400, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Jenis transfer", style: TextStyle(fontSize: 16, color: Colors.black45)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text("BI Fast", style: TextStyle(fontSize: 18, color: Colors.black)),
                              const SizedBox(width: 12),
                              Text(
                                "Rp2.500", 
                                style: TextStyle(fontSize: 16, color: Colors.grey.shade600, decoration: TextDecoration.lineThrough)
                              ),
                              const SizedBox(width: 8),
                              const Text("Gratis", style: TextStyle(fontSize: 18, color: Colors.green)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            Container(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7F00),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Text("Kembali", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16), 
                  
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          final String textResi = '''
                            ✅ *TRANSFER BERHASIL* ✅
                            -------------------------------
                            Penerima: $namaPenerima
                            Bank: IKE Bank ($nomorRekening)
                            Jumlah: Rp $jumlah
                            Sumber: Saku Utama
                            -------------------------------
                            Terima kasih menggunakan IKE Bank!
                                                      ''';
                          
                          Share.share(textResi);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7F00),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.share, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text("Bagikan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
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
}