import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PinLimitHarianScreen extends StatefulWidget {
  const PinLimitHarianScreen({super.key});

  @override
  State<PinLimitHarianScreen> createState() =>
      _PinLimitHarianScreenState();
}

class _PinLimitHarianScreenState
    extends State<PinLimitHarianScreen> {
  String pin = "";
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void handleKey(RawKeyEvent e) {
    if (e is RawKeyDownEvent) {
      final key = e.logicalKey;

      // input angka
      if (RegExp(r'^[0-9]$').hasMatch(key.keyLabel)) {
        if (pin.length < 6) {
          setState(() => pin += key.keyLabel);
        }
      }

      // backspace
      if (key == LogicalKeyboardKey.backspace &&
          pin.isNotEmpty) {
        setState(
            () => pin = pin.substring(0, pin.length - 1));
      }
    }
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
      body: RawKeyboardListener(
        focusNode: _focusNode,
        onKey: handleKey,
        child: GestureDetector(
          onTap: () => _focusNode.requestFocus(),
          child: SafeArea(
            child: Column(
              children: [
                //  HEADER
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // BODY
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

                        //  PIN BOX
                        Row(
                          children:
                              List.generate(6, (i) => box(i)),
                        ),

                        const Spacer(),

                        Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: SizedBox(
                            width: double.infinity,
                            height: 65,
                            child: ElevatedButton(
                              onPressed: pin.length == 6
                                  ? () {
                                      Navigator.pop(context);
                                      Navigator.pop(context);
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