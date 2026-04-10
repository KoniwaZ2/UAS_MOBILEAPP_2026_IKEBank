import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'riwayat_berhasil.dart';
import '../../../api/banking.dart';

class RiwayatPinScreen extends StatefulWidget {
  final String namaPenerima;
  final String nomorRekening;
  final String jumlah;
  final String sumberDana;

  const RiwayatPinScreen({
    super.key,
    required this.namaPenerima,
    required this.nomorRekening,
    required this.jumlah,
    required this.sumberDana,
  });

  @override
  State<RiwayatPinScreen> createState() => _RiwayatPinScreenState();
}

class _RiwayatPinScreenState extends State<RiwayatPinScreen> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();
  String _pin = "";
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _pinController.addListener(_onPinInputChanged);
  }

  void _onPinInputChanged() {
    if (!mounted || _isSubmitting) {
      return;
    }

    final value = _pinController.text.trim();
    if (value == _pin) {
      return;
    }

    setState(() {
      _pin = value;
    });

    if (value.length == 6) {
      _submitTransfer(value);
    }
  }

  String _extractAmountDigits(String formattedText) {
    return formattedText.replaceAll(RegExp(r'[^0-9]'), '');
  }

  Future<void> _submitTransfer(String pinValue) async {
    if (_isSubmitting) {
      return;
    }

    if (pinValue.trim().length != 6) {
      return;
    }

    final amountDigits = _extractAmountDigits(widget.jumlah);
    if (amountDigits.isEmpty || (int.tryParse(amountDigits) ?? 0) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal transfer tidak valid')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await BankingService.transferOut(
        pin: pinValue,
        destinationAccount: widget.nomorRekening,
        amount: amountDigits,
        description: 'Transfer ke ${widget.namaPenerima}',
      );

      if (!mounted) {
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RiwayatBerhasilScreen(
            namaPenerima: widget.namaPenerima,
            nomorRekening: widget.nomorRekening,
            jumlah: widget.jumlah,
            sumberDana: widget.sumberDana,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      final message = e
          .toString()
          .replaceFirst('Exception: ', '')
          .replaceFirst(RegExp(r'^Failed to transfer out \(HTTP \d+\):\s*'), '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message.isEmpty ? 'Transfer gagal' : message)),
      );

      setState(() {
        _pin = '';
        _pinController.clear();
      });
      FocusScope.of(context).requestFocus(_pinFocusNode);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0x1AFFCA96),
        elevation: 0,
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Transfer Dana",
          style: TextStyle(
            fontFamily: 'AlumniSans',
            fontWeight: FontWeight.w800,
            fontSize: 24,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Masukkan PIN Keamananmu",
                style: TextStyle(
                  fontFamily: 'AlumniSans',
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 32),

              Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: 0.0,
                    child: TextField(
                      controller: _pinController,
                      focusNode: _pinFocusNode,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      maxLength: 6,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onSubmitted: (value) {
                        if (value.trim().length == 6) {
                          _submitTransfer(value.trim());
                        }
                      },
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      FocusScope.of(context).requestFocus(_pinFocusNode);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (index) {
                        return Container(
                          width: 45,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            index < _pin.length ? '•' : '',
                            style: const TextStyle(
                              fontSize: 32,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
              if (_isSubmitting) ...[
                const SizedBox(height: 20),
                const CircularProgressIndicator(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
