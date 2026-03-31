import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../api/auth.dart';
import '../../../core/colors.dart';
import 'foto_ktp_screen.dart'; // Nanti kita buat file ini

class VerifikasiKodeScreen extends StatefulWidget {
  final String email; // Hapus teks dummy-nya
  final String phone;
  final String reference;

  // Tambahkan 'required this.email' agar wajib diisi saat dipanggil
  const VerifikasiKodeScreen({
    super.key,
    required this.email,
    required this.phone,
    required this.reference,
  });

  @override
  State<VerifikasiKodeScreen> createState() => _VerifikasiKodeScreenState();
}

class _VerifikasiKodeScreenState extends State<VerifikasiKodeScreen> {
  // Membuat 6 FocusNode dan Controller untuk masing-masing kotak OTP
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  bool _isSubmitting = false;
  bool _isResending = false;
  String _reference = '';

  @override
  void initState() {
    super.initState();
    _reference = widget.reference;
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Logika untuk pindah kotak otomatis saat mengetik atau menghapus
  void _onOtpChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index].unfocus();
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index].unfocus();
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle alumniSansBold = TextStyle(fontWeight: FontWeight.w700);

    return Scaffold(
      backgroundColor: AppColors.primaryOrange,
      // ==========================================================
      // APP BAR & PROGRESS BAR (Tahap 2)
      // ==========================================================
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
                // Progress Bar: 2 Nyala (Gradasi Biru), 4 Mati (Putih Transparan)
                _buildProgressSegment(isActive: true),
                _buildProgressSegment(isActive: true),
                _buildProgressSegment(isActive: false),
                _buildProgressSegment(isActive: false),
                _buildProgressSegment(isActive: false),
                _buildProgressSegment(isActive: false),
              ],
            ),
          ),
        ),
      ),

      // ==========================================================
      // KONTEN UTAMA
      // ==========================================================
      body: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(
          top: 16.0,
        ), // Perbaikan dari EdgeInsets.top menjadi .only(top:)
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
                        // ==========================================================
                        // TEKS JUDUL & DESKRIPSI
                        // ==========================================================
                        Text(
                          "Konfirmasi email kamu",
                          style: alumniSansBold.copyWith(
                            fontSize: 36,
                            color: AppColors.textBlack,
                          ),
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.textBlack,
                              height: 1.4,
                            ),
                            children: [
                              const TextSpan(
                                text:
                                    "Masukkan kode yang kami kirim lewat email ke\n",
                              ),
                              TextSpan(
                                text: widget.email,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            6,
                            (index) => _buildOtpBox(index),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // TOMBOL KIRIM ULANG KODE
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
                                            purpose: 'registration',
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
                            child: const Text(
                              "Kirim ulang kode",
                              style: TextStyle(
                                color: Color(0xFF0000FF),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
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
                                        purpose: 'registration',
                                      );

                                      if (!context.mounted) {
                                        return;
                                      }

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => FotoKtpScreen(
                                            phone: widget.phone,
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

  // --- FUNGSI HELPER UNTUK KOTAK OTP ---
  Widget _buildOtpBox(int index) {
    return Container(
      width: 45,
      height: 55,
      decoration: BoxDecoration(
        color: AppColors.inputGrey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: "",
        ),
        onChanged: (value) => _onOtpChanged(value, index),
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
