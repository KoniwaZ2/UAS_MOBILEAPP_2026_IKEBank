import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '10_detail_kartu_2_screen.dart';

class RegistrasiPinDetailScreen extends StatefulWidget {
  const RegistrasiPinDetailScreen({super.key});

  @override
  State<RegistrasiPinDetailScreen> createState() =>
      _RegistrasiPinDetailScreenState();
}

class _RegistrasiPinDetailScreenState extends State<RegistrasiPinDetailScreen> {
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
        if (pin.length < 6) {
          setState(() {
            pin += key.keyLabel;
          });
        }
      }

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

                        const SizedBox(height: 35),

                        Row(
                          children:
                              List.generate(6, (i) => pinBox(i)),
                        ),

                        const Spacer(),

                        // BUTTON
                        Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            color: pin.length == 6
                                ? const Color(0xFFFF7F00)
                                : Colors.grey[400],
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius:
                                  BorderRadius.circular(30),
                              onTap: pin.length == 6
                                  ? () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const DetailKartu2Screen(),
                                        ),
                                      );
                                    }
                                  : null,
                              child: const Center(
                                child: Text(
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
        ),
      ),
    );
  }
}