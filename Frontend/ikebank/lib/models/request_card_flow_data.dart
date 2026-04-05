import 'dart:io';

class RequestCardFlowData {
  final String phoneNumber;
  final String email;
  final String otpReference;
  final File? ktpFile;

  const RequestCardFlowData({
    required this.phoneNumber,
    required this.email,
    required this.otpReference,
    this.ktpFile,
  });

  RequestCardFlowData copyWith({
    String? phoneNumber,
    String? email,
    String? otpReference,
    File? ktpFile,
  }) {
    return RequestCardFlowData(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      otpReference: otpReference ?? this.otpReference,
      ktpFile: ktpFile ?? this.ktpFile,
    );
  }
}
