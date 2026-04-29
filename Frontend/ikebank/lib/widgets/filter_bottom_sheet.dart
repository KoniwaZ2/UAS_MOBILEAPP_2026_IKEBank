import 'package:flutter/material.dart';

enum FilterPeriode { all, last7Days, last30Days, customDate }

enum FilterJenisTransaksi { all, danaMasuk, danaKeluar }

class TransactionFilter {
  final FilterPeriode periode;
  final FilterJenisTransaksi jenis;
  final DateTime? tanggalDari;
  final DateTime? tanggalSampai;

  const TransactionFilter({
    required this.periode,
    required this.jenis,
    this.tanggalDari,
    this.tanggalSampai,
  });

  const TransactionFilter.initial()
    : periode = FilterPeriode.last7Days,
      jenis = FilterJenisTransaksi.danaMasuk,
      tanggalDari = null,
      tanggalSampai = null;

  const TransactionFilter.noFilter()
    : periode = FilterPeriode.all,
      jenis = FilterJenisTransaksi.all,
      tanggalDari = null,
      tanggalSampai = null;
}

Future<TransactionFilter?> showFilterBottomSheet(
  BuildContext context, {
  TransactionFilter? initialFilter,
}) {
  final current = initialFilter ?? const TransactionFilter.initial();

  return showModalBottomSheet<TransactionFilter>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      FilterPeriode selectedPeriode = current.periode;
      FilterJenisTransaksi selectedJenis = current.jenis;
      DateTime? tanggalDari = current.tanggalDari;
      DateTime? tanggalSampai = current.tanggalSampai;

      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          Future<void> pickDate(bool isStart) async {
            final initial = isStart
                ? (tanggalDari ?? DateTime.now())
                : (tanggalSampai ?? tanggalDari ?? DateTime.now());

            final picked = await showDatePicker(
              context: context,
              initialDate: initial,
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
            );

            if (picked == null) {
              return;
            }

            setState(() {
              if (isStart) {
                tanggalDari = picked;
                if (tanggalSampai != null && picked.isAfter(tanggalSampai!)) {
                  tanggalSampai = picked;
                }
              } else {
                tanggalSampai = picked;
                if (tanggalDari != null && picked.isBefore(tanggalDari!)) {
                  tanggalDari = picked;
                }
              }
            });
          }

          return Padding(
            padding: EdgeInsets.only(
              left: 24.0,
              right: 24.0,
              top: 16.0,
              bottom: MediaQuery.of(context).padding.bottom + 24.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  "Filter transaksi",
                  style: TextStyle(
                    fontFamily: 'AlumniSans',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  "Periode",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),

                _buildRadioOption<FilterPeriode>(
                  "Semua",
                  FilterPeriode.all,
                  selectedPeriode,
                  (val) => setState(() => selectedPeriode = val),
                ),
                _buildRadioOption<FilterPeriode>(
                  "7 hari terakhir",
                  FilterPeriode.last7Days,
                  selectedPeriode,
                  (val) => setState(() => selectedPeriode = val),
                ),
                _buildRadioOption<FilterPeriode>(
                  "30 hari terakhir",
                  FilterPeriode.last30Days,
                  selectedPeriode,
                  (val) => setState(() => selectedPeriode = val),
                ),
                _buildRadioOption<FilterPeriode>(
                  "Pilih tanggal",
                  FilterPeriode.customDate,
                  selectedPeriode,
                  (val) => setState(() => selectedPeriode = val),
                ),

                if (selectedPeriode == FilterPeriode.customDate) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDatePickerBox(
                          title: "Dari",
                          selectedValue: tanggalDari,
                          onTap: () => pickDate(true),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDatePickerBox(
                          title: "Sampai",
                          selectedValue: tanggalSampai,
                          onTap: () => pickDate(false),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),

                const Text(
                  "Jenis transaksi",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),

                _buildRadioOption<FilterJenisTransaksi>(
                  "Semua jenis",
                  FilterJenisTransaksi.all,
                  selectedJenis,
                  (val) => setState(() => selectedJenis = val),
                ),
                _buildRadioOption<FilterJenisTransaksi>(
                  "Dana masuk",
                  FilterJenisTransaksi.danaMasuk,
                  selectedJenis,
                  (val) => setState(() => selectedJenis = val),
                ),
                _buildRadioOption<FilterJenisTransaksi>(
                  "Dana keluar",
                  FilterJenisTransaksi.danaKeluar,
                  selectedJenis,
                  (val) => setState(() => selectedJenis = val),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (selectedPeriode == FilterPeriode.customDate &&
                          (tanggalDari == null || tanggalSampai == null)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pilih tanggal dari dan sampai'),
                          ),
                        );
                        return;
                      }

                      Navigator.pop(
                        context,
                        TransactionFilter(
                          periode: selectedPeriode,
                          jenis: selectedJenis,
                          tanggalDari:
                              selectedPeriode == FilterPeriode.customDate
                              ? tanggalDari
                              : null,
                          tanggalSampai:
                              selectedPeriode == FilterPeriode.customDate
                              ? tanggalSampai
                              : null,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7F00),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Lihat Hasil",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget _buildRadioOption<T>(
  String title,
  T optionValue,
  T selectedValue,
  ValueChanged<T> onChanged,
) {
  return InkWell(
    onTap: () => onChanged(optionValue),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(
            selectedValue == optionValue
                ? Icons.radio_button_checked
                : Icons.radio_button_off,
            color: selectedValue == optionValue
                ? const Color(0xFFFF7F00)
                : Colors.grey.shade400,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    ),
  );
}

Widget _buildDatePickerBox({
  required String title,
  required DateTime? selectedValue,
  required VoidCallback onTap,
}) {
  String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFDBB7), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF7F00),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  selectedValue == null ? 'Pilih' : formatDate(selectedValue),
                  style: TextStyle(
                    fontSize: 14,
                    color: selectedValue == null
                        ? Colors.grey.shade400
                        : Colors.black87,
                  ),
                ),
              ),
              const Icon(
                Icons.calendar_today,
                color: Color(0xFFFF7F00),
                size: 16,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
