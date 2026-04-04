import 'package:flutter/material.dart';
import 'qris_sukses_screen.dart';
import '../../../api/banking.dart';

class QrisPinScreen extends StatefulWidget {
  final String qrisNumber;
  final String merchantName;
  final String amount;
  final String location;
  final String aquirer;
  final String panId;
  final String walletName;
  final String walletBalance;

  const QrisPinScreen({
    super.key,
    required this.qrisNumber,
    required this.merchantName,
    required this.amount,
    required this.location,
    required this.aquirer,
    required this.panId,
    required this.walletName,
    required this.walletBalance,
  });

  @override
  State<QrisPinScreen> createState() => _QrisPinScreenState();
}

class _QrisPinScreenState extends State<QrisPinScreen> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isProcessing = false;

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> _processPayment() async {
    final pin = _pinController.text;

    if (pin.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN harus terdiri dari 6 digit')),
      );
      return null;
    }

    if (_isProcessing) {
      return null;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final response = await BankingService.bayarQris(
        pin: pin,
        qrisNumber: widget.qrisNumber,
        amount: widget.amount,
        category: 'payment',
        description: 'Pembayaran QRIS ke ${widget.qrisNumber}',
      );

      if (!mounted) {
        return null;
      }
      return response;
    } catch (e) {
      if (!mounted) {
        return null;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memproses pembayaran')),
      );
      return null;
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF9F2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "QRIS",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 24,
            fontFamily: 'AlumniSans',
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 50),

            const Text(
              "Masukkan PIN Keamananmu",
              style: TextStyle(
                fontFamily: 'AlumniSans',
                fontWeight: FontWeight.w800,
                fontSize: 24,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 40),

            GestureDetector(
              onTap: () => _focusNode.requestFocus(),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: 0.0,
                    child: TextField(
                      controller: _pinController,
                      focusNode: _focusNode,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      autofocus: true,
                      onChanged: (value) async {
                        setState(() {});

                        if (value.length != 6 || _isProcessing) {
                          return;
                        }

                        final paymentResponse = await _processPayment();
                        if (paymentResponse == null || !context.mounted) {
                          return;
                        }

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QrisSuksesScreen(
                              paymentResponse: paymentResponse,
                              qrisNumber: widget.qrisNumber,
                              merchantName: widget.merchantName,
                              amount: widget.amount,
                              location: widget.location,
                              aquirer: widget.aquirer,
                              panId: widget.panId,
                              walletName: widget.walletName,
                              walletBalance: widget.walletBalance,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBEBEB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: _pinController.text.length > index
                            ? Container(
                                width: 16,
                                height: 16,
                                decoration: const BoxDecoration(
                                  color: Colors.black,
                                  shape: BoxShape.circle,
                                ),
                              )
                            : null,
                      );
                    }),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 3. TOMBOL LUPA PIN
            GestureDetector(
              onTap: () {
                // TODO: Aksi Lupa PIN
              },
              child: const Text(
                "Lupa PIN?",
                style: TextStyle(
                  color: Color(0xFFFF7F00),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
