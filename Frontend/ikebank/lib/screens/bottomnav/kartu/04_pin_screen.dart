import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '05_kartu_berhasil_screen.dart';

class PinScreen extends StatefulWidget {
  final String nama;

  const PinScreen({super.key, required this.nama});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
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

      if (key.keyLabel.isNotEmpty &&
          RegExp(r'^[0-9]$').hasMatch(key.keyLabel)) {
        addPin(key.keyLabel);
      }

      if (key == LogicalKeyboardKey.backspace) {
        deletePin();
      }
    }
  }

  void addPin(String number) {
    if (pin.length < 6) {
      setState(() {
        pin += number;
      });

      if (pin.length == 6) {
        Future.delayed(const Duration(milliseconds: 300), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const KartuBerhasilScreen(),
            ),
          );
        });
      }
    }
  }

  void deletePin() {
    if (pin.isNotEmpty) {
      setState(() {
        pin = pin.substring(0, pin.length - 1);
      });
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
                Container(
                  padding: const EdgeInsets.only(
                    top: 10,
                    bottom: 18,
                  ),
                  color: const Color(0xFFFF7F00),
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

                // CONTENT
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
                        Row(
                          children:
                              List.generate(6, (i) => pinBox(i)),
                        ),
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