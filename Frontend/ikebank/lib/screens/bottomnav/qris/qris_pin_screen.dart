import 'package:flutter/material.dart';
import 'qris_sukses_screen.dart';

class QrisPinScreen extends StatefulWidget {
  const QrisPinScreen({super.key});

  @override
  State<QrisPinScreen> createState() => _QrisPinScreenState();
}

class _QrisPinScreenState extends State<QrisPinScreen> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
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
                      onChanged: (value) {
                        setState(() {}); 
                        
                        // JIKA PIN SUDAH 6 DIGIT:
                        if (value.length == 6) {
                          print("PIN yang dimasukkan: $value"); 
                          
                          Future.delayed(const Duration(milliseconds: 500), () {
                            // Pastikan widget masih aktif
                            if (!context.mounted) return;
                            
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const QrisSuksesScreen()),
                            );
                          });
                        }
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