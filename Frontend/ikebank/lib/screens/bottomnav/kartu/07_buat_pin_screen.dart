import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main_tab_screen.dart';

class BuatPinScreen extends StatefulWidget {
  const BuatPinScreen({super.key});

  @override
  State<BuatPinScreen> createState() => _BuatPinScreenState();
}

class _BuatPinScreenState extends State<BuatPinScreen> {
  String pin = "";
  String confirmPin = "";

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

      if (key.keyLabel.isNotEmpty &&
          RegExp(r'^[0-9]$').hasMatch(key.keyLabel)) {
        add(key.keyLabel);
      }

      if (key == LogicalKeyboardKey.backspace) {
        delete();
      }
    }
  }

  void add(String n) {
    setState(() {
      if (pin.length < 6) {
        pin += n;
      } else if (confirmPin.length < 6) {
        confirmPin += n;
      }
    });
  }

  void delete() {
    setState(() {
      if (confirmPin.isNotEmpty) {
        confirmPin =
            confirmPin.substring(0, confirmPin.length - 1);
      } else if (pin.isNotEmpty) {
        pin = pin.substring(0, pin.length - 1);
      }
    });
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
      body: RawKeyboardListener(
        focusNode: _focusNode,
        onKey: handleKey,
        child: GestureDetector(
          onTap: () => _focusNode.requestFocus(),
          child: SafeArea(
            child: Column(
              children: [
                // HEADER
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
                        horizontal: 20, vertical: 25),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // TITLE
                        const Text(
                          "Buat PIN untuk Kartu Debit",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          "Masukkan PIN untuk kartumu",
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 30),

                        Row(
                          children:
                              List.generate(6, (i) => box(i, pin)),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "Hindari menggunakan tanggal lahir serta angka yang berurutan dan berulang\n(Contoh: 123456, DDMMYY, 000000)",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            color: Color.fromARGB(255, 222, 219, 219),
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 25),

                        const Text(
                          "Konfirmasi PIN kartumu",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),

                        const SizedBox(height: 15),

                        Row(
                          children: List.generate(
                              6, (i) => box(i, confirmPin)),
                        ),

                        const Spacer(),

                        Container(
                          width: double.infinity,
                          height: 65,
                          decoration: BoxDecoration(
                            color: (pin.length == 6 &&
                                    confirmPin.length == 6 &&
                                    pin == confirmPin)
                                ? const Color(0xFFFF7F00)
                                : Colors.grey[400],
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius:
                                  BorderRadius.circular(30),
                              onTap: (pin.length == 6 &&
                                      confirmPin.length == 6 &&
                                      pin == confirmPin)
                                  ? () {
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const MainTabScreen(
                                                  initialIndex: 5),
                                        ),
                                        (Route<dynamic> route) => false,
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