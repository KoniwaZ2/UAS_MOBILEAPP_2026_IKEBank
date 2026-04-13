import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Untuk share.svg dan send.svg
import '../../../widgets/chat_bubble.dart';
import '../../auth/login/face_recog_screen.dart';
import '../../../api/cs.dart';

class BantuanCsScreen extends StatefulWidget {
  const BantuanCsScreen({super.key});

  @override
  State<BantuanCsScreen> createState() => _BantuanCsScreenState();
}

class _BantuanCsScreenState extends State<BantuanCsScreen> {
  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text: "Hai, apa yang dapat kami bantu?",
      sender: "Menu",
      isMe: false,
      timestamp: DateTime.now().toIso8601String(),
    ),
  ];
  final TextEditingController _controller = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;
    setState(() {
      _messages.add(
        _ChatMessage(
          text: text,
          sender: "Saya",
          isMe: true,
          timestamp: DateTime.now().toIso8601String(),
        ),
      );
      _isSending = true;
      _controller.clear();
    });
    try {
      final response = await CsService.sendMessage(text);
      final reply = response['message']?.toString() ?? 'CS tidak merespon.';
      final action = response['action']?.toString() ?? '';
      if (action == 'FACE_VERIFICATION') {
        // akan muncul tombol verifikasi muka
      }
      final replyTimestamp =
          response['timestamp']?.toString() ?? DateTime.now().toIso8601String();
      setState(() {
        _messages.add(
          _ChatMessage(
            text: reply,
            sender: "CS",
            isMe: false,
            timestamp: replyTimestamp,
          ),
        );
      });
    } catch (e) {
      setState(() {
        _messages.add(
          _ChatMessage(
            text: "Gagal mengirim: $e",
            sender: "System",
            isMe: false,
            timestamp: DateTime.now().toIso8601String(),
          ),
        );
      });
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  Future<void> _handleClose() async {
    try {
      await CsService.closeChat(); // Pastikan ada method ini di CsService
    } catch (_) {}
    if (mounted) Navigator.pop(context);
  }

  String _formatTimeOnly(String ts) {
    // Jika sudah format 'HH:mm', tampilkan langsung
    final reg = RegExp(r'^\d{2}:\d{2}?$');
    if (reg.hasMatch(ts)) return ts.substring(0, 5);
    // Jika ISO, ambil jam dan menit
    try {
      final dt = DateTime.parse(ts);
      return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      // Jika format aneh, fallback tampilkan 5 char pertama
      return ts.length >= 5 ? ts.substring(0, 5) : ts;
    }
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
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 30),
                  Image.asset('assets/images/IKEHome.png', height: 60),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.black,
                      size: 28,
                    ),
                    onPressed: _handleClose,
                  ),
                ],
              ),
            ),
            // BANNER ORANYE
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
                        style: TextStyle(
                          fontFamily: 'AlumniSans',
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Selamat datang di layanan chat IKE Bank",
                        style: TextStyle(fontSize: 12, color: Colors.white),
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
            // CHAT BUBBLE LIST
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _messages.length,
                itemBuilder: (context, idx) {
                  final msg = _messages[idx];
                  return ChatBubble(
                    text: msg.text,
                    sender: msg.sender,
                    isMe: msg.isMe,
                    timestamp: msg.timestamp != null
                        ? _formatTimeOnly(msg.timestamp!)
                        : null,
                  );
                },
              ),
            ),
            // INPUT
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/share.svg',
                    width: 28,
                    height: 28,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFFFF7F00),
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: !_isSending,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: "Send Message",
                        hintStyle: const TextStyle(color: Colors.grey),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
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
                          borderSide: const BorderSide(
                            color: Color(0xFFFF7F00),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _isSending ? null : _sendMessage,
                    child: CircleAvatar(
                      backgroundColor: _isSending
                          ? Colors.grey
                          : const Color(0xFFFF7F00),
                      radius: 24,
                      child: SvgPicture.asset(
                        'assets/images/send.svg',
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
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

class _ChatMessage {
  final String text;
  final String sender;
  final bool isMe;
  final String? timestamp;
  _ChatMessage({
    required this.text,
    required this.sender,
    required this.isMe,
    this.timestamp,
  });
}
