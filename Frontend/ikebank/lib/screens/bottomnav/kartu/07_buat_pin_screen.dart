import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../api/banking.dart';
import '../main_tab_screen.dart';

class BuatPinScreen extends StatefulWidget {
  final String cardLast6Digits;

  const BuatPinScreen({super.key, required this.cardLast6Digits});

  @override
  State<BuatPinScreen> createState() => _BuatPinScreenState();
}

class _BuatPinScreenState extends State<BuatPinScreen> {
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

  String _errorMessage(Object error) {
    final raw = error.toString();
    return raw.replaceFirst('Exception: ', '').trim();
  }

  Future<void> _submitActivateCard() async {
    final isPinValid = pin.length == 6 && confirmPin.length == 6 && pin == confirmPin;
    if (!isPinValid || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await BankingService.cardActivate(
        cardLast6Digits: widget.cardLast6Digits,
        newPIN: pin,
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainTabScreen(initialIndex: 3)),
        (Route<dynamic> route) => false,
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage(error)),
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
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFE5E5E5),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          i < val.length ? "•" : "",
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF7F00),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
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
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(counterText: ""),
                      ),
                    ),
                    
                    GestureDetector(
                      onTap: () => FocusScope.of(context).requestFocus(_pinFocusNode),
                      behavior: HitTestBehavior.opaque,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: IntrinsicHeight(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Buat PIN untuk Kartu Debit",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      "Masukkan PIN untuk kartumu",
                                      style: TextStyle(fontSize: 20, color: Colors.black),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 30),

                                    Row(children: List.generate(6, (i) => box(i, pin))),

                                    const SizedBox(height: 20),
                                    const Text(
                                      "Hindari menggunakan tanggal lahir serta angka yang berurutan dan berulang\n(Contoh: 123456, DDMMYY, 000000)",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color.fromARGB(255, 222, 219, 219),
                                        height: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 25),
                                    const Text(
                                      "Konfirmasi PIN kartumu",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    const SizedBox(height: 15),

                                    Row(children: List.generate(6, (i) => box(i, confirmPin))),

                                    const Spacer(), 

                                    Container(
                                      width: double.infinity,
                                      height: 65,
                                      decoration: BoxDecoration(
                                        color: (pin.length == 6 && confirmPin.length == 6 && pin == confirmPin && !_isSubmitting)
                                            ? const Color(0xFFFF7F00)
                                            : Colors.grey[400],
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(30),
                                          onTap: (pin.length == 6 && confirmPin.length == 6 && pin == confirmPin && !_isSubmitting)
                                              ? _submitActivateCard
                                              : null,
                                          child: Center(
                                            child: _isSubmitting
                                                ? const SizedBox(
                                                    width: 22,
                                                    height: 22,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2.5,
                                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                    ),
                                                  )
                                                : const Text(
                                                    "Lanjut",
                                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
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
}