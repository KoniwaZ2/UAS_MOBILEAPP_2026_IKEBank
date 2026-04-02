import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'qris_konfirmasi_screen.dart';

class QrisScreen extends StatefulWidget {
  const QrisScreen({super.key});

  @override
  State<QrisScreen> createState() => _QrisScreenState();
}

class _QrisScreenState extends State<QrisScreen> {
  @override
  Widget build(BuildContext context) {
    Color transparentAppBarColor = const Color(0x1AFFCA96);
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: transparentAppBarColor, 
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "QRIS",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900, 
            fontSize: 24,
            fontFamily: 'AlumniSans', 
          ),
        ),
        centerTitle: true,
      ),
      
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: const Color(0xFFEBEBEB), 
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code_scanner, size: 100, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        "Arahkan kamera ke kode QR", 
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 16, fontWeight: FontWeight.w500)
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  width: 260, 
                  height: 260,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0, left: 0,
                        child: _buildCornerLine(isTop: true, isLeft: true),
                      ),
                      Positioned(
                        top: 0, right: 0,
                        child: _buildCornerLine(isTop: true, isLeft: false),
                      ),
                      Positioned(
                        bottom: 0, left: 0,
                        child: _buildCornerLine(isTop: false, isLeft: true),
                      ),
                      Positioned(
                        bottom: 0, right: 0,
                        child: _buildCornerLine(isTop: false, isLeft: false),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.black12, width: 1)),
            ),
            child: Row(
              children: [
                Expanded(
                      child: SizedBox(
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const QrisKonfirmasiScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF7F00), 
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                            elevation: 0,
                          ),
                          child: const Text("Scan QR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                      ),
                    ),
                const SizedBox(width: 16),
                Expanded(
                      child: SizedBox(
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();
                            
                            final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                            
                            if (!context.mounted) return;

                            if (image != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Berhasil memilih foto: ${image.name}")),
                              );
                              
                              // TODO Selanjutnya: 
                              // Gambar ini (image.path) akan dikirim ke package pembaca QR 
                              // (seperti mobile_scanner) untuk di-decode isinya.
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF7F00),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                            elevation: 0,
                          ),
                          child: const Text("Upload File", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                      ),
                    ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCornerLine({required bool isTop, required bool isLeft}) {
    const double length = 55.0; 
    const double strokeWidth = 12.0; 
    const Radius radius = Radius.circular(16.0); 

    return Container(
      width: length,
      height: length,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? const BorderSide(color: Colors.black, width: strokeWidth) : BorderSide.none,
          bottom: !isTop ? const BorderSide(color: Colors.black, width: strokeWidth) : BorderSide.none,
          left: isLeft ? const BorderSide(color: Colors.black, width: strokeWidth) : BorderSide.none,
          right: !isLeft ? const BorderSide(color: Colors.black, width: strokeWidth) : BorderSide.none,
        ),
        borderRadius: BorderRadius.only(
          topLeft: (isTop && isLeft) ? radius : Radius.zero,
          topRight: (isTop && !isLeft) ? radius : Radius.zero,
          bottomLeft: (!isTop && isLeft) ? radius : Radius.zero,
          bottomRight: (!isTop && !isLeft) ? radius : Radius.zero,
        ),
      ),
    );
  }
}