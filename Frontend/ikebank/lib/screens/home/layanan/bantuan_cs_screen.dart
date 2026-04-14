import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Untuk share.svg dan send.svg
import 'package:ikebank/api/auth.dart';
import 'package:ikebank/api/banking.dart';
import '../../../widgets/chat_bubble.dart';
import '../../auth/login/face_recog_screen.dart';
import '../../../api/cs.dart';

class BantuanCsScreen extends StatefulWidget {
  const BantuanCsScreen({super.key});

  @override
  State<BantuanCsScreen> createState() => _BantuanCsScreenState();
}

class _BantuanCsScreenState extends State<BantuanCsScreen> {
  bool _isVerified = false;
  bool _reportSubmitted = false;
  String? _reportId;
  String?
  actions; // Menyimpan action dari respons CS untuk menentukan step selanjutnya

  String _generateReportId() {
    // Generate ID laporan dari timestamp + random number
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return timestamp.substring(timestamp.length - 9); // Ambil 9 digit terakhir
  }

  Future<void> _mulaiVerifikasi() async {
    // Ambil intent dari pesan terakhir yang membutuhkan verifikasi
    String? intent;
    if (_messages.isNotEmpty) {
      intent = _messages.last.intent;
    }
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FaceRecogScreen(isFromCS: true, intent: intent),
      ),
    );
    if (result == true && mounted) {
      // Generate ID laporan dan kirim ke backend
      final reportId = _generateReportId();
      try {
        // Kirim ID laporan ke backend via CsService
        await CsService.submitReport(reportId: reportId);
        await BankingService.fetchAccountDetails();
        setState(() {
          _isVerified = true;
          _reportId = reportId;
          _reportSubmitted = true;
          // Jika intent CHANGE_PIN, tambahkan chat bubble sukses
          if (intent == 'CHANGE_PIN') {
            _messages.add(
              _ChatMessage(
                text: 'PIN berhasil diubah',
                sender: 'Jacob',
                isMe: false,
                timestamp: DateTime.now().toIso8601String(),
              ),
            );
          }
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal membuat laporan: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text: "Hai, apa yang dapat kami bantu?",
      sender: "Jacob",
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
          sender: "Me",
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
      final intent = response['intent']?.toString() ?? '';
      final replyTimestamp =
          response['timestamp']?.toString() ?? DateTime.now().toIso8601String();
      if (action == 'FACE_VERIFICATION') {
        setState(() {
          _messages.add(
            _ChatMessage(
              text: reply,
              sender: "Jacob",
              isMe: false,
              timestamp: replyTimestamp,
              customAction: Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: _isVerified ? null : _mulaiVerifikasi,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _isVerified
                          ? Colors.grey.shade400
                          : const Color(0xFFFFC891),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isVerified
                            ? Colors.grey
                            : const Color(0x33000000),
                      ),
                    ),
                    child: const Text(
                      "Klik untuk Verifikasi",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              intent: intent,
            ),
          );
        });
      } else {
        setState(() {
          _messages.add(
            _ChatMessage(
              text: reply,
              sender: "Jacob",
              isMe: false,
              timestamp: replyTimestamp,
              intent: intent,
            ),
          );
        });
      }
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
    // Jika ISO, ambil jam dan menit, konversi ke UTC+7 (WIB)
    try {
      final dt = DateTime.parse(ts).toUtc().add(const Duration(hours: 7));
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
                itemCount:
                    _messages.length +
                    ((_isVerified && _reportSubmitted) ? 2 : 0),
                itemBuilder: (context, idx) {
                  if (idx < _messages.length) {
                    final msg = _messages[idx];
                    return ChatBubble(
                      text: msg.text,
                      sender: msg.sender,
                      isMe: msg.isMe,
                      timestamp: msg.timestamp != null
                          ? _formatTimeOnly(msg.timestamp!)
                          : null,
                      customAction: msg.customAction,
                    );
                  }
                  // Bubble custom "Mengirim Data"
                  if (idx == _messages.length) {
                    return ChatBubble(
                      text: "Mengirim Data",
                      sender: "Me",
                      isMe: true,
                      isActionOnly: true,
                      customAction: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFCC80),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _isVerified
                                ? Colors.grey
                                : const Color(0x33000000),
                          ),
                        ),
                        child: const Text(
                          "Mengirim Data",
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }
                  // Bubble "Terima kasih..." setelah "Mengirim Data"
                  if (idx == _messages.length + 1 &&
                      _messages.isNotEmpty &&
                      _messages.last.intent == 'HACK_ACCOUNT' &&
                      _isVerified &&
                      _reportSubmitted) {
                    return ChatBubble(
                      text:
                          "Terima kasih, tim kami akan meninjau laporanmu, ID Laporan ${_reportId ?? '-'} . Akunmu tidak dapat bertransaksi sementara waktu untuk keamananmu.",
                      sender: "Jacob",
                      isMe: false,
                    );
                  }
                },
              ),
            ),
            // INPUT
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
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
  final Widget? customAction;
  final String? intent;
  _ChatMessage({
    required this.text,
    required this.sender,
    required this.isMe,
    this.timestamp,
    this.customAction,
    this.intent,
  });
}
