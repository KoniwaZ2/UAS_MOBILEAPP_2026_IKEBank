import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../home/home_screen.dart';
import 'saku/saku_screen.dart';
import 'qris/qris_screen.dart'; 
import 'kartu/buat_kartu_screen.dart';
import 'lainnya/lainnya_screen.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const SakuScreen(),
    const Scaffold(body: Center(child: Text("Halaman QRIS (Dalam Pengembangan)"))), 
    const BuatKartuScreen(), 
    const LainnyaScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], 

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade400, width: 1.0)),
        ),
        child: SafeArea(
          child: Container(
            height: 75, 
            padding: const EdgeInsets.symmetric(horizontal: 20.0), 
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, 
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _buildNavItem(svgPath: 'assets/images/beranda.svg', label: "Beranda", index: 0),
                _buildNavItem(svgPath: 'assets/images/saku.svg', label: "Saku", index: 1),
                _buildQrisNavItem(), 
                _buildNavItem(svgPath: 'assets/images/kartu.svg', label: "Kartu", index: 3),
                _buildNavItem(svgPath: 'assets/images/lainnya.svg', label: "Lainnya", index: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildNavItem({required String svgPath, required String label, required int index}) {
    bool isSelected = _selectedIndex == index;
    
    Color activeColor = const Color(0xFFFF7F00); 
    Color inactiveColor = Colors.black87;        
    
    Color currentColor = isSelected ? activeColor : inactiveColor;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        width: 50, 
        color: Colors.transparent, 
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              svgPath,
              height: 30, 
              colorFilter: ColorFilter.mode(currentColor, BlendMode.srcIn),
            ),
            
            
            const SizedBox(height: 0.1),
            Text(
              label, 
              style: TextStyle(
                fontSize: 16, 
                color: currentColor, 
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, 
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrisNavItem() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const QrisScreen()),
        );
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [Color(0xFFFF7F00), Color(0xFFFFCA96)],
          ),
        ),
        alignment: Alignment.center,
        child: Image.asset('assets/images/Qris.png', height: 20, fit: BoxFit.contain),
      ),
    );
  }
}