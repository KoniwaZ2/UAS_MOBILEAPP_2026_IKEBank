import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../api/auth.dart';

class UbahPinScreen extends StatefulWidget {
  const UbahPinScreen({super.key});

  @override
  State<UbahPinScreen> createState() => _UbahPinScreenState();
}

class _UbahPinScreenState extends State<UbahPinScreen> {
  final TextEditingController _pinLamaController = TextEditingController();
  final TextEditingController _pinBaruController = TextEditingController();
  final TextEditingController _konfirmasiPinController =
      TextEditingController();
  bool _isSubmitting = false;

  final TextStyle alumniSansBold = const TextStyle(
    fontWeight: FontWeight.w800,
    fontFamily: 'AlumniSans',
  );

  @override
  void dispose() {
    _pinLamaController.dispose();
    _pinBaruController.dispose();
    _konfirmasiPinController.dispose();
    super.dispose();
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
                              "Masukkan PIN Lama Kamu",
                              style: alumniSansBold.copyWith(
                                fontSize: 24,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Masukkan PIN keamananmu",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildPinInput(_pinLamaController),
                            const SizedBox(height: 40),

                            Text(
                              "Masukkan PIN Baru Kamu",
                              style: alumniSansBold.copyWith(
                                fontSize: 24,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildPinInput(_pinBaruController),
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

                            Text(
                              "Konfirmasi PIN keamananmu",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildPinInput(_konfirmasiPinController),
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
                          onPressed: _isSubmitting ? null : _submitChangePin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF7F00),
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

  Future<void> _submitChangePin() async {
    final oldPin = _pinLamaController.text.trim();
    final newPin = _pinBaruController.text.trim();
    final confirmPin = _konfirmasiPinController.text.trim();

    if (oldPin.length != 6 || newPin.length != 6 || confirmPin.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN harus terdiri dari 6 digit.'), backgroundColor: Colors.red),
      );
      return;
    }

    if (newPin == oldPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN baru tidak boleh sama dengan PIN lama.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (newPin != confirmPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfirmasi PIN tidak cocok.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await AuthService.changePIN(
        oldPin: oldPin,
        newPin: newPin,
        newPinConfirmation: confirmPin,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('PIN berhasil diubah!'), backgroundColor: Colors.green));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Widget _buildPinInput(TextEditingController controller) {
    return SizedBox(
      height: 50,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (index) {
              bool isFilled = index < controller.text.length;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: isFilled
                    ? const Center(
                        child: CircleAvatar(
                          radius: 6,
                          backgroundColor: Colors.black,
                        ),
                      )
                    : null,
              );
            }),
          ),

          Opacity(
            opacity: 0.0,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 6,
              cursorColor: Colors.transparent,
              onChanged: (value) {
                setState(() {});
              },
              decoration: const InputDecoration(
                counterText: "",
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
