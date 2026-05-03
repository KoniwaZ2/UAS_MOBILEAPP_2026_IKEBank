import '../models/register_flow_data.dart';

String? validatePinEntry(String pin, String confirmPin) {
  if (pin.length < 6 || confirmPin.length < 6) {
    return 'PIN harus terdiri dari 6 digit angka!';
  }
  if (pin != confirmPin) {
    return 'Konfirmasi PIN tidak cocok!';
  }
  return null;
}

String? validateRegistrationFlowData(RegisterFlowData? flowData) {
  if (flowData == null ||
      flowData.ktpFile == null ||
      (flowData.password ?? '').isEmpty ||
      (flowData.otpReference).isEmpty) {
    return 'Data registrasi belum lengkap. Ulangi dari awal.';
  }
  return null;
}
