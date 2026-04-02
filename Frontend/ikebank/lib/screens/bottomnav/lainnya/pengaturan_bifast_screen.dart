import 'package:flutter/material.dart';

class PengaturanBiFastScreen extends StatefulWidget {
  const PengaturanBiFastScreen({super.key});

  @override
  State<PengaturanBiFastScreen> createState() => _PengaturanBiFastScreenState();
}

class _PengaturanBiFastScreenState extends State<PengaturanBiFastScreen> {
  bool _isPhoneEnabled = false; 

  final TextStyle alumniSansBold = const TextStyle(
    fontWeight: FontWeight.w800, 
    fontFamily: 'AlumniSans',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF7F00), 
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Pengaturan BI-Fast",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            fontFamily: 'AlumniSans',
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Mendaftarkan nomor telepon kamu sebagai Proxy\nID akan memudahkan kamu untuk menerima\npembayaran dan transfer",
                style: TextStyle(
                  fontSize: 22, 
                  color: Colors.grey.shade800, 
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 32),

              _buildProxyCard(
                icon: Icons.mail,
                label: "Alamat email",
                value: "jacobsins@gmail.com",
                isRegistered: true,
                isToggled: true, 
                isLocked: true, 
                onToggleChanged: (val) {}, 
              ),
              
              const SizedBox(height: 16),

              _buildProxyCard(
                icon: Icons.phone,
                label: "Nomor ponsel",
                value: "+6281234567890",
                isRegistered: _isPhoneEnabled,
                isToggled: _isPhoneEnabled,
                isLocked: false, 
                onToggleChanged: (val) {
                  setState(() {
                    _isPhoneEnabled = val;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProxyCard({
    required IconData icon,
    required String label,
    required String value,
    required bool isRegistered,
    required bool isToggled,
    bool isLocked = false, 
    required ValueChanged<bool> onToggleChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 1.0), 
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Icon(icon, color: const Color(0xFFFF7F00), size: 32),
          ),
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 18, color: Colors.black)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w400)),
                const SizedBox(height: 8),
                
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 2),
                  decoration: BoxDecoration(
                    color: isRegistered ? const Color(0xFFFF9800) : const Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black, width: 0.5),
                  ),
                  child: Text(
                    isRegistered ? "Terdaftar" : "Belum terdaftar",
                    style: const TextStyle(color: Colors.black87, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          
          IgnorePointer(
            ignoring: isLocked,
            child: Opacity(
              opacity: isLocked ? 0.6 : 1.0, 
              child: Switch(
                value: isToggled,
                onChanged: onToggleChanged,
                activeColor: Colors.white, 
                activeTrackColor: const Color(0xFFFF7F00), 
                inactiveThumbColor: Colors.white, 
                inactiveTrackColor: Colors.grey.shade300, 
              ),
            ),
          ),
        ],
      ),
    );
  }
}