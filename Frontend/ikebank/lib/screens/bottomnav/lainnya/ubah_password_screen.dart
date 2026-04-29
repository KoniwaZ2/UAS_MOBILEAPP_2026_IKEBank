import 'package:flutter/material.dart';
import '../../../api/auth.dart';

class UbahPasswordScreen extends StatefulWidget {
  const UbahPasswordScreen({super.key});

  @override
  State<UbahPasswordScreen> createState() => _UbahPasswordScreenState();
}

class _UbahPasswordScreenState extends State<UbahPasswordScreen> {
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;

  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _newPasswordError;
  String? _confirmPasswordError;

  final TextStyle alumniSansBold = const TextStyle(
    fontWeight: FontWeight.w800,
    fontFamily: 'AlumniSans',
  );

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isPasswordStrong(String password) {
    final hasUpper = RegExp(r'[A-Z]').hasMatch(password);
    final hasLower = RegExp(r'[a-z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    final hasMinLength = password.length >= 8;
    return hasUpper && hasLower && hasNumber && hasMinLength;
  }

  Future<void> _submitChangePassword() async {
    final oldPassword = _oldPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      _newPasswordError = null;
      _confirmPasswordError = null;
    });

    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field password wajib diisi.'), backgroundColor: Colors.red,),
      );
      return;
    }

    if (newPassword == oldPassword) {
      setState(() {
        _newPasswordError = 'Password lama tidak diperbolehkan';
      });
      return;
    }

    if (!_isPasswordStrong(newPassword)) {
      setState(() {
        _newPasswordError =
            'Password harus 8+ karakter, huruf besar, huruf kecil, dan angka.';
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        _confirmPasswordError = 'Konfirmasi password tidak cocok.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await AuthService.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
        newPasswordConfirmation: confirmPassword,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Password berhasil diubah'), backgroundColor: Colors.green));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password lama salah'), backgroundColor: Colors.red),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF7F00),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Masukkan Password Lama Kamu",
                              style: alumniSansBold.copyWith(
                                fontSize: 26,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),

                            _buildPasswordField(
                              hintText: "Password lama",
                              controller: _oldPasswordController,
                              obscureText: _obscureOldPassword,
                              onToggle: () {
                                setState(() {
                                  _obscureOldPassword = !_obscureOldPassword;
                                });
                              },
                            ),
                            const SizedBox(height: 32),

                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Pastikan password kamu terdiri dari:",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildRequirementItem(
                                  iconText: "A",
                                  label: "Huruf besar",
                                ),
                                _buildRequirementItem(
                                  iconText: "a",
                                  label: "Huruf kecil",
                                ),
                                _buildRequirementItem(
                                  iconText: "123",
                                  label: "Angka",
                                ),
                                _buildRequirementItem(
                                  iconText: "8+",
                                  label: "8+ karakter",
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),

                            _buildPasswordField(
                              hintText: "Password baru",
                              controller: _newPasswordController,
                              obscureText: _obscureNewPassword,
                              onToggle: () {
                                setState(() {
                                  _obscureNewPassword = !_obscureNewPassword;
                                });
                              },
                              errorText: _newPasswordError,
                            ),
                            const SizedBox(height: 16),

                            _buildPasswordField(
                              hintText: "Konfirmasi password baru",
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              onToggle: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                              errorText: _confirmPasswordError,
                            ),
                          ],
                        ),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                      width: double.infinity,
                      child: SizedBox(
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isSubmitting
                              ? null
                              : _submitChangePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF7F00), // Oranye
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            _isSubmitting ? 'Memproses...' : 'Lanjut',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String hintText,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggle,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              border: InputBorder.none,
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.black87,
                ),
                onPressed: onToggle,
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.red, size: 14),
              const SizedBox(width: 4),
              Text(
                errorText,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildRequirementItem({
    required String iconText,
    required String label,
  }) {
    return Column(
      children: [
        Text(
          iconText,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade300,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.black87),
        ),
      ],
    );
  }
}
