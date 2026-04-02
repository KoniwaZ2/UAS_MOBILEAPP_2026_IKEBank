import 'package:flutter/material.dart';
import '../../../core/colors.dart'; 
import 'package:flutter_svg/flutter_svg.dart'; 

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextStyle alumniSansBold = const TextStyle(
      fontWeight: FontWeight.w700,
      fontFamily: 'AlumniSans',
    );

    final List<Map<String, dynamic>> notifications = [
      {
        'type': 'bell',
        'title': 'Deposito spesial bunga hingga 8.80% p.a. hanya untuk 100 orang pertama.',
        'desc': 'Surprise Deposito sudah dimulai. Nikmati bunga spesial dari IKE Bank hanya untuk 100 orang pertama!',
        'date': 'Hari Ini',
        'time': '12:00',
      },
      {
        'type': 'transfer',
        'title': 'Transfer Keluar',
        'desc': 'Kamu mengirimkan dana sebesar Rp 50.000 ke Ivan Ibrahim Segera hubungi Contact Center IKE Bank jika transaksi tidak kamu lakukan.',
        'date': 'Kemarin',
        'time': '09:00',
      },
      {
        'type': 'cashback',
        'title': 'Cashback diterima',
        'desc': 'Selamat, kamu mendapatkan hadiah cashback sebesar Rp50.000 dari IKE Bank karena telah menjadi nasabah setia kami. Terus gunakan IKE Bank ya!',
        'date': '26 Februari 2026',
        'time': '16:00',
      },
      {
        'type': 'qris',
        'title': 'Transaksi dengan QRIS berhasil',
        'desc': 'Kamu baru saja melakukan transaksi QRIS sebesar Rp 2.000.000 ke Toko Baju Erik. Segera hubungi Contact Center IKE Bank jika transaksi tidak kamu lakukan.',
        'date': '26 Februari 2026',
        'time': '16:00',
      },
      {
        'type': 'card',
        'title': 'Request Kartu Berhasil',
        'desc': 'Selamat, request kartu kamu berhasil. Segera aktifkan kartumu setelah kartu diterima ya',
        'date': '20 Februari 2026',
        'time': '13:00',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white, 
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Notification",
          style: alumniSansBold.copyWith(fontSize: 28, color: Colors.black),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const Divider(
          color: Color(0xFFEEEEEE), 
          thickness: 1.5,
          height: 26, 
        ),
        itemBuilder: (context, index) {
          final notif = notifications[index];
          return _buildNotificationItem(
            type: notif['type'],
            title: notif['title'],
            desc: notif['desc'],
            date: notif['date'],
            time: notif['time'],
            titleStyle: alumniSansBold,
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem({
    required String type,
    required String title,
    required String desc,
    required String date,
    required String time,
    required TextStyle titleStyle,
  }) {
    Widget iconWidget;
    
    switch (type) {
      case 'bell':
        iconWidget = SvgPicture.asset(
          'assets/images/notif.svg',
          height: 30,
          colorFilter: const ColorFilter.mode(
            Colors.white, 
            BlendMode.srcIn,
          ),
        );
        break;
      case 'transfer':
        iconWidget = const Icon(Icons.arrow_forward, color: Colors.white, size: 28);
        break;
      case 'cashback':
        iconWidget = const Icon(Icons.add, color: Colors.white, size: 30);
        break;
      case 'qris':
        iconWidget = Image.asset(
          'assets/images/Qris.png',
          height: 24, 
          fit: BoxFit.contain,
        );
        break;
      case 'card':
        iconWidget = SvgPicture.asset(
          'assets/images/kartu.svg',
          height: 30,
          colorFilter: const ColorFilter.mode(
            Colors.white, 
            BlendMode.srcIn,
          ),
        );
        break;
      default:
        iconWidget = const Icon(Icons.info_outline, color: Colors.white, size: 28);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: const BoxDecoration(
            color: AppColors.primaryOrange,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: iconWidget,
        ),
        const SizedBox(width: 12),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: titleStyle.copyWith(fontSize: 16, color: Colors.black, height: 1.2),
              ),
              const SizedBox(height: 8),
              Text(
                desc,
                style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(date, style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600)),
                  Text(time, style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}