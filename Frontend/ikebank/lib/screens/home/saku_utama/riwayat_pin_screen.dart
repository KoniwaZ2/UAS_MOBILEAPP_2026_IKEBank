import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'riwayat_berhasil.dart';

class RiwayatPinScreen extends StatefulWidget {
  final String namaPenerima;
  final String nomorRekening;
  final String jumlah;
  final String sumberDana;

  const RiwayatPinScreen({
    super.key,
    required this.namaPenerima,
    required this.nomorRekening,
    required this.jumlah,
    required this.sumberDana,
  });

  @override
  State<RiwayatPinScreen> createState() => _RiwayatPinScreenState();
}

class _RiwayatPinScreenState extends State<RiwayatPinScreen> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();
  String _pin = "";

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0x1AFFCA96), 
        elevation: 0,
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Transfer Dana",
          style: TextStyle(
            fontFamily: 'AlumniSans',
            fontWeight: FontWeight.w800,
            fontSize: 24,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Masukkan PIN Keamananmu",
                style: TextStyle(
                  fontFamily: 'AlumniSans',
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 32),
              
              Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: 0.0,
                    child: TextField(
                      controller: _pinController,
                      focusNode: _pinFocusNode,
                      keyboardType: TextInputType.number,
                      autofocus: true, 
                      maxLength: 6,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        setState(() {
                          _pin = value;
                        });
                        
                        // Jika PIN sudah 6 digit, otomatis proses
                        if (value.length == 6) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RiwayatBerhasilScreen(
                                namaPenerima: widget.namaPenerima,
                                nomorRekening: widget.nomorRekening,
                                jumlah: widget.jumlah,
                                sumberDana: widget.sumberDana,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  
                  GestureDetector(
                    onTap: () {
                      FocusScope.of(context).requestFocus(_pinFocusNode);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (index) {
                        return Container(
                          width: 45,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200, 
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            index < _pin.length ? '•' : '',
                            style: const TextStyle(
                              fontSize: 32,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}