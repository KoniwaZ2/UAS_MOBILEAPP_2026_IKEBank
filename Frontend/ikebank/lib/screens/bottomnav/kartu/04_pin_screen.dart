import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '02_buat_kartu_screen_2.dart';
import '05_kartu_berhasil_screen.dart';
import '../../../api/banking.dart';

enum PinEntrySource { buatKartu, kartuTab, other }

class PinScreen extends StatefulWidget {
  final String nama;
  final String sourceFundsId;
  final PinEntrySource entrySource;

  const PinScreen({
    super.key,
    required this.nama,
    this.sourceFundsId = '',
    this.entrySource = PinEntrySource.other,
  });

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  String pin = "";
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSubmitting = false;
  bool _isCheckingCardState = false;
  bool _hasKartu = false;
  String _cardStatus = 'none';

  @override
  void initState() {
    super.initState();
    _pinController.addListener(_onPinInputChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _resolveCardState();
    });
  }

  void _onPinInputChanged() {
    if (_isSubmitting) {
      return;
    }

    final value = _pinController.text.trim();
    final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
    final normalized = digitsOnly.length > 6
        ? digitsOnly.substring(0, 6)
        : digitsOnly;

    if (normalized == pin) {
      return;
    }

    setState(() {
      pin = normalized;
    });

    if (_pinController.text != normalized) {
      _pinController.value = TextEditingValue(
        text: normalized,
        selection: TextSelection.collapsed(offset: normalized.length),
      );
    }

    if (pin.length == 6) {
      _submitCardRequest();
    }
  }

  bool get _isBackBlocked {
    final status = _cardStatus.trim().toLowerCase();
    return _hasKartu && (status == 'active' || status == 'requested');
  }

  Future<void> _resolveCardState() async {
    setState(() {
      _isCheckingCardState = true;
    });

    bool resolvedHasKartu = false;
    String resolvedCardStatus = 'none';

    try {
      final accountDetails = await BankingService.fetchAccountDetails();
      final hasCardNumber = accountDetails.any(
        (account) => account.cardnumber?.trim().isNotEmpty ?? false,
      );
      resolvedHasKartu = hasCardNumber;
      resolvedCardStatus = hasCardNumber ? 'requested' : 'none';

      try {
        final detail = await BankingService.cardDetails();
        if (detail is Map<String, dynamic>) {
          final status = (detail['card_status'] ?? 'none')
              .toString()
              .trim()
              .toLowerCase();
          final cardNumber = (detail['card_number'] ?? '').toString().trim();
          final hasStatusKartu = status == 'active' ||
              status == 'requested' ||
              status == 'delivered';

          resolvedCardStatus = status.isEmpty ? 'none' : status;
          resolvedHasKartu =
              hasCardNumber || cardNumber.isNotEmpty || hasStatusKartu;

          if (resolvedCardStatus.contains('block')) {
            resolvedCardStatus = 'none';
            resolvedHasKartu = false;
          }
        }
      } catch (_) {
        // Keep fallback from account-details when card-details is unavailable.
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _hasKartu = resolvedHasKartu;
        _cardStatus = resolvedCardStatus.isEmpty ? 'none' : resolvedCardStatus;
      });
    } finally {
      if (!mounted) {
        return;
      }

      setState(() {
        _isCheckingCardState = false;
      });
    }
  }

  Future<void> _handleBackPressed() async {
    if (_isSubmitting || _isCheckingCardState) {
      return;
    }

    if (_isBackBlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kartu sudah requested/active, tidak bisa kembali.'),
        ),
      );
      return;
    }

    if (widget.entrySource == PinEntrySource.buatKartu ||
        widget.entrySource == PinEntrySource.kartuTab) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BuatKartuScreen2()),
      );
      return;
    }

    final popped = await Navigator.maybePop(context);
    if (!popped && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BuatKartuScreen2()),
      );
    }
  }

  Future<bool> _onWillPop() async {
    await _handleBackPressed();
    return false;
  }

  String _errorMessage(Object error) {
    final raw = error.toString();
    return raw.replaceFirst('Exception: ', '').trim();
  }

  Future<String> _resolveSourceFundsId() async {
    final directSourceFundsId = widget.sourceFundsId.trim();
    if (directSourceFundsId.isNotEmpty) {
      return directSourceFundsId;
    }

    try {
      final accountDetails = await BankingService.fetchAccountDetails();
      if (accountDetails.isNotEmpty) {
        return accountDetails.first.userid.toString().trim();
      }
    } catch (_) {
      // Fall through to empty string so the request can fail with a clear error.
    }

    return '';
  }

  Future<void> _submitCardRequest() async {
    if (_isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final sourceFundsId = await _resolveSourceFundsId();
      if (sourceFundsId.isEmpty) {
        throw Exception('Source funds ID tidak ditemukan.');
      }

      await BankingService.cardRequest(
        userPin: pin,
        sourceFundsId: sourceFundsId,
      );

      if (!mounted) {
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const KartuBerhasilScreen()),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        pin = '';
        _pinController.clear();
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage(error)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget pinBox(int index) {
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
          index < pin.length ? "•" : "",
          style: const TextStyle(fontSize: 26),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFFF7F00),

        body: GestureDetector(
          onTap: () => _focusNode.requestFocus(),
          child: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    // HEADER
                    Container(
                      padding: const EdgeInsets.only(top: 10, bottom: 18),
                      color: const Color(0xFFFF7F00),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: _isSubmitting || _isCheckingCardState
                                ? null
                                : _handleBackPressed,
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // CONTENT
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
                            const SizedBox(height: 20),

                            // JUDUL
                            const Text(
                              "Masukkan PIN keamananmu",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 40),

                            // PIN BOX
                            Row(children: List.generate(6, (i) => pinBox(i))),
                            const SizedBox(height: 16),
                            if (_isSubmitting || _isCheckingCardState)
                              const CircularProgressIndicator(
                                color: Color(0xFFFF7F00),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Opacity(
                      opacity: 0.0,
                      child: TextField(
                        controller: _pinController,
                        focusNode: _focusNode,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        enableSuggestions: false,
                        autocorrect: false,
                        maxLength: 6,
                        autofocus: true,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onSubmitted: (value) {
                          if (value.trim().length == 6) {
                            _submitCardRequest();
                          }
                        },
                        decoration: const InputDecoration(counterText: ''),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pinController.removeListener(_onPinInputChanged);
    _focusNode.dispose();
    _pinController.dispose();
    super.dispose();
  }
}
