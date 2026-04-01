import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../core/colors.dart';
import 'kebijkan_privasi_screen.dart'; 
import 'verifikasi_kode_screen.dart'; 

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _referralController = TextEditingController();

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
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
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
                                text: "Dengan melanjutkan, saya setuju bahwa PT IKE Bank Indonesia dapat menggunakan data pribadi saya untuk kepentingan operasional bank sesuai dengan Kebijakan Privasi di bawah.\n\n",
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
                                      MaterialPageRoute(builder: (context) => const KebijakanPrivasiScreen())
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
                            onPressed: () {
                              String inputPhone = _phoneController.text.trim();
                              String inputEmail = _emailController.text.trim();

                              if (inputPhone.isEmpty || inputEmail.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Nomor ponsel dan email wajib diisi!"),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                return;
                              }

                              Navigator.push(
                                context, 
                                MaterialPageRoute(
                                  builder: (context) => VerifikasiKodeScreen(email: inputEmail), // Kirim ke sini
                                )
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
          contentPadding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 24),
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
              
          color: isActive 
              ? null 
              : Colors.white.withValues(alpha: 0.6), 
        ),
      ),
    );
  }
}