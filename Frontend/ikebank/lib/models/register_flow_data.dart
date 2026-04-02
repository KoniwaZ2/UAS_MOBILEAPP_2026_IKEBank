import 'dart:io';

class RegisterFlowData {
  final String phoneNumber;
  final String email;
  final String otpReference;
  final File? ktpFile;
  final String? name;
  final String? nik;
  final String? bornPlace;
  final String? bornDate;
  final String? gender;
  final String? address;
  final String? religion;
  final String? motherName;
  final String? password;
  final String? pin;

  const RegisterFlowData({
    required this.phoneNumber,
    required this.email,
    required this.otpReference,
    this.ktpFile,
    this.name,
    this.nik,
    this.bornPlace,
    this.bornDate,
    this.gender,
    this.address,
    this.religion,
    this.motherName,
    this.password,
    this.pin,
  });

  RegisterFlowData copyWith({
    String? phoneNumber,
    String? email,
    String? otpReference,
    File? ktpFile,
    String? name,
    String? nik,
    String? bornPlace,
    String? bornDate,
    String? gender,
    String? address,
    String? religion,
    String? motherName,
    String? password,
    String? pin,
  }) {
    return RegisterFlowData(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      otpReference: otpReference ?? this.otpReference,
      ktpFile: ktpFile ?? this.ktpFile,
      name: name ?? this.name,
      nik: nik ?? this.nik,
      bornPlace: bornPlace ?? this.bornPlace,
      bornDate: bornDate ?? this.bornDate,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      religion: religion ?? this.religion,
      motherName: motherName ?? this.motherName,
      password: password ?? this.password,
      pin: pin ?? this.pin,
    );
  }
}
