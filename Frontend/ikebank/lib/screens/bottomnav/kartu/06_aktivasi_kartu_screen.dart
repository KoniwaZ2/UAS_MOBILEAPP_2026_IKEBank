import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '07_buat_pin_screen.dart';

class AktivasiKartuScreen extends StatefulWidget {
  const AktivasiKartuScreen({super.key});

  @override
  State<AktivasiKartuScreen> createState() =>
      _AktivasiKartuScreenState();
}

class _AktivasiKartuScreenState extends State<AktivasiKartuScreen> {
  String kode = "";
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void handleKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      final key = event.logicalKey;

      // input angka
      if (key.keyLabel.isNotEmpty &&
          RegExp(r'^[0-9]$').hasMatch(key.keyLabel)) {
        addDigit(key.keyLabel);
      }

      // backspace
      if (key == LogicalKeyboardKey.backspace) {
        deleteDigit();
      }
    }
  }

  void addDigit(String n) {
    if (kode.length < 6) {
      setState(() => kode += n);
    }
  }

  void deleteDigit() {
    if (kode.isNotEmpty) {
      setState(() => kode = kode.substring(0, kode.length - 1));
    }
  }

  // BOX WIDGET
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

      body: RawKeyboardListener(
        focusNode: _focusNode,
        onKey: handleKey,
        child: GestureDetector(
          onTap: () => _focusNode.requestFocus(),
          child: SafeArea(
            child: Column(
              children: [
                // 🔶 HEADER
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.white),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // BODY
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Masukkan 6 digit terakhir kartumu",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // PIN BOX
                        Row(
                          children:
                              List.generate(6, (i) => box(i)),
                        ),

                        const Spacer(),

                        // BUTTON
                        Container(
                          width: double.infinity,
                          height: 65,
                          decoration: BoxDecoration(
                            color: kode.length == 6
                                ? const Color(0xFFFF7F00)
                                : Colors.grey[400],
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius:
                                  BorderRadius.circular(30),
                              onTap: kode.length == 6
                                  ? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const BuatPinScreen(),
                                        ),
                                      );
                                    }
                                  : null,
                              child: const Center(
                                child: Text(
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
        ),
      ),
    );
  }
}