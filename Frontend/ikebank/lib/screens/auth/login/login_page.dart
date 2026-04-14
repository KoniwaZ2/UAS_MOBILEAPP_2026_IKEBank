import 'package:flutter/material.dart';
import 'package:ikebank/screens/bottomnav/main_tab_screen.dart';
import 'package:ikebank/api/auth.dart';
import 'package:ikebank/screens/home/home_screen.dart';
import '../../../core/colors.dart';
import 'lupa_password_screen.dart';
import '../../../api/banking.dart';
import 'package:local_auth/local_auth.dart';

class LoginPage extends StatefulWidget {
  final String? prefilledEmail;
  final bool isAfterRegister;
  final String? reference;

  const LoginPage({
    super.key,
    this.prefilledEmail,
    this.isAfterRegister = false,
    this.reference,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPasswordVisible = false;
  bool _isSubmitting = false;
  late final TextEditingController _emailController;
  final TextEditingController _passwordController = TextEditingController();
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isBiometric = false;
  
  bool _isEmailLocked = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.prefilledEmail ?? '');
    
    if (_emailController.text.isNotEmpty) {
      _isEmailLocked = true;
    }
    
    _loadLastEmailIfNeeded();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final hasToken = await AuthService.hasAccessToken();
    if (hasToken) {
      try {
        final resp = await AuthService.biometricCheck(
          email: await AuthService.getLastEmail() ?? '',
        );
        final enabled = resp is Map && resp['biometric_login'] == true;
        setState(() {
          _isBiometric = enabled;
        });
      } catch (_) {
        setState(() {
          _isBiometric = false;
        });
      }
    } else {
      setState(() {
        _isBiometric = false;
      });
    }
  }

  Future<void> _loginWithBiometric() async {
    bool success = await _auth.authenticate(
      localizedReason: 'Login menggunakan biometrik',
      options: const AuthenticationOptions(
        biometricOnly: true,
        stickyAuth: true,
      ),
    );

    if (!success) return;

    final refreshed = await AuthService.refreshAccessTokenIfNeeded();

    if (!refreshed) {
      await AuthService.clearTokens();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session habis, silakan login ulang')),
      );
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => MainTabScreen(
          homeEntrySource: widget.isAfterRegister
              ? HomeEntrySource.register
              : HomeEntrySource.login,
        ),
      ),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> _loadLastEmailIfNeeded() async {
    if ((widget.prefilledEmail ?? '').isNotEmpty) {
      return;
    }

    final savedEmail = await AuthService.getLastEmail();
    if (!mounted || savedEmail == null || savedEmail.isEmpty) {
      return;
    }

    setState(() {
      _emailController.text = savedEmail;
      _emailController.selection = TextSelection.collapsed(
        offset: savedEmail.length,
      );
      _isEmailLocked = true; 
    });
  }

  @override
  void didUpdateWidget(covariant LoginPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.prefilledEmail != widget.prefilledEmail) {
      _emailController
        ..text = widget.prefilledEmail ?? ''
        ..selection = TextSelection.collapsed(
          offset: (widget.prefilledEmail ?? '').length,
        );
      
      setState(() {
        _isEmailLocked = (widget.prefilledEmail ?? '').isNotEmpty;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email wajib diisi.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password minimal 8 karakter.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await AuthService.login(email: email, password: password);

      if (!mounted) {
        return;
      }

      bool needsRegisterAccount = false;
      try {
        final accounts = await BankingService.fetchAccountDetails();
        if (accounts.isEmpty) {
          needsRegisterAccount = true;
        }
      } catch (_) {
        needsRegisterAccount = true;
      }

      if (needsRegisterAccount) {
        await BankingService.registerAccount();
      }

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => MainTabScreen(
            homeEntrySource: widget.isAfterRegister
                ? HomeEntrySource.register
                : HomeEntrySource.login,
          ),
        ),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle alumniSansBold = TextStyle(fontWeight: FontWeight.w700);

    final bool isInputValid =
        _emailController.text.trim().isNotEmpty &&
        _passwordController.text.length >= 8;

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
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 24.0,
              ),
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
                  const SizedBox(height: 50),

                  Text(
                    "Selamat Datang Kembali",
                    style: alumniSansBold.copyWith(
                      fontSize: 34,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    "Ikuti langkah dibawah ini untuk masuk kembali ke akunmu",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.primaryOrange.withValues(alpha: 0.9),
                      height: 1.0,
                    ),
                  ),

                  const SizedBox(height: 50),

                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _emailController,
                      readOnly: _isEmailLocked, 
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                        fontSize: 18, 
                        color: _isEmailLocked ? Colors.grey.shade700 : Colors.black,
                      ),
                      decoration: const InputDecoration(
                        hintText: "Email",
                        hintStyle: TextStyle(color: Colors.black, fontSize: 16),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),

                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      style: const TextStyle(fontSize: 18),
                      decoration: InputDecoration(
                        hintText: "Password",
                        hintStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.black54,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),

                  const SizedBox(height: 8),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LupaPasswordScreen(
                              email: _emailController.text,
                              reference: widget.reference ?? '',
                            ),
                          ),
                        );
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
                            backgroundColor: isInputValid
                                ? AppColors.primaryOrange
                                : const Color(0xFFCDCDCD),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            if (_isSubmitting) {
                              return;
                            }
                            if (!isInputValid) {
                              return;
                            }
                            _submitLogin();
                          },
                          child: Text(
                            _isSubmitting ? "Memproses..." : "Masuk",
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
                          color: _isBiometric
                              ? AppColors.primaryOrange
                              : Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.fingerprint,
                            color: Colors.white,
                            size: 32,
                          ),
                          onPressed: () {
                            if (_isBiometric) {
                              _loginWithBiometric();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Silahkan login menggunakan email dan password',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
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
