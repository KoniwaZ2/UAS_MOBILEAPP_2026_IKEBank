import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ikebank/screens/auth/login/login_page.dart';
import 'package:ikebank/screens/bottomnav/main_tab_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ikebank/screens/home/home_screen.dart';
import 'package:ikebank/screens/auth/register/buat_pass_screen.dart';
import 'core/colors.dart';
import 'screens/auth/signin.dart';
import 'api/auth.dart';
import 'package:ikebank/services/notif_service.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await NotifService().initNotification();

  GoogleFonts.config.allowRuntimeFetching = true;
  await initializeDateFormatting('id_ID', null);
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final hasToken = await AuthService.hasValidAccessToken();
    if (mounted) {
      setState(() {
        _isLoggedIn = hasToken;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IKE-Bank',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryOrange,
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.alumniSansTextTheme(Theme.of(context).textTheme),
      ),
      home: _isLoading
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : (_isLoggedIn ? const MainTabScreen() : const SignIn()),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/buat_password': (context) => const BuatPassScreen(),
      },
    );
  }
}
