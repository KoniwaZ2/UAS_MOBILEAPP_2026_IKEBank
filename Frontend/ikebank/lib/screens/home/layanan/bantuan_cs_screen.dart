import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Untuk share.svg dan send.svg
import '../../../widgets/chat_bubble.dart';
import '../../auth/login/face_recog_screen.dart';

class BantuanCsScreen extends StatefulWidget {
  const BantuanCsScreen({super.key});

  @override
  State<BantuanCsScreen> createState() => _BantuanCsScreenState();
}

class _BantuanCsScreenState extends State<BantuanCsScreen> {
  bool _isVerified = false;

  Future<void> _mulaiVerifikasi() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FaceRecogScreen(
        isFromCS: true,
      )),
    );
    
    if (mounted) {
      setState(() {
        _isVerified = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 30),
                  Image.asset('assets/images/IKEHome.png', height: 60),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // ==========================================
            // BANNER ORANYE DENGAN CS.PNG
            // ==========================================
            Container(
              width: double.infinity,
              color: const Color(0xFFFF7F00),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Halo JACOB",
                        style: TextStyle(fontFamily: 'AlumniSans', fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Selamat datang di layanan chat IKE Bank",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ],
                  ),
                  Image.asset(
                    'assets/images/CS.png',
                    height: 70,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const ChatBubble(
                      text: "Hai, apa yang dapat kami bantu?",
                      sender: "Menu",
                      isMe: false,
                    ),
                    const ChatBubble(
                      text: "Tolong rekening saya di hack",
                      sender: "Jacob",
                      isMe: true,
                    ),
                    const ChatBubble(
                      text: "Mohon menunggu, AI Agent kami akan membantu",
                      sender: "Menu",
                      isMe: false,
                    ),
                    
                    ChatBubble(
                      text: "Hai Jacob, aku AI Agent dari IKE Bank yang akan membantumu. Silakan lakukan verifikasi wajah.",
                      sender: "AI Agent",
                      isMe: false,
                      customAction: Align(
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: _isVerified ? null : _mulaiVerifikasi,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                            decoration: BoxDecoration(
                              color: _isVerified ? Colors.grey.shade400 : const Color(0xFFFFC891),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: _isVerified ? Colors.grey : const Color(0x33000000)),
                            ),
                            child: const Text("Klik untuk Verifikasi", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
                          ),
                        ),
                      ),
                    ),

                    if (_isVerified) ...[
                      ChatBubble(
                        text: "Mengirim Data",
                        sender: "Jacob",
                        isMe: true,
                        isActionOnly: true,
                        customAction: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFCC80),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFFF9800)),
                          ),
                          child: const Text("Mengirim Data", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
                        ),
                      ),
                      const ChatBubble(
                        text: "Terima kasih, tim kami akan meninjau laporanmu, ID Laporan 000637439482. Akunmu tidak dapat bertransaksi sementara waktu untuk keamananmu.",
                        sender: "AI Agent",
                        isMe: false,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ==========================================
            // BOTTOM INPUT (DENGAN SHARE.SVG & SEND.SVG)
            // ==========================================
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Ikon Share di sebelah kiri input
                  SvgPicture.asset(
                    'assets/images/share.svg',
                    width: 28,
                    height: 28,
                    colorFilter: const ColorFilter.mode(Color(0xFFFF7F00), BlendMode.srcIn),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Send Message",
                        hintStyle: const TextStyle(color: Colors.grey),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: Color(0xFFFF7F00)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Tombol Send dengan send.svg di sebelah kanan input
                  CircleAvatar(
                    backgroundColor: const Color(0xFFFF7F00),
                    radius: 24,
                    child: SvgPicture.asset(
                      'assets/images/send.svg',
                      width: 20,
                      height: 20,
                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
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