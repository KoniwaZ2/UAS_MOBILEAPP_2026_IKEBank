import 'package:flutter/material.dart';
import '../../../core/colors.dart';
import 'verifikasi_code_screen.dart';
import '../../../api/auth.dart';

class MasukScreen extends StatefulWidget {
  const MasukScreen({super.key});

  @override
  State<MasukScreen> createState() => _MasukScreenState();
}

class _MasukScreenState extends State<MasukScreen> {
  final TextEditingController _emailController = TextEditingController();

  String? _errorMessage;
  bool _isCheckingLogin = false;

  Future<void> _validasiDanLanjut() async {
    final email = _emailController.text.trim();

    final isEmailValid = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    ).hasMatch(email);

    if (email.isEmpty) {
      setState(() {
        _errorMessage = "Email tidak boleh kosong";
      });
      return;
    }

    if (!isEmailValid) {
      setState(() {
        _errorMessage = "Format email tidak valid (contoh: nama@gmail.com)";
      });
      return;
    }

    setState(() {
      _errorMessage = null;
      _isCheckingLogin = true;
    });

    try {
      await AuthService.saveLastEmail(email);

      final result = await AuthService.checkLogin(email: email);
      final exists = result['exists'] == true;

      if (!mounted) {
        return;
      }

      if (!exists) {
        setState(() {
          _errorMessage = "Email belum terdaftar";
          _isCheckingLogin = false;
        });
        return;
      }

      setState(() {
        _isCheckingLogin = false;
      });

      final otpRes = await AuthService.otpRequest(
        email: email,
        purpose: 'login',
      );
      final otpRequests = (otpRes['otp_requests'] as List?) ?? [];
      if (otpRequests.isEmpty) {
        throw Exception('OTP reference tidak ditemukan');
      }
      final reference =
          (otpRequests.first as Map<String, dynamic>)['reference']
              ?.toString() ??
          '';

      if (reference.isEmpty) {
        throw Exception('OTP reference kosong');
      }

      if (!mounted) {
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              VerifikasiCodeScreen(email: email, reference: reference),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isCheckingLogin = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle alumniSansBold = TextStyle(fontWeight: FontWeight.w700);

    return Scaffold(
      backgroundColor: AppColors.primaryOrange,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 32.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Selamat Datang!",
                          style: alumniSansBold.copyWith(
                            fontSize: 36,
                            color: AppColors.textBlack,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Masukkan alamat email kamu untuk\nmenghubungkan akunmu",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textBlack,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 40),

                        Container(
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFD9D9D9,
                            ).withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: _errorMessage != null
                                ? Border.all(color: Colors.red, width: 1.5)
                                : null,
                          ),
                          child: TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(fontSize: 18),
                            decoration: const InputDecoration(
                              hintText: "Alamat Email",
                              hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                            ),
                          ),
                        ),

                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 8.0,
                              left: 10.0,
                            ),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                            ),
                          ),

                        const Spacer(),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryOrange,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: _isCheckingLogin
                                ? null
                                : _validasiDanLanjut,
                            child: Text(
                              _isCheckingLogin ? "Memproses..." : "Lanjut",
                              style: alumniSansBold.copyWith(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
