import 'package:flutter/material.dart';
import '../../../core/colors.dart';
import 'face_recog_screen.dart';
import '../../../api/auth.dart';

class LupaPasswordScreen extends StatefulWidget {
  final String email;
  final String reference;

  const LupaPasswordScreen({
    super.key,
    required this.email,
    required this.reference,
  });

  @override
  State<LupaPasswordScreen> createState() => _LupaPasswordScreenState();
}

class _LupaPasswordScreenState extends State<LupaPasswordScreen> {
  bool _isPasswordVisible1 = false;
  bool _isPasswordVisible2 = false;
  bool _isSubmitting = false;
  late final TextEditingController _passwordController1;
  late final TextEditingController _passwordController2;

  @override
  void initState() {
    super.initState();
    _passwordController1 = TextEditingController();
    _passwordController2 = TextEditingController();
  }

  @override
  void dispose() {
    _passwordController1.dispose();
    _passwordController2.dispose();
    super.dispose();
  }

  Future<void> _submitResetPassword() async {
    final password1 = _passwordController1.text.trim();
    final password2 = _passwordController2.text.trim();

    if (password1.isEmpty || password2.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password tidak boleh kosong")),
      );
      return;
    }

    if (password1 != password2) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Password tidak cocok")));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await AuthService.forgotPassword(
        email: widget.email,
        otpReference: widget.reference,
        password: password1,
        passwordConfirmation: password2,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password berhasil direset")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => FaceRecogScreen(
            isFromLupaPassword: true,
            reference: widget.reference,
            email: widget.email,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Terjadi kesalahan: $e")));
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

    return Scaffold(
      backgroundColor: AppColors.primaryOrange,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Lupa Password",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 26,
          ),
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Masukkan Password Baru",
                          style: alumniSansBold.copyWith(
                            fontSize: 28,
                            color: AppColors.textBlack,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Silahkan masukan password baru anda di kolom\nbawah.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textBlack,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 32),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Pastikan password kamu terdiri dari:",
                            style: alumniSansBold.copyWith(
                              fontSize: 18,
                              color: AppColors.textBlack,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildPasswordRuleItem("A", "Huruf besar"),
                            _buildPasswordRuleItem("a", "Huruf kecil"),
                            _buildPasswordRuleItem("123", "Angka"),
                            _buildPasswordRuleItem("8+", "8+ karakter"),
                          ],
                        ),
                        const SizedBox(height: 32),

                        _buildPasswordField(
                          hintText: "Masukan Password baru",
                          isVisible: _isPasswordVisible1,
                          controller: _passwordController1,
                          onVisibilityToggle: () {
                            setState(() {
                              _isPasswordVisible1 = !_isPasswordVisible1;
                            });
                          },
                        ),
                        const SizedBox(height: 20),

                        _buildPasswordField(
                          hintText: "Confrmasi Password baru",
                          isVisible: _isPasswordVisible2,
                          controller: _passwordController2,
                          onVisibilityToggle: () {
                            setState(() {
                              _isPasswordVisible2 = !_isPasswordVisible2;
                            });
                          },
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
                            onPressed: () {
                              if (_isSubmitting) {
                                return;
                              }
                              _submitResetPassword();
                            },
                            child: Text(
                              "Lanjut",
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

  // Fungsi untuk membuat Indikator Kekuatan Password (A, a, 123, 8+)
  Widget _buildPasswordRuleItem(String bigText, String smallText) {
    return Column(
      children: [
        Text(
          bigText,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w400,
            color: Colors.grey.shade400,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          smallText,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textBlack,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String hintText,
    required bool isVisible,
    required TextEditingController controller,
    required VoidCallback onVisibilityToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: !isVisible,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black, fontSize: 16),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              isVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.black54,
            ),
            onPressed: onVisibilityToggle,
          ),
        ),
      ),
    );
  }
}
