import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../api/auth.dart';
import '../../../core/colors.dart';
import '../login/verifikasi_wajah_screen.dart';

class VerifikasiCodeScreen extends StatefulWidget {
  final String email;
  final String reference;

  const VerifikasiCodeScreen({
    super.key,
    required this.email,
    required this.reference,
  });

  @override
  State<VerifikasiCodeScreen> createState() => _VerifikasiCodeScreenState();
}

class _VerifikasiCodeScreenState extends State<VerifikasiCodeScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  bool _isResending = false;
  bool _isSubmitting = false;
  String _reference = '';

  @override
  void initState() {
    super.initState();
    _reference = widget.reference.trim();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < 5) {
        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
      } else {
        FocusScope.of(context).unfocus();
      }
    } else {
      if (index > 0) {
        FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
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
                          "Konfirmasi email kamu",
                          style: alumniSansBold.copyWith(
                            fontSize: 28,
                            color: AppColors.textBlack,
                          ),
                        ),
                        const SizedBox(height: 12),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textBlack,
                              height: 1.4,
                            ),
                            children: [
                              const TextSpan(
                                text:
                                    "Masukkan kode yang kami kirim lewat Email ke\n",
                              ),
                              TextSpan(
                                text: widget.email,
                                style: alumniSansBold,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),

                        // KOTAK OTP
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            6,
                            (index) => _buildOtpBox(index),
                          ),
                        ),

                        const SizedBox(height: 32),

                        Center(
                          child: TextButton(
                            onPressed: _isResending
                                ? null
                                : () async {
                                    setState(() {
                                      _isResending = true;
                                    });

                                    try {
                                      final otpRes =
                                          await AuthService.otpRequest(
                                            email: widget.email,
                                            purpose: 'login',
                                          );

                                      final otpRequests =
                                          (otpRes['otp_requests'] as List?) ??
                                          [];
                                      if (otpRequests.isNotEmpty) {
                                        _reference =
                                            (otpRequests.first
                                                    as Map<
                                                      String,
                                                      dynamic
                                                    >)['reference']
                                                ?.toString() ??
                                            _reference;
                                      }

                                      if (!context.mounted) {
                                        return;
                                      }
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'OTP berhasil dikirim ulang',
                                          ),
                                          backgroundColor: Colors.green,
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
                                          content: Text(e.toString()),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    } finally {
                                      if (context.mounted) {
                                        setState(() {
                                          _isResending = false;
                                        });
                                      }
                                    }
                                  },
                            child: Text(
                              'Kirim ulang kode',
                              style: alumniSansBold.copyWith(
                                fontSize: 16,
                                color: Colors.blue.shade700,
                              ),
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
                            onPressed: _isSubmitting
                                ? null
                                : () async {
                                    final otpCode = _controllers
                                        .map((c) => c.text)
                                        .join();

                                    final otpCodeTrimmed = otpCode.trim();

                                    if (_reference.isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Reference OTP tidak ditemukan. Silakan kirim ulang kode.',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    if (otpCodeTrimmed.length != 6) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Kode OTP harus 6 digit',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    setState(() {
                                      _isSubmitting = true;
                                    });

                                    try {
                                      await AuthService.otpVerify(
                                        reference: _reference,
                                        otpcode: otpCodeTrimmed,
                                        purpose: 'login',
                                      );

                                      if (!context.mounted) {
                                        return;
                                      }

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              VerifikasiWajahScreen(
                                                isFromRegister: false,
                                                email: widget.email,
                                                reference: _reference,
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
                                        ),
                                      );
                                    } finally {
                                      if (context.mounted) {
                                        setState(() {
                                          _isSubmitting = false;
                                        });
                                      }
                                    }
                                  },
                            child: Text(
                              _isSubmitting ? 'Memverifikasi...' : 'Lanjut',
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

  Widget _buildOtpBox(int index) {
    return Container(
      width: 45,
      height: 55,
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        onChanged: (value) => _onChanged(value, index),
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(border: InputBorder.none),
      ),
    );
  }
}
