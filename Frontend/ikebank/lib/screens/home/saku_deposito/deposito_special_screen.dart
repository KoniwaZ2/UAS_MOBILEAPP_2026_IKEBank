import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart'; 
import 'deposito_konfirmasi_screen.dart';

class DepositoSpesialScreen extends StatefulWidget {
  final double sukuBunga;
  final int jangkaWaktuBulan;
  final bool isSpecial;

  const DepositoSpesialScreen({
    super.key,
    this.sukuBunga = 8.8, 
    this.jangkaWaktuBulan = 1, 
    this.isSpecial = true, 
  });

  @override
  State<DepositoSpesialScreen> createState() => _DepositoSpesialScreenState();
}

class _DepositoSpesialScreenState extends State<DepositoSpesialScreen> {
  final TextEditingController _amountController = TextEditingController();

  String _selectedSumber = "Saku Utama";
  String _selectedSumberSaldo = "Rp 3.000.000";

  @override
  void dispose() {
    _amountController.dispose();
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
        title: Text(
          widget.isSpecial ? "Deposito Spesial" : "Buka Deposito",
          style: const TextStyle(fontFamily: 'AlumniSans', fontWeight: FontWeight.w800, fontSize: 24, color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: 100,
              color: const Color(0x1AFFCA96),
            ),

            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade400, width: 1.5),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Bunga saat ini :",
                                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFFFF7F00)),
                                  ),
                                  Text(
                                    "${widget.sukuBunga}%p.a",
                                    style: const TextStyle(fontFamily: 'AlumniSans', fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFFFF7F00)),
                                  ),
                                ],
                              ),
                              
                              if (widget.isSpecial) ...[
                                const SizedBox(height: 24),
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      height: 12,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.black, width: 1),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(9),
                                        child: const LinearProgressIndicator(
                                          value: 0.9, 
                                          backgroundColor: Colors.transparent,
                                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF7F00)),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 20, 
                                      top: -24,
                                      child: SvgPicture.asset('assets/images/api.svg', height: 26), 
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  "Tersisa 90 kuota",
                                  style: TextStyle(fontSize: 18, color: Colors.black),
                                ),
                              ]
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            _CurrencyInputFormatter(), 
                          ],
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF5F5F5), 
                            hintText: "Jumlah penempatan",
                            hintStyle: const TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.normal),
                            
                            prefixText: 'Rp ',
                            prefixStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                            
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Colors.transparent),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFFFF7F00), width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 24.0),
                          child: Text(
                            "Min. Rp1.000.000 Maks Rp100.000.000",
                            style: TextStyle(fontSize: 18, color: Colors.grey.shade500),
                          ),
                        ),

                        const SizedBox(height: 16),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade400, width: 1.5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Sumber dana", style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
                                  const SizedBox(height: 4),
                                  Text(_selectedSumber, style: const TextStyle(fontSize: 18, color: Colors.black)),
                                  const SizedBox(height: 2),
                                  Text(_selectedSumberSaldo, style: const TextStyle(fontSize: 18, color: Colors.black87)),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  _showPilihSumberBottomSheet(context);
                                },
                                child: const Text("Ganti", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFF7F00))),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade400, width: 1.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Estimasi dana saat jatuh tempo", style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
                              const SizedBox(height: 4),
                              const Text("-", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                              const SizedBox(height: 12),
                              Text("Jangka waktu : ${widget.jangkaWaktuBulan} Bulan", style: const TextStyle(fontSize: 18, color: Colors.black)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Text(
                            "Hitungan simulasi sudah termasuk potongan pajak bunga.",
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                Container(
                  padding: const EdgeInsets.all(24.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        String cleanText = _amountController.text.replaceAll('.', '');
                        double inputAmount = double.tryParse(cleanText) ?? 0;

                        if (inputAmount >= 1000000) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DepositoKonfirmasiScreen(
                                jumlahPenempatan: inputAmount,
                                sukuBunga: widget.sukuBunga, 
                                jangkaWaktuBulan: widget.jangkaWaktuBulan, 
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Minimal penempatan Rp 1.000.000")),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF7F00),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text("Lanjut", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPilihSumberBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 16.0, bottom: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50, height: 5,
                  decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Sumber dana",
                style: TextStyle(fontFamily: 'AlumniSans', fontSize: 28, fontWeight: FontWeight.w800, color: Colors.black),
              ),
              const SizedBox(height: 20),

              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedSumber = "Saku Utama";
                    _selectedSumberSaldo = "Rp 3.000.000";
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8F0), 
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0x4D000000), width: 1.5), 
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50, height: 55,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD6E4FF),
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
                        ),
                        alignment: Alignment.center,
                        child: Image.asset('assets/images/IKEHome.png', height: 28, fit: BoxFit.contain, errorBuilder: (c, e, s) => const Icon(Icons.account_balance, color: Colors.blue)),
                      ),
                      const SizedBox(width: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Saku Utama", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                          SizedBox(height: 4),
                          Text("Rp 3.000.000", style: TextStyle(fontSize: 16, color: Colors.black)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 12),

              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedSumber = "Uang Belanja";
                    _selectedSumberSaldo = "Rp 5.000.000";
                  });
                  Navigator.pop(context);
                },
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8F0), 
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0x4D000000), width: 1.5), 
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50, height: 55,
                            decoration: const BoxDecoration(
                              color: Color(0xFFD6CFFF),
                              borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
                            ),
                            alignment: Alignment.center,
                            child: SvgPicture.asset('assets/images/bag.svg', height: 28, colorFilter: const ColorFilter.mode(Color(0xFFFF7F00), BlendMode.srcIn)),
                          ),
                          const SizedBox(width: 16),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Uang Belanja", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                              SizedBox(height: 4),
                              Text("Rp 5.000.000", style: TextStyle(fontSize: 16, color: Colors.black)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 0, right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF1A36DF), 
                          borderRadius: BorderRadius.only(topRight: Radius.circular(14), bottomLeft: Radius.circular(12)),
                        ),
                        child: const Text("Transaksi", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    
    String cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanText.isEmpty) return newValue.copyWith(text: '');
    
    int value = int.tryParse(cleanText) ?? 0;
    
    if (value > 100000000) {
      cleanText = '100000000';
    }
    
    String formatted = '';
    int count = 0;
    for (int i = cleanText.length - 1; i >= 0; i--) {
      if (count == 3) {
        formatted = '.$formatted';
        count = 0;
      }
      formatted = cleanText[i] + formatted;
      count++;
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length), 
    );
  }
}