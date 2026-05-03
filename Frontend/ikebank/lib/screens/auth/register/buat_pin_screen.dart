import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ikebank/api/auth.dart';
import '../../../core/colors.dart';
import '../../../models/register_flow_data.dart';
import '../login/login_page.dart';
import '../../../api/banking.dart';
import '../../bottomnav/qris/qris_pin_screen.dart';
import '../../../utils/pin_rules.dart';

class BuatPinScreen extends StatefulWidget {
  final RegisterFlowData? flowData;
  final bool isLupaPin;
  final bool isFromCs;
  final Map<String, dynamic>? qrisData;

  const BuatPinScreen({
    super.key,
    this.flowData,
    this.isLupaPin = false,
    this.isFromCs = false,
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
    final validationMessage = validatePinEntry(pin, confirmPin);
    if (validationMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationMessage), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await BankingService.changePin(newPin: pin, newPinConfirm: confirmPin);

      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN Berhasil Diperbarui! Silakan Lanjut Bayar'),
          backgroundColor: Colors.green,
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

  Future<void> _submitGantiPin() async {
    final validationMessage = validatePinEntry(pin, confirmPin);
    if (validationMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(validationMessage)));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await BankingService.changePin(newPin: pin, newPinConfirm: confirmPin);

      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN Berhasil Diperbarui! Silakan Lanjut Bayar'),
        ),
      );

      Navigator.pop(context, true);
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
    final validationMessage = validatePinEntry(pin, confirmPin);
    if (validationMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationMessage), backgroundColor: Colors.red),
      );
      return;
    }

    final flowData = widget.flowData;
    final flowValidationMessage = validateRegistrationFlowData(flowData);
    if (flowValidationMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(flowValidationMessage),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirmedFlowData = flowData!;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await AuthService.register(
        otpReference: confirmedFlowData.otpReference,
        phoneNumber: confirmedFlowData.phoneNumber,
        email: confirmedFlowData.email,
        password: confirmedFlowData.password!,
        name: confirmedFlowData.name ?? '',
        nik: confirmedFlowData.nik ?? '',
        bornPlace: confirmedFlowData.bornPlace ?? '-',
        bornDate: confirmedFlowData.bornDate ?? '',
        gender: confirmedFlowData.gender ?? 'Other',
        address: confirmedFlowData.address ?? '',
        religion: confirmedFlowData.religion ?? '',
        motherName: confirmedFlowData.motherName ?? '',
        pin: pin,
        ktpFile: confirmedFlowData.ktpFile!,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi Berhasil! Silakan Login'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(
            prefilledEmail: confirmedFlowData.email,
            isAfterRegister: true,
          ),
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
                                              } else if (widget.isFromCs) {
                                                _submitGantiPin();
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
