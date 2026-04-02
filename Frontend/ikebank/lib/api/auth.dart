import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static String baseUrl = 'http://192.168.1.29:8000/api/auth';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static const String _accessTokenKey = 'auth_access_token';
  static const String _refreshTokenKey = 'auth_refresh_token';

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }

  static Future<String?> getAccessToken() async {
    return _secureStorage.read(key: _accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    return _secureStorage.read(key: _refreshTokenKey);
  }

  static Future<bool> hasAccessToken() async {
    final accessToken = await getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }

  static Future<void> clearTokens() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  static Future<Map<String, String>> buildAuthHeaders({
    bool includeJsonContentType = true,
  }) async {
    final headers = <String, String>{
      if (includeJsonContentType) 'Content-Type': 'application/json',
    };

    final accessToken = await getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    return headers;
  }

  static Map<String, String>? _extractTokens(Map<String, dynamic> decoded) {
    String? access;
    String? refresh;

    final nestedToken = decoded['token'];
    if (nestedToken is Map<String, dynamic>) {
      access = nestedToken['access']?.toString();
      refresh = nestedToken['refresh']?.toString();
    }

    access ??= decoded['access']?.toString();
    refresh ??= decoded['refresh']?.toString();
    access ??= decoded['access_token']?.toString();
    refresh ??= decoded['refresh_token']?.toString();

    if (access == null ||
        access.isEmpty ||
        refresh == null ||
        refresh.isEmpty) {
      return null;
    }

    return <String, String>{'access': access, 'refresh': refresh};
  }

  static Future<Map<String, dynamic>> check({
    required String phone,
    required String email,
  }) async {
    final url = Uri.parse("$baseUrl/check/");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone_number': phone, 'email': email}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(_extractErrorMessage(response, 'Failed to check data'));
    }
  }

  static Future<Map<String, dynamic>> otpRequest({
    required String email,
    required String purpose,
  }) async {
    final url = Uri.parse("$baseUrl/otp/request/");
    final String normalizedPurpose = purpose.toLowerCase() == 'registration'
        ? 'registration'
        : purpose.toLowerCase() == 'login'
        ? 'login'
        : purpose;
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'purpose': normalizedPurpose}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(_extractErrorMessage(response, 'Failed to request OTP'));
    }
  }

  static Future<Map<String, dynamic>> otpVerify({
    required String reference,
    required String otpcode,
    required String purpose,
  }) async {
    final url = Uri.parse("$baseUrl/otp/verify/");

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'reference': reference,
        'otp_code': otpcode,
        'purpose': purpose,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(_extractErrorMessage(response, 'Failed to verify OTP'));
    }
  }

  static String _extractErrorMessage(http.Response response, String fallback) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final detail = decoded['detail']?.toString();
        if (detail != null && detail.isNotEmpty) {
          return detail;
        }

        for (final entry in decoded.entries) {
          final value = entry.value;
          if (value is List && value.isNotEmpty) {
            return value.first.toString();
          }
          if (value is String && value.isNotEmpty) {
            return value;
          }
        }
      }
    } catch (_) {
      // Ignore JSON parse failures and return fallback below.
    }

    return '$fallback (HTTP ${response.statusCode})';
  }

  static String _extractErrorFromDynamic(dynamic decoded, String fallback) {
    if (decoded is Map<String, dynamic>) {
      final detail = decoded['detail']?.toString();
      if (detail != null && detail.isNotEmpty) {
        return detail;
      }

      for (final entry in decoded.entries) {
        final value = entry.value;
        if (value is List && value.isNotEmpty) {
          return value.first.toString();
        }
        if (value is String && value.isNotEmpty) {
          return value;
        }
      }
    }
    return fallback;
  }

  static Future<Map<String, dynamic>> uploadKTP({
    required File imageFile,
    required String reference,
  }) async {
    final url = Uri.parse("$baseUrl/ktp/upload/");
    var request = http.MultipartRequest('POST', url);
    request.fields['reference'] = reference;
    request.fields['purpose'] = 'registration';
    request.files.add(await http.MultipartFile.fromPath('ktp', imageFile.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      return jsonDecode(responseBody);
    } else {
      final respStr = await response.stream.bytesToString();
      throw Exception("Upload gagal: $respStr");
    }
  }

  static Future<void> uploadFaceImage(
    File imageFile, {
    String? reference,
    String purpose = 'registration',
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/upload-face/'),
    );

    request.fields['purpose'] = purpose;
    if (reference != null && reference.isNotEmpty) {
      request.fields['reference'] = reference;
    }

    request.files.add(
      await http.MultipartFile.fromPath('face', imageFile.path),
    );

    var response = await request.send();

    if (response.statusCode != 200) {
      final respStr = await response.stream.bytesToString();
      throw Exception("Upload gagal: $respStr");
    }
  }

  static Future<Map<String, dynamic>> register({
    required String otpReference,
    required String phoneNumber,
    required String email,
    required String password,
    required String name,
    required String nik,
    required String bornPlace,
    required String bornDate,
    required String gender,
    required String address,
    required String religion,
    required String motherName,
    required String pin,
    required File ktpFile,
  }) async {
    final url = Uri.parse('$baseUrl/register/');
    final request = http.MultipartRequest('POST', url);

    request.fields['otp_reference'] = otpReference;
    request.fields['purpose'] = 'registration';
    request.fields['phone_number'] = phoneNumber;
    request.fields['email'] = email;
    request.fields['password'] = password;
    request.fields['password_confirmation'] = password;
    request.fields['name'] = name;
    request.fields['nik'] = nik;
    request.fields['born_place'] = bornPlace;
    request.fields['born_date'] = bornDate;
    request.fields['gender'] = gender;
    request.fields['address'] = address;
    request.fields['religion'] = religion;
    request.fields['mother_name'] = motherName;
    request.fields['pin'] = pin;
    request.fields['pin_confirmation'] = pin;
    request.files.add(await http.MultipartFile.fromPath('ktp', ktpFile.path));

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode == 201 || response.statusCode == 200) {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return <String, dynamic>{'message': 'Register success'};
    }

    String message = 'Register gagal (HTTP ${response.statusCode})';
    try {
      final decoded = jsonDecode(body);
      message = _extractErrorFromDynamic(decoded, message);
    } catch (_) {
      // If parsing fails, keep fallback message.
    }

    throw Exception(message);
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/login/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Invalid login response format');
      }

      final tokens = _extractTokens(decoded);
      if (tokens != null) {
        await saveTokens(
          accessToken: tokens['access']!,
          refreshToken: tokens['refresh']!,
        );
      }

      return decoded;
    } else {
      throw Exception(_extractErrorMessage(response, 'Login failed'));
    }
  }

  static Future<Map<String, dynamic>> checkLogin({
    required String email,
  }) async {
    final url = Uri.parse("$baseUrl/login-check/");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(_extractErrorMessage(response, 'Failed to check data'));
    }
  }

  static Future<void> checkFaceLogin(
    File imageFile, {
    String? reference,
    String purpose = 'login',
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/face/login/'),
    );

    request.fields['purpose'] = purpose;
    if (reference != null && reference.isNotEmpty) {
      request.fields['reference'] = reference;
    }

    request.files.add(
      await http.MultipartFile.fromPath('face', imageFile.path),
    );

    var response = await request.send();

    if (response.statusCode != 200) {
      final respStr = await response.stream.bytesToString();
      throw Exception("Upload gagal: $respStr");
    }
  }

  static Future<void> forgotPassword({
    required String email,
    required String otpReference,
    required String password,
    required String passwordConfirmation,
  }) async {
    final url = Uri.parse('$baseUrl/forgot-password/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'otp_reference': otpReference,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(_extractErrorMessage(response, 'Failed to check data'));
    }
  }
}
