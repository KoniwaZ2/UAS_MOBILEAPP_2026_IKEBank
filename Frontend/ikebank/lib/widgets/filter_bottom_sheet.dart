import 'package:flutter/material.dart';

void showFilterBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, 
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      String selectedPeriode = '7 hari terakhir'; 
      String selectedJenis = 'Dana masuk'; 
      
      String? tanggalDari; 
      String? tanggalSampai; 

      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 24.0, right: 24.0, top: 16.0,
              bottom: MediaQuery.of(context).padding.bottom + 24.0 
            ),
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
                
                const Text("Filter transaksi", style: TextStyle(fontFamily: 'AlumniSans', fontSize: 28, fontWeight: FontWeight.w800, color: Colors.black)),
                const SizedBox(height: 24),

                const Text("Periode", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(height: 8),
                
                _buildRadioOption("7 hari terakhir", selectedPeriode, (val) => setState(() => selectedPeriode = val)),
                _buildRadioOption("30 hari terakhir", selectedPeriode, (val) => setState(() => selectedPeriode = val)),
                _buildRadioOption("Pilih tanggal", selectedPeriode, (val) => setState(() => selectedPeriode = val)),

                if (selectedPeriode == "Pilih tanggal") ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDatePickerBox("Dari", tanggalDari, (val) {
                          setState(() { tanggalDari = val; });
                        })
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDatePickerBox("Sampai", tanggalSampai, (val) {
                          setState(() { tanggalSampai = val; });
                        })
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                
                const Text("Jenis transaksi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(height: 8),

                _buildRadioOption("Dana masuk", selectedJenis, (val) => setState(() => selectedJenis = val)),
                _buildRadioOption("Dana keluar", selectedJenis, (val) => setState(() => selectedJenis = val)),

                const SizedBox(height: 32),
                
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); 
                    }, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7F00),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text("Lihat Hasil", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                )
              ],
            ),
          );
        }
      );
    },
  );
}


Widget _buildRadioOption(String title, String groupValue, ValueChanged<String> onChanged) {
  return InkWell(
    onTap: () => onChanged(title),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(
            groupValue == title ? Icons.radio_button_checked : Icons.radio_button_off,
            color: groupValue == title ? const Color(0xFFFF7F00) : Colors.grey.shade400,
          ),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontSize: 16, color: Colors.black87)),
        ],
      ),
    ),
  );
}

Widget _buildDatePickerBox(String title, String? selectedValue, Function(String?) onChanged) {
    List<String> days = List.generate(31, (index) => (index + 1).toString());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F0), 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFDBB7), width: 1.5), 
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFFF7F00))),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              isDense: true,
              value: selectedValue,
              hint: Text("Pilih", style: TextStyle(fontSize: 14, color: Colors.grey.shade400)),
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFFFF7F00), size: 18),
              items: days.map((String day) {
                return DropdownMenuItem<String>(
                  value: day,
                  child: Text(day, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

