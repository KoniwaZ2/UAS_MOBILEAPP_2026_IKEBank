import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ikebank/api/auth.dart';
import '../../../core/colors.dart';
import '../../../models/register_flow_data.dart';
import '../login/login_page.dart';
import '../../../api/banking.dart';
import '../../bottomnav/qris/qris_pin_screen.dart';

class BuatPinScreen extends StatefulWidget {
  final RegisterFlowData? flowData;
  final bool isLupaPin;
  final Map<String, dynamic>? qrisData;

  const BuatPinScreen({
    super.key,
    this.flowData,
    this.isLupaPin = false,
    this.qrisData,
  });

  @override
  State<BuatPinScreen> createState() => _BuatPinScreenState();
}

class _BuatPinScreenState extends State<BuatPinScreen> {
  final TextStyle alumniSansBold = const TextStyle(
    fontWeight: FontWeight.w700,
    fontFamily: 'AlumniSans',
  );

  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();

  String pin = "";
  String confirmPin = "";
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _pinController.addListener(_onPinInputChanged);
  }

  void _onPinInputChanged() {
    if (!mounted || _isSubmitting) return;

    final value = _pinController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (value != _pinController.text) {
      _pinController.text = value;
      _pinController.selection = TextSelection.collapsed(offset: value.length);
    }

    setState(() {
      if (value.length <= 6) {
        pin = value;
        confirmPin = "";
      } else {
        pin = value.substring(0, 6);
        confirmPin = value.substring(6, value.length);
      }
    });
  }

  Future<void> _submitLupaPin() async {
    if (pin.length < 6 || confirmPin.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN harus terdiri dari 6 digit angka!')),
      );
      return;
    }

    if (pin != confirmPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfirmasi PIN tidak cocok!')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Panggil API Ganti PIN.
      // (Asumsi di AuthService / BankingService ada fungsi changePin)
      // Karena Lupa PIN biasanya meng-overwrite PIN lama tanpa tahu PIN lamanya,
      // pastikan Backend mendukung ini, atau gunakan API yang sesuai.
      //
      // await AuthService.resetPin(newPin: pin1); <--- SESUAIKAN DENGAN API

      // Simulasi sukses untuk UI Flow:
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN Berhasil Diperbarui! Silakan Lanjut Bayar'),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QrisPinScreen(
            qrisNumber: widget.qrisData?['qrisNumber'] ?? '',
            merchantName: widget.qrisData?['merchantName'] ?? '',
            amount: widget.qrisData?['amount'] ?? '',
            location: widget.qrisData?['location'] ?? '',
            aquirer: widget.qrisData?['aquirer'] ?? '',
            panId: widget.qrisData?['panId'] ?? '',
            walletName: widget.qrisData?['walletName'] ?? '',
            walletBalance: widget.qrisData?['walletBalance'] ?? '',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
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

  Future<void> _submitRegistration() async {
    if (pin.length < 6 || confirmPin.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN harus terdiri dari 6 digit angka!')),
      );
      return;
    }

    if (pin != confirmPin) {
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
        pin: pin,
        ktpFile: flowData.ktpFile!,
      );

      if (!mounted) return;

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
      if (!mounted) return;
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
    _pinController.removeListener(_onPinInputChanged);
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  Widget box(int i, String val) {
    return Expanded(
      child: Container(
        height: 52,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          i < val.length ? "•" : "",
          style: const TextStyle(
            fontSize: 28,
            color: Colors.black,
            fontWeight: FontWeight.bold,
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

  @override
  Widget build(BuildContext context) {
    bool isButtonEnabled =
        pin.length == 6 &&
        confirmPin.length == 6 &&
        pin == confirmPin &&
        !_isSubmitting;

    return Scaffold(
      backgroundColor: AppColors.primaryOrange,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
        ),
        bottom: widget.isLupaPin
            ? null
            : PreferredSize(
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
                child: Stack(
                  children: [
                    Opacity(
                      opacity: 0.0,
                      child: TextField(
                        controller: _pinController,
                        focusNode: _pinFocusNode,
                        keyboardType: TextInputType.number,
                        maxLength: 12,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(counterText: ""),
                      ),
                    ),

                    GestureDetector(
                      onTap: () =>
                          FocusScope.of(context).requestFocus(_pinFocusNode),
                      behavior: HitTestBehavior.opaque,
                      child: CustomScrollView(
                        slivers: [
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Buat PIN Baru",
                                  style: alumniSansBold.copyWith(
                                    fontSize: 28,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                const Text(
                                  "Masukkan PIN keamananmu",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    6,
                                    (i) => box(i, pin),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                Text(
                                  "Hindari menggunakan tanggal lahir serta angka yang\nberurutan dan berulang\n(Contoh: 123456, DDMMYY, 000000)",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade400,
                                    height: 1.4,
                                  ),
                                ),

                                const SizedBox(height: 32),

                                const Text(
                                  "Konfirmasi PIN keamananmu",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    6,
                                    (i) => box(i, confirmPin),
                                  ),
                                ),

                                const Spacer(),

                                Container(
                                  width: double.infinity,
                                  height: 60,
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    color: isButtonEnabled
                                        ? AppColors.primaryOrange
                                        : Colors.grey[400],
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(30),
                                      onTap: isButtonEnabled
                                          ? () {
                                              if (widget.isLupaPin) {
                                                _submitLupaPin();
                                              } else {
                                                _submitRegistration();
                                              }
                                            }
                                          : null,
                                      child: Center(
                                        child: _isSubmitting
                                            ? const SizedBox(
                                                height: 24,
                                                width: 24,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2.5,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(Colors.white),
                                                ),
                                              )
                                            : Text(
                                                "Lanjut",
                                                style: alumniSansBold.copyWith(
                                                  fontSize: 20,
                                                  color: Colors.white,
                                                ),
                                              ),
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
