import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main_tab_screen.dart'; // 🔥 WAJIB

class RegistrasiPinBlockScreen extends StatefulWidget {
  const RegistrasiPinBlockScreen({super.key});

  @override
  State<RegistrasiPinBlockScreen> createState() =>
      _RegistrasiPinBlockScreenState();
}

class _RegistrasiPinBlockScreenState
    extends State<RegistrasiPinBlockScreen> {
  String pin = "";
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
        if (pin.length < 6) {
          setState(() {
            pin += key.keyLabel;
          });
        }
      }

      // backspace
      if (key == LogicalKeyboardKey.backspace) {
        if (pin.isNotEmpty) {
          setState(() {
            pin = pin.substring(0, pin.length - 1);
          });
        }
      }
    }
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
      body: RawKeyboardListener(
        focusNode: _focusNode,
        onKey: handleKey,
        child: GestureDetector(
          onTap: () => _focusNode.requestFocus(),
          child: SafeArea(
            child: Column(
              children: [
                // 🔥 HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),

                // BODY
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 30),
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
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          "Setelah blokir sementara kamu dapat membukanya kembali melalui menu kartu debit",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // PIN BOX
                        Row(
                          children:
                              List.generate(6, (i) => pinBox(i)),
                        ),

                        const Spacer(),

                        // BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 65,
                          child: ElevatedButton(
                            onPressed: pin.length == 6
                                ? () {
                                   Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const MainTabScreen(initialIndex: 6),
                                  ),
                                  (route) => false,
                                );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFFFF7F00),
                              disabledBackgroundColor:
                                  Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(35),
                              ),
                            ),
                            child: const Text(
                              "Lanjut",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}