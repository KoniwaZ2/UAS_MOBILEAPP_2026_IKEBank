import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '07_buat_pin_screen.dart';
import '../../../api/banking.dart';

class AktivasiKartuScreen extends StatefulWidget {
  const AktivasiKartuScreen({super.key});

  @override
  State<AktivasiKartuScreen> createState() => _AktivasiKartuScreenState();
}

class _AktivasiKartuScreenState extends State<AktivasiKartuScreen> {
  final TextEditingController _kodeController = TextEditingController();
  final FocusNode _kodeFocusNode = FocusNode();
  String kode = "";
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _kodeController.addListener(_onKodeInputChanged);
  }

  void _onKodeInputChanged() {
    if (!mounted || _isSubmitting) return;

    final value = _kodeController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (value != _kodeController.text) {
      _kodeController.text = value;
      _kodeController.selection = TextSelection.collapsed(offset: value.length);
    }

    if (value == kode) return;

    setState(() {
      kode = value;
    });
  }

  String _errorMessage(Object error) {
    final raw = error.toString();
    return raw.replaceFirst('Exception: ', '').trim();
  }

  Future<void> _submitCardActivation() async {
    if (_isSubmitting || kode.length != 6) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await BankingService.cardVerify(cardLast6Digits: kode);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BuatPinScreen(cardLast6Digits: kode),
        ),
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
    _kodeController.removeListener(_onKodeInputChanged);
    _kodeController.dispose();
    _kodeFocusNode.dispose();
    super.dispose();
  }

  Widget box(int i) {
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
          i < kode.length ? "•" : "",
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
            Row(
              children: [
                IconButton(
                  onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Masukkan 6 digit terakhir kartumu",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),

                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Opacity(
                          opacity: 0.0,
                          child: TextField(
                            controller: _kodeController,
                            focusNode: _kodeFocusNode,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            maxLengthEnforcement: MaxLengthEnforcement.enforced,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(counterText: ""),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => FocusScope.of(context).requestFocus(_kodeFocusNode),
                          child: Row(children: List.generate(6, (i) => box(i))),
                        ),
                      ],
                    ),

                    const Spacer(),

                    Container(
                      width: double.infinity,
                      height: 65,
                      decoration: BoxDecoration(
                        color: (kode.length == 6 && !_isSubmitting)
                            ? const Color(0xFFFF7F00)
                            : Colors.grey[400],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: (kode.length == 6 && !_isSubmitting)
                              ? _submitCardActivation
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
                                    style: TextStyle(
                                      fontSize: 20,
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