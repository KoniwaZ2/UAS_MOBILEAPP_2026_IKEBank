import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';

class TambahDanaNabungAiScreen extends StatefulWidget {
  const TambahDanaNabungAiScreen({super.key});

  @override
  State<TambahDanaNabungAiScreen> createState() => _TambahDanaNabungAiScreenState();
}

class _TambahDanaNabungAiScreenState extends State<TambahDanaNabungAiScreen> {
  final TextEditingController _amountController = TextEditingController(text: "");
  
  String _selectedSumber = "Saku Utama";
  String _selectedSumberSaldo = "Rp 3.000.000";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Tambah Dana",
          style: TextStyle(
            fontFamily: 'AlumniSans',
            fontWeight: FontWeight.w800,
            fontSize: 28,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      clipBehavior: Clip.antiAlias, 
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Tambahkan ke", style: TextStyle(fontSize: 14, color: Colors.black87)),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Container(
                                      width: 45, height: 50,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFD6CFFF),
                                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
                                      ),
                                      alignment: Alignment.center,
                                      child: Image.asset('assets/images/celengan.png', height: 28, fit: BoxFit.contain),
                                    ),
                                    const SizedBox(width: 12),
                                    const Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Saku Celengan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                                        SizedBox(height: 2),
                                        Text("Rp 8.000.000", style: TextStyle(fontSize: 14, color: Colors.black87)),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          Divider(height: 0.1, color: Colors.grey.shade200),
                          
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16.0),
                            decoration: const BoxDecoration(
                              color: Color(0x1AFFCA96), 
                              borderRadius: BorderRadius.all(Radius.circular(16)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Jumlah", style: TextStyle(fontSize: 14, color: Colors.black)),
                                Row(
                                  children: [
                                    Text(
                                      "Rp ",
                                      style: TextStyle(
                                        fontFamily: 'AlumniSans', 
                                        fontSize: 32, 
                                        fontWeight: FontWeight.w900, 
                                        color: _amountController.text.isEmpty ? Colors.grey.shade400 : const Color(0xFFFF7F00)
                                      ),
                                    ),
                                    Expanded(
                                      child: TextField(
                                        controller: _amountController,
                                        keyboardType: TextInputType.number,
                                        style: const TextStyle(fontFamily: 'AlumniSans', fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFFFF7F00)),
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                          hintText: "500.000",
                                          hintStyle: TextStyle(
                                            fontFamily: 'AlumniSans', 
                                            fontSize: 32, 
                                            fontWeight: FontWeight.w900, 
                                            color: Colors.grey.shade400
                                          )
                                        ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly, 
                                          _CurrencyInputFormatter(maxAmount: 500000), // Maksimal 500.000
                                        ],
                                        onChanged: (value) {
                                          setState(() {}); 
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                        child: Text(
                          "*Minimal Rp 1, Maksimal Rp 500.000",
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Dari", style: TextStyle(fontSize: 12, color: Colors.black87)),
                              const SizedBox(height: 4),
                              Text(_selectedSumber, style: const TextStyle(fontSize: 16, color: Colors.black)),
                              const SizedBox(height: 2),
                              Text(_selectedSumberSaldo, style: const TextStyle(fontSize: 14, color: Colors.black)),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              _showPilihSumberBottomSheet(context);
                            },
                            child: const Text("Ganti", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFFF7F00))),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: const BoxDecoration(color: Colors.transparent),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, true); 
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Dana berhasil ditambahkan ke Saku Celengan!")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7F00),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Tambah Dana", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text(
                        "Rp ${_amountController.text.isEmpty ? '0' : _amountController.text}", 
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
                      ),
                    ],
                  ),
                ),
              ),
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
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Pilih sumber dana",
                style: TextStyle(fontFamily: 'AlumniSans', fontSize: 26, fontWeight: FontWeight.w800, color: Colors.black),
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
                    border: Border.all(color: const Color(0xFFFFDBB7), width: 1.5), 
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
                          Text("Saku Utama", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                          SizedBox(height: 4),
                          Text("Rp 3.000.000", style: TextStyle(fontSize: 14, color: Colors.black87)),
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
                        border: Border.all(color: const Color(0xFFFFDBB7), width: 1.5), 
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
                            child: SvgPicture.asset('assets/images/bag.svg', height: 24, colorFilter: const ColorFilter.mode(Color(0xFFFF7F00), BlendMode.srcIn)),
                          ),
                          const SizedBox(width: 16),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Uang Belanja", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                              SizedBox(height: 4),
                              Text("Rp 5.000.000", style: TextStyle(fontSize: 14, color: Colors.black87)),
                            ],
                          ),
                        ],
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
  final int maxAmount;
  _CurrencyInputFormatter({required this.maxAmount});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    String cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanText.isEmpty) return newValue.copyWith(text: '');
    int value = int.parse(cleanText);
    if (value > maxAmount) { value = maxAmount; cleanText = maxAmount.toString(); }
    String formatted = '';
    int count = 0;
    for (int i = cleanText.length - 1; i >= 0; i--) {
      if (count == 3) { formatted = '.$formatted'; count = 0; }
      formatted = cleanText[i] + formatted;
      count++;
    }
    return TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }
}