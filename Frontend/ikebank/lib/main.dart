import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ikebank/screens/home/home_screen.dart';
import 'package:ikebank/screens/auth/register/buat_pass_screen.dart';
import 'core/colors.dart';
import 'screens/auth/signin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IKE-Bank',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryOrange,
        scaffoldBackgroundColor: Colors.white,
        // Pasang font Alumni Sans ke seluruh teks aplikasi
        textTheme: GoogleFonts.alumniSansTextTheme(Theme.of(context).textTheme),
      ),
      home: const SignIn(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/buat_password': (context) => const BuatPassScreen(),
      },
    );
  }
}
