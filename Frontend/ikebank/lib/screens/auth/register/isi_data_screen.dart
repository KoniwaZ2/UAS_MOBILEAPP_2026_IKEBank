import 'package:flutter/material.dart';
import '../../../core/colors.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../../models/register_flow_data.dart';
import '../login/verifikasi_wajah_screen.dart';
import '../../../utils/registration_rules.dart';

class IsiDataScreen extends StatefulWidget {
  final String phone;
  final String email;
  final File? ktpImageFile;
  final Map<String, dynamic> prefillIdentity;
  final String? reference;
  final ValueChanged<RegisterFlowData>? onContinue;

  const IsiDataScreen({
    super.key,
    required this.phone,
    required this.email,
    this.ktpImageFile,
    this.prefillIdentity = const <String, dynamic>{},
    this.reference,
    this.onContinue,
  });

  @override
  State<IsiDataScreen> createState() => _IsiDataScreenState();
}

class _IsiDataScreenState extends State<IsiDataScreen> {
  final TextStyle alumniSansBold = const TextStyle(
    fontWeight: FontWeight.w700,
    fontFamily: 'AlumniSans',
  );

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _ttlController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _ibuController = TextEditingController();

  String? _jenisKelamin;
  final List<String> _listKelamin = ['Laki-Laki', 'Perempuan'];

  String? _agama;
  final List<String> _listAgama = [
    'ISLAM',
    'CHRISTIANITY',
    'HINDUISM',
    'BUDDHISM',
    'OTHER',
  ];

  @override
  void initState() {
    super.initState();
    _applyPrefill();
  }

  void _applyPrefill() {
    final data = widget.prefillIdentity;

    _namaController.text = (data['name'] ?? '').toString();
    _nikController.text = (data['nik'] ?? '').toString();
    _alamatController.text = (data['address'] ?? '').toString();
    _ibuController.text = (data['mother_name'] ?? '').toString();

    final bornDate = (data['born_date'] ?? '').toString();
    if (bornDate.isNotEmpty) {
      _ttlController.text = bornDate;
    }

    final gender = (data['gender'] ?? '').toString().toLowerCase();
    if (gender.contains('male') || gender.contains('laki')) {
      _jenisKelamin = 'Laki-Laki';
    } else if (gender.contains('female') || gender.contains('perempuan')) {
      _jenisKelamin = 'Perempuan';
    }

    final religionRaw = (data['religion'] ?? '').toString().toUpperCase();
    if (_listAgama.contains(religionRaw)) {
      _agama = religionRaw;
    } else if (religionRaw == 'KRISTEN' ||
        religionRaw == 'KATHOLIK' ||
        religionRaw == 'KATOLIK') {
      _agama = 'CHRISTIANITY';
    } else if (religionRaw == 'HINDU') {
      _agama = 'HINDUISM';
    } else if (religionRaw == 'BUDDHA' || religionRaw == 'BUDHA') {
      _agama = 'BUDDHISM';
    } else if (religionRaw.isNotEmpty) {
      _agama = 'OTHER';
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nikController.dispose();
    _ttlController.dispose();
    _alamatController.dispose();
    _ibuController.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2007, 2, 26),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryOrange,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        String tanggalFormat = DateFormat('dd-MM-yyyy').format(picked);
        _ttlController.text = tanggalFormat;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryOrange,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                _buildProgressSegment(isActive: true),
                _buildProgressSegment(isActive: true),
                _buildProgressSegment(isActive: true),
                _buildProgressSegment(isActive: true),
                _buildProgressSegment(isActive: false),
                _buildProgressSegment(isActive: false),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16.0),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 32.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Isi Data Diri Kamu",
                          style: alumniSansBold.copyWith(
                            fontSize: 32,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 24),

                        _buildTextInput(
                          label: "Nama Sesuai KTP",
                          controller: _namaController,
                        ),
                        _buildTextInput(
                          label: "Nomor Induk KTP",
                          controller: _nikController,
                          isNumber: true,
                          maxLength: 16,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Bagian ini harus diisi';
                            }
                            if (value.length != 16) {
                              return 'NIK harus terdiri dari 16 digit';
                            }
                            return null;
                          },
                        ),

                        _buildTextInput(
                          label: "Tanggal Lahir",
                          controller: _ttlController,
                          readOnly: true,
                          onTap: () => _pilihTanggal(context),
                          suffixIcon: Icons.calendar_today,
                        ),

                        _buildDropdownInput(
                          label: "Jenis Kelamin",
                          value: _jenisKelamin,
                          items: _listKelamin,
                          onChanged: (newValue) {
                            setState(() {
                              _jenisKelamin = newValue;
                            });
                          },
                        ),

                        _buildTextInput(
                          label: "Alamat Sesuai KTP",
                          controller: _alamatController,
                        ),

                        _buildDropdownInput(
                          label: "Agama",
                          value: _agama,
                          items: _listAgama,
                          onChanged: (newValue) {
                            setState(() {
                              _agama = newValue;
                            });
                          },
                        ),

                        _buildTextInput(
                          label: "Nama Gadis Ibu Kandung",
                          controller: _ibuController,
                        ),

                        const SizedBox(height: 40),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryOrange,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: const StadiumBorder(),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                if (_jenisKelamin == null || _agama == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Pastikan Jenis Kelamin dan Agama sudah dipilih!',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                final flowData = RegisterFlowData(
                                  phoneNumber: widget.phone,
                                  email: widget.email,
                                  otpReference: widget.reference ?? '',
                                  ktpFile: widget.ktpImageFile,
                                  name: _namaController.text.trim(),
                                  nik: _nikController.text.trim(),
                                  bornPlace:
                                      (widget.prefillIdentity['born_place']
                                              ?.toString()
                                              .trim()
                                              .isNotEmpty ??
                                          false)
                                      ? widget.prefillIdentity['born_place']
                                            .toString()
                                            .trim()
                                      : '-',
                                  bornDate: toApiDate(
                                    _ttlController.text.trim(),
                                  ),
                                  gender: toApiGender(_jenisKelamin),
                                  address: _alamatController.text.trim(),
                                  religion: _agama!,
                                  motherName: _ibuController.text.trim(),
                                );

                                if (widget.onContinue != null) {
                                  widget.onContinue!(flowData);
                                  return;
                                }

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VerifikasiWajahScreen(
                                      isFromRegister: true,
                                      reference: widget.reference,
                                      flowData: flowData,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              "Lanjut",
                              style: alumniSansBold.copyWith(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextInput({
    required String label,
    required TextEditingController controller,
    bool isNumber = false,
    bool readOnly = false,
    VoidCallback? onTap,
    IconData? suffixIcon,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          TextFormField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            readOnly: readOnly,
            maxLength: maxLength,
            onTap: onTap,
            validator:
                validator ??
                (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bagian ini harus diisi';
                  }
                  return null;
                },
            style: const TextStyle(fontSize: 16, color: Colors.black),
            decoration: InputDecoration(
              isDense: true,
              counterText: "",
              contentPadding: const EdgeInsets.only(top: 4, bottom: 4),
              border: InputBorder.none,
              suffixIcon: suffixIcon != null
                  ? Icon(suffixIcon, color: Colors.grey.shade700)
                  : null,
              suffixIconConstraints: const BoxConstraints(
                minWidth: 24,
                minHeight: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownInput({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButtonFormField<String>(
              initialValue: value,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.grey.shade700,
              ),
              isExpanded: true,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
              ),
              items: items.map((String val) {
                return DropdownMenuItem<String>(
                  value: val,
                  child: Text(
                    val,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSegment({required bool isActive}) {
    return Expanded(
      child: Container(
        height: 6,
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: [Color(0xFF0000FF), Color(0xFF9999FF)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,

          color: isActive ? null : Colors.white.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
