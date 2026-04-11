import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../api/banking.dart';

class PinLimitHarianScreen extends StatefulWidget {
  final int dailyWithdrawalLimit;
  final int dailyTransactionLimit;
  final int dailySingleTransactionLimit;

  const PinLimitHarianScreen({
    super.key,
    required this.dailyWithdrawalLimit,
    required this.dailyTransactionLimit,
    required this.dailySingleTransactionLimit,
  });

  @override
  State<PinLimitHarianScreen> createState() =>
      _PinLimitHarianScreenState();
}

class _PinLimitHarianScreenState extends State<PinLimitHarianScreen> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String pin = "";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pinController.addListener(_onPinInputChanged);
  }

  void _onPinInputChanged() {
    if (!mounted || _isLoading) return;

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
      await BankingService.setDailyLimit(
        pinUser: pin,
        dailyWithdrawalLimit: widget.dailyWithdrawalLimit,
        dailyTransactionLimit: widget.dailyTransactionLimit,
        dailySingleTransactionLimit: widget.dailySingleTransactionLimit,
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(context);
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage(error))),
      );
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 25, 20, 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30),
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
                                    child: Row(
                                      children: List.generate(6, (i) => box(i)),
                                    ),
                                  ),
                                ],
                              ),

                              const Spacer(),

                              // BUTTON
                              Padding(
                                padding: const EdgeInsets.only(bottom: 15),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 65,
                                  child: ElevatedButton(
                                    onPressed: (pin.length == 6 && !_isLoading)
                                        ? _handleContinue
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFF7F00),
                                      disabledBackgroundColor: Colors.grey,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(35),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
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
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}