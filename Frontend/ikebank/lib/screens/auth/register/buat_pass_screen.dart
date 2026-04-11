import 'package:flutter/material.dart';
import '../../../core/colors.dart';
import '../../../models/register_flow_data.dart';
import 'buat_pin_screen.dart';

class BuatPassScreen extends StatefulWidget {
  final RegisterFlowData? flowData;

  const BuatPassScreen({super.key, this.flowData});

  @override
  State<BuatPassScreen> createState() => _BuatPassScreenState();
}

class _BuatPassScreenState extends State<BuatPassScreen> {
  final TextStyle alumniSansBold = const TextStyle(
    fontWeight: FontWeight.w700,
    fontFamily: 'AlumniSans',
  );

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _hasUppercase(String value) => RegExp(r'[A-Z]').hasMatch(value);
  bool _hasLowercase(String value) => RegExp(r'[a-z]').hasMatch(value);
  bool _hasNumber(String value) => RegExp(r'\d').hasMatch(value);

  String? _validatePassword(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Password wajib diisi';
    if (text.length < 8) return 'Password minimal 8 karakter';
    if (!_hasUppercase(text)) return 'Password harus punya huruf besar';
    if (!_hasLowercase(text)) return 'Password harus punya huruf kecil';
    if (!_hasNumber(text)) return 'Password harus punya angka';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Konfirmasi password wajib diisi';
    if (text != _passwordController.text.trim()) {
      return 'Konfirmasi password tidak sama';
    }
    return null;
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryOrange,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                _buildProgressSegment(isActive: true),
                _buildProgressSegment(isActive: true),
                _buildProgressSegment(isActive: true),
                _buildProgressSegment(isActive: true),
                _buildProgressSegment(isActive: true),
                _buildProgressSegment(isActive: true),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16.0),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 32.0,
                ),
                child: Form(
                  key: _formKey,
                  child: CustomScrollView(
                    slivers: [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Selamat bergabung dengan Kami",
                                style: alumniSansBold.copyWith(
                                  fontSize: 28,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "Selamat Jacob, rekening kamu telah aktif dan sudah dapat digunakan untuk bertransaksi. Yuk buat password kamu",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 32),

                            Text(
                              "Pastikan password kamu terdiri dari:",
                              style: alumniSansBold.copyWith(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildCriteriaItem("A", "Huruf besar"),
                                _buildCriteriaItem("a", "Huruf kecil"),
                                _buildCriteriaItem("123", "Angka"),
                                _buildCriteriaItem("8+", "8+ karakter"),
                              ],
                            ),
                            const SizedBox(height: 32),

                            _buildPasswordField(
                              hint: "Masukkan Password",
                              controller: _passwordController,
                              isObscure: _obscurePassword,
                              validator: _validatePassword,
                              onToggleVisibility: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            const SizedBox(height: 16),

                            _buildPasswordField(
                              hint: "Konfirmasi password",
                              controller: _confirmPasswordController,
                              isObscure: _obscureConfirmPassword,
                              validator: _validateConfirmPassword,
                              onToggleVisibility: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
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
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),
                                  shape: const StadiumBorder(),
                                ),
                                onPressed: () {
                                  if (_formKey.currentState?.validate() !=
                                      true) {
                                    return;
                                  }
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BuatPinScreen(
                                        flowData: widget.flowData?.copyWith(
                                          password: _passwordController.text
                                              .trim(),
                                        ),
                                      ),
                                    ),
                                  );
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
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCriteriaItem(String iconText, String labelText) {
    return Column(
      children: [
        Text(
          iconText,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w400,
            color: Color(0xFFC0C0C0),
            height: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          labelText,
          style: const TextStyle(
            fontSize: 14,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String hint,
    required TextEditingController controller,
    required bool isObscure,
    required String? Function(String?) validator,
    required VoidCallback onToggleVisibility,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isObscure,
        style: const TextStyle(fontSize: 16, color: Colors.black),
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          suffixIcon: IconButton(
            icon: Icon(
              isObscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.grey.shade700,
            ),
            onPressed: onToggleVisibility,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSegment({required bool isActive}) {
    return Expanded(
      child: Container(
        height: 6,
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: [Color(0xFF0000FF), Color(0xFF9999FF)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: isActive ? null : Colors.white.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
