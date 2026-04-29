import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../api/banking.dart';
import '10_detail_kartu_2_screen.dart';

class RegistrasiPinDetailScreen extends StatefulWidget {
  const RegistrasiPinDetailScreen({super.key});

  @override
  State<RegistrasiPinDetailScreen> createState() =>
      _RegistrasiPinDetailScreenState();
}

class _RegistrasiPinDetailScreenState extends State<RegistrasiPinDetailScreen> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String pin = "";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Memasang listener gaya eleganmu
    _pinController.addListener(_onPinInputChanged);
  }

  void _onPinInputChanged() {
    if (!mounted || _isLoading) return;

    // Filter hanya angka
    final value = _pinController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (value != _pinController.text) {
      _pinController.text = value;
      _pinController.selection = TextSelection.collapsed(offset: value.length);
    }

    if (value == pin) return;

    setState(() {
      pin = value;
    });
  }

  String _errorMessage(Object error) {
    return error.toString().replaceFirst('Exception: ', '').trim();
  }

  Future<void> _handleContinue() async {
    if (_isLoading || pin.length != 6) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await BankingService.cardGetDetails(userPin: pin);

      if (!mounted) {
        return;
      }

      if (result is! Map<String, dynamic>) {
        throw Exception('Format respons detail kartu tidak valid.');
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DetailKartu2Screen(cardDetails: result),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_errorMessage(error))));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _pinController.removeListener(_onPinInputChanged);
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Widget pinBox(int i) {
    return Expanded(
      child: Container(
        height: 55,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFE5E5E5),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          i < pin.length ? "•" : "",
          style: const TextStyle(fontSize: 26),
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
            // HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ],
              ),
            ),

            // BODY
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 30,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Masukkan PIN keamananmu",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 35),

                    // PIN BOX (Trik Stack & Opacity 0)
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Opacity(
                          opacity: 0.0,
                          child: TextField(
                            controller: _pinController,
                            focusNode: _focusNode,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            maxLengthEnforcement: MaxLengthEnforcement.enforced,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(counterText: ""),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => FocusScope.of(context).requestFocus(_focusNode),
                          behavior: HitTestBehavior.opaque,
                          child: Row(children: List.generate(6, (i) => pinBox(i))),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // BUTTON
                    Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        color: (pin.length == 6 && !_isLoading)
                            ? const Color(0xFFFF7F00)
                            : Colors.grey[400],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: (pin.length == 6 && !_isLoading)
                              ? _handleContinue
                              : null,
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    "Lanjut",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
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