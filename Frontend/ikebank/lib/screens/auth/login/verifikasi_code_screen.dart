import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import '../../../core/colors.dart';
import 'verifikasi_wajah_screen.dart'; 

class VerifikasiCodeScreen extends StatefulWidget {
  final String emailUser; 

  const VerifikasiCodeScreen({super.key, required this.emailUser});

  @override
  State<VerifikasiCodeScreen> createState() => _VerifikasiCodeScreenState();
}

class _VerifikasiCodeScreenState extends State<VerifikasiCodeScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

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
                          "Konfirmasi email kamu", 
                          style: alumniSansBold.copyWith(
                            fontSize: 32,
                            color: AppColors.textBlack,
                          ),
                        ),
                        const SizedBox(height: 12),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.textBlack,
                              height: 1.4,
                            ),
                            children: [
                              const TextSpan(text: "Masukkan kode yang kami kirim lewat Email ke\n"), 
                              TextSpan(
                                text: widget.emailUser, 
                                style: alumniSansBold, 
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),

                        // KOTAK OTP 
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, (index) => _buildOtpBox(index)),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        Center(
                          child: TextButton(
                            onPressed: () {
                            },
                            child: Text(
                              'Kirim ulang kode',
                              style: alumniSansBold.copyWith(
                                fontSize: 16, 
                                color: Colors.blue.shade700
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
                            onPressed: () {
                              Navigator.push(
                                context, 
                                MaterialPageRoute(builder: (context) => const VerifikasiWajahScreen())
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
        decoration: const InputDecoration(
          border: InputBorder.none, 
        ),
      ),
    );
  }
}