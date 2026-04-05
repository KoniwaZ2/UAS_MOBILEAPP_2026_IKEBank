import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../core/colors.dart';
import 'kebijkan_privasi_screen.dart';
import 'verifikasi_kode_screen.dart';
import '../../../api/auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _referralController = TextEditingController();
  bool isLoading = false;

  String _normalizePhone(String value) {
    var cleaned = value.trim();
    // Keep digits and plus sign only to avoid hidden or pasted characters.
    cleaned = cleaned.replaceAll(RegExp(r'[^0-9+]'), '');

    if (cleaned.startsWith('8')) {
      return '0$cleaned';
    }

    return cleaned;
  }

  bool _isValidEmail(String value) {
    final emailPattern = RegExp(
      r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
    );
    final match = emailPattern.firstMatch(value);
    return match != null && match.group(0) == value;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _referralController.dispose();
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(10.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                _buildProgressSegment(isActive: true),
                _buildProgressSegment(isActive: false),
                _buildProgressSegment(isActive: false),
                _buildProgressSegment(isActive: false),
                _buildProgressSegment(isActive: false),
                _buildProgressSegment(isActive: false),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 16.0),
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
                          "Yuk, kita mulai!",
                          style: alumniSansBold.copyWith(
                            fontSize: 36,
                            color: AppColors.textBlack,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Masukkan nomor ponsel dan alamat email\nkamu yang aktif",
                          style: TextStyle(
                            fontSize: 22,
                            color: AppColors.textBlack,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 40),

                        _buildInputField(
                          hintText: "Nomor ponsel",
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 20),

                        _buildInputField(
                          hintText: "Email",
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20),

                        _buildInputField(
                          hintText: "Kode referral (opsional)",
                          controller: _referralController,
                          keyboardType: TextInputType.text,
                        ),

                        const Spacer(),

                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade800,
                              height: 1.5,
                            ),
                            children: [
                              const TextSpan(
                                text:
                                    "Dengan melanjutkan, saya setuju bahwa PT IKE Bank Indonesia dapat menggunakan data pribadi saya untuk kepentingan operasional bank sesuai dengan Kebijakan Privasi di bawah.\n\n",
                              ),
                              TextSpan(
                                text: "Kebijakan Privasi PT IKE Bank Indonesia",
                                style: const TextStyle(
                                  color: Color(0xFF0000FF),
                                  fontWeight: FontWeight.w700,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const KebijakanPrivasiScreen(),
                                      ),
                                    );
                                  },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

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
                            onPressed: isLoading
                                ? null
                                : () async {
                                    String inputPhone = _phoneController.text
                                        .trim();
                                    String inputEmail = _emailController.text
                                        .trim()
                                        .toLowerCase();
                                    inputPhone = _normalizePhone(inputPhone);

                                    if (inputPhone.isEmpty ||
                                        inputEmail.isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Nomor ponsel dan email wajib diisi!",
                                          ),
                                          backgroundColor: Colors.red,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                      return;
                                    }

                                    if (!_isValidEmail(inputEmail)) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Format email tidak valid.",
                                          ),
                                          backgroundColor: Colors.red,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                      return;
                                    }

                                    setState(() {
                                      isLoading = true;
                                    });

                                    try {
                                      await AuthService.check(
                                        email: inputEmail,
                                        phone: inputPhone,
                                      );
                                      final otpRes =
                                          await AuthService.otpRequest(
                                            email: inputEmail,
                                            purpose: 'registration',
                                          );

                                      final otpRequests =
                                          (otpRes['otp_requests'] as List?) ??
                                          [];
                                      if (otpRequests.isEmpty) {
                                        throw Exception(
                                          'OTP reference tidak ditemukan',
                                        );
                                      }

                                      final reference =
                                          (otpRequests.first
                                                  as Map<
                                                    String,
                                                    dynamic
                                                  >)['reference']
                                              ?.toString() ??
                                          '';

                                      if (reference.isEmpty) {
                                        throw Exception('OTP reference kosong');
                                      }

                                      if (!context.mounted) {
                                        return;
                                      }

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              VerifikasiKodeScreen(
                                                email: inputEmail,
                                                phone: inputPhone,
                                                reference: reference,
                                              ),
                                        ),
                                      );
                                    } catch (e) {
                                      if (!context.mounted) {
                                        return;
                                      }
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            e.toString().replaceFirst(
                                              'Exception: ',
                                              '',
                                            ),
                                          ),
                                          backgroundColor: Colors.red,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    } finally {
                                      if (context.mounted) {
                                        setState(() {
                                          isLoading = false;
                                        });
                                      }
                                    }
                                  },
                            child: Text(
                              isLoading ? "Memproses..." : "Lanjut",
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

  Widget _buildInputField({
    required String hintText,
    required TextEditingController controller,
    required TextInputType keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black, fontSize: 16),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: 24,
          ),
        ),
      ),
    );
  }

  // --- FUNGSI HELPER UNTUK PROGRESS BAR ---
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
