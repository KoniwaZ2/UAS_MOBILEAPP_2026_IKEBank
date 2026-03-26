import 'package:flutter/material.dart';
import '../../../core/colors.dart';
import 'lupa_password_screen.dart';
import '../../home/home_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    const TextStyle alumniSansBold = TextStyle(fontWeight: FontWeight.w700);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.43,
              width: double.infinity,
              child: Image.asset(
                'assets/images/IKEBank.png',
                fit: BoxFit.cover,
              ),
            ),

            Container(
              width: double.infinity,
              transform: Matrix4.translationValues(0.0, -30.0, 0.0),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, 
                children: [
                  
                  const SizedBox(height: 70), 

                  Text(
                    "Selamat Datang Kembali",
                    style: alumniSansBold.copyWith(
                      fontSize: 40,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Ikuti langkah dibawah ini untuk masuk kembali ke akunmu",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      color: AppColors.primaryOrange.withValues(alpha: 0.9), 
                      height: 1.4,
                    ),
                  ),
                  
                  const SizedBox(height: 110), 

                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9).withValues(alpha: 0.5), 
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      obscureText: !_isPasswordVisible, 
                      style: const TextStyle(fontSize: 18),
                      decoration: InputDecoration(
                        hintText: "Password",
                        hintStyle: const TextStyle(color: Colors.black, fontSize: 16),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: Colors.black54,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const LupaPasswordScreen()));
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        "Lupa Password?",
                        style: alumniSansBold.copyWith(
                          fontSize: 15,
                          color: AppColors.primaryOrange,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16), 

                  // TOMBOL MASUK & FINGERPRINT
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFCDCDCD), 
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12), 
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const HomeScreen()),
                              (Route<dynamic> route) => false, 
                            );
                          },
                          child: Text(
                            "Masuk",
                            style: alumniSansBold.copyWith(
                              fontSize: 20,
                              color: Colors.white, 
                            ),
                          ),
                        ),
                      ),
                      // Fingerprint 
                      const SizedBox(width: 16),
                      Container(
                        height: 60, 
                        width: 60,
                        decoration: BoxDecoration(
                          color: AppColors.primaryOrange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.fingerprint, color: Colors.white, size: 32),
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const HomeScreen()),
                              (Route<dynamic> route) => false, 
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}