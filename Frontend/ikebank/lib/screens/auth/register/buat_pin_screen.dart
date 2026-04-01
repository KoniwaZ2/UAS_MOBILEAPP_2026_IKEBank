import 'package:flutter/material.dart';
import 'package:ikebank/api/auth.dart';
import '../../../core/colors.dart';
import '../../../models/register_flow_data.dart';
import '../login/login_page.dart';
import '../../../api/banking.dart';

class BuatPinScreen extends StatefulWidget {
  final RegisterFlowData? flowData;

  const BuatPinScreen({super.key, this.flowData});

  @override
  State<BuatPinScreen> createState() => _BuatPinScreenState();
}

class _BuatPinScreenState extends State<BuatPinScreen> {
  final TextStyle alumniSansBold = const TextStyle(
    fontWeight: FontWeight.w700,
    fontFamily: 'AlumniSans',
  );

  // Controller untuk menyimpan input PIN
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitRegistration() async {
    String pin1 = _pinController.text;
    String pin2 = _confirmPinController.text;

    if (pin1.length < 6 || pin2.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN harus terdiri dari 6 digit angka!')),
      );
      return;
    }

    if (pin1 != pin2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfirmasi PIN tidak cocok!')),
      );
      return;
    }

    final flowData = widget.flowData;
    if (flowData == null ||
        flowData.ktpFile == null ||
        (flowData.password ?? '').isEmpty ||
        (flowData.otpReference).isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data registrasi belum lengkap. Ulangi dari awal.'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await AuthService.register(
        otpReference: flowData.otpReference,
        phoneNumber: flowData.phoneNumber,
        email: flowData.email,
        password: flowData.password!,
        name: flowData.name ?? '',
        nik: flowData.nik ?? '',
        bornPlace: flowData.bornPlace ?? '-',
        bornDate: flowData.bornDate ?? '',
        gender: flowData.gender ?? 'Other',
        address: flowData.address ?? '',
        religion: flowData.religion ?? '',
        motherName: flowData.motherName ?? '',
        pin: pin1,
        ktpFile: flowData.ktpFile!,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrasi Berhasil! Silakan Login')),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) =>
              LoginPage(prefilledEmail: flowData.email, isAfterRegister: true),
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
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
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
                child: CustomScrollView(
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.center, // Pusatkan isi
                        children: [
                          Text(
                            "Buat PIN Baru",
                            style: alumniSansBold.copyWith(
                              fontSize: 32,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 24),

                          const Text(
                            "Masukkan PIN keamananmu",
                            style: TextStyle(fontSize: 22, color: Colors.black),
                          ),
                          const SizedBox(height: 16),

                          _buildPinInputBox(_pinController),

                          const SizedBox(height: 24),

                          Text(
                            "Hindari menggunakan tanggal lahir serta angka yang\nberurutan dan berulang\n(Contoh: 123456, DDMMYY, 000000)",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.grey.shade400,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 32),

                          const Text(
                            "Konfirmasi PIN keamananmu",
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          const SizedBox(height: 16),

                          _buildPinInputBox(_confirmPinController),

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
                                _submitRegistration();
                              },
                              child: Text(
                                _isSubmitting ? "Memproses..." : "Lanjut",
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
        ],
      ),
    );
  }

  // WIDGET CUSTOM: 6 Kotak PIN + Invisible TextField
  Widget _buildPinInputBox(TextEditingController controller) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (index) {
            return Container(
              width: 48,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                controller.text.length > index ? "•" : "",
                style: const TextStyle(
                  fontSize: 28,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }),
        ),
        Positioned.fill(
          child: Opacity(
            opacity: 0.0,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              maxLength: 6,
              cursorColor: Colors.transparent,
              decoration: const InputDecoration(
                counterText: "",
                border: InputBorder.none,
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
        ),
      ],
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
