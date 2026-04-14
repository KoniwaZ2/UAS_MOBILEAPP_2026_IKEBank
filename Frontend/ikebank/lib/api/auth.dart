import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://10.10.161.245:8000/api/auth';
  // static const String baseUrl = 'http://192.168.1.12:8000/api/auth';

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static const String _accessTokenKey = 'auth_access_token';
  static const String _refreshTokenKey = 'auth_refresh_token';
  static const String _lastEmailKey = 'auth_last_email';
  static const Duration _refreshBuffer = Duration(minutes: 2);
  static const Duration _activityRefreshThrottle = Duration(minutes: 3);
  static DateTime? _lastActivityRefreshAttempt;
  static Completer<bool>? _refreshCompleter;

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }

  static Future<void> saveLastEmail(String email) async {
    final normalizedEmail = email.trim();
    if (normalizedEmail.isEmpty) {
      return;
    }

    await _secureStorage.write(key: _lastEmailKey, value: normalizedEmail);
  }

  static Future<String?> getLastEmail() async {
    final value = await _secureStorage.read(key: _lastEmailKey);
    final normalized = value?.trim() ?? '';
    return normalized.isEmpty ? null : normalized;
  }

  static Future<String?> getAccessToken() async {
    return _secureStorage.read(key: _accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    return _secureStorage.read(key: _refreshTokenKey);
  }

  static Future<void> onUserActivity() async {
    final now = DateTime.now();
    if (_lastActivityRefreshAttempt != null) {
      final elapsed = now.difference(_lastActivityRefreshAttempt!);
      if (elapsed < _activityRefreshThrottle) {
        return;
      }
    }

    _lastActivityRefreshAttempt = now;
    await _refreshAccessTokenIfNeeded();
  }

  static Future<bool> hasAccessToken() async {
    final accessToken = await getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }

  static Future<bool> hasValidAccessToken() async {
    final accessToken = await getAccessToken();
    if (accessToken == null || accessToken.isEmpty) return false;
    // Anggap token expired jika akan expired dalam 2 menit ke depan
    if (_isTokenExpiringSoon(accessToken, const Duration(minutes: 2)))
      return false;
    return true;
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

  static Future<http.Response> authorizedGet(
    Uri url, {
    Map<String, String>? headers,
  }) async {
    await _refreshAccessTokenIfNeeded();

    final authHeaders = await buildAuthHeaders(includeJsonContentType: false);
    final mergedHeaders = <String, String>{...authHeaders, ...?headers};
    var response = await http.get(url, headers: mergedHeaders);

    if (response.statusCode == 401) {
      final refreshed = await _refreshAccessTokenIfNeeded(force: true);
      if (refreshed) {
        final retryHeaders = await buildAuthHeaders(
          includeJsonContentType: false,
        );
        response = await http.get(
          url,
          headers: <String, String>{...retryHeaders, ...?headers},
        );
      }
    }

    return response;
  }

  static Future<http.Response> authorizedPost(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    await _refreshAccessTokenIfNeeded();

    final authHeaders = await buildAuthHeaders(includeJsonContentType: true);
    final mergedHeaders = <String, String>{...authHeaders, ...?headers};
    var response = await http.post(url, headers: mergedHeaders, body: body);

    if (response.statusCode == 401) {
      final refreshed = await _refreshAccessTokenIfNeeded(force: true);
      if (refreshed) {
        final retryHeaders = await buildAuthHeaders(
          includeJsonContentType: true,
        );
        response = await http.post(
          url,
          headers: <String, String>{...retryHeaders, ...?headers},
          body: body,
        );
      }
    }

    return response;
  }

  static Future<http.Response> authorizedPatch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    await _refreshAccessTokenIfNeeded();

    final authHeaders = await buildAuthHeaders(includeJsonContentType: true);
    final mergedHeaders = <String, String>{...authHeaders, ...?headers};
    var response = await http.patch(url, headers: mergedHeaders, body: body);

    if (response.statusCode == 401) {
      final refreshed = await _refreshAccessTokenIfNeeded(force: true);
      if (refreshed) {
        final retryHeaders = await buildAuthHeaders(
          includeJsonContentType: true,
        );
        response = await http.patch(
          url,
          headers: <String, String>{...retryHeaders, ...?headers},
          body: body,
        );
      }
    }

    return response;
  }

  static Future<bool> _refreshAccessTokenIfNeeded({bool force = false}) async {
    final accessToken = await getAccessToken();
    final needsRefresh =
        force ||
        accessToken == null ||
        accessToken.isEmpty ||
        _isTokenExpiringSoon(accessToken, _refreshBuffer);

    if (!needsRefresh) {
      return true;
    }

    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<bool>();
    try {
      final refreshed = await _performRefresh();
      _refreshCompleter!.complete(refreshed);
      return refreshed;
    } catch (_) {
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }

  static Future<bool> _performRefresh() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    final endpoints = <String>['$baseUrl/token/refresh/', '$baseUrl/refresh/'];

    for (final endpoint in endpoints) {
      try {
        final response = await http.post(
          Uri.parse(endpoint),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'refresh': refreshToken,
            'refresh_token': refreshToken,
          }),
        );

        if (response.statusCode != 200) {
          continue;
        }

        final decoded = jsonDecode(response.body);
        if (decoded is! Map<String, dynamic>) {
          continue;
        }

        final tokens = _extractTokens(decoded);
        if (tokens != null) {
          await saveTokens(
            accessToken: tokens['access']!,
            refreshToken: tokens['refresh']!,
          );
          return true;
        }

        final accessOnly = _extractAccessToken(decoded);
        if (accessOnly != null && accessOnly.isNotEmpty) {
          await _secureStorage.write(key: _accessTokenKey, value: accessOnly);
          return true;
        }
      } catch (_) {
        // Try next endpoint candidate.
      }
    }

    return false;
  }

  static String? _extractAccessToken(Map<String, dynamic> decoded) {
    final nestedToken = decoded['token'];
    if (nestedToken is Map<String, dynamic>) {
      final access = nestedToken['access']?.toString();
      if (access != null && access.isNotEmpty) {
        return access;
      }
    }

    final direct =
        decoded['access']?.toString() ?? decoded['access_token']?.toString();
    if (direct == null || direct.isEmpty) {
      return null;
    }
    return direct;
  }

  static bool _isTokenExpiringSoon(String token, Duration buffer) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return true;
      }
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) {
        return true;
      }
      final expValue = decoded['exp'];
      final expSeconds = expValue is int
          ? expValue
          : int.tryParse(expValue?.toString() ?? '');
      if (expSeconds == null) {
        return true;
      }
      final expiresAt = DateTime.fromMillisecondsSinceEpoch(
        expSeconds * 1000,
        isUtc: true,
      );
      final nowUtc = DateTime.now().toUtc();
      return nowUtc.add(buffer).isAfter(expiresAt);
    } catch (_) {
      return true;
    }
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

      await saveLastEmail(email);

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

  static Future<void> logout() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await clearTokens();
      return;
    }

    try {
      await authorizedPost(
        Uri.parse('$baseUrl/logout/'),
        body: jsonEncode({'refresh': refreshToken}),
      );
    } catch (_) {
      // Ignore API logout failure and continue to local token cleanup.
    }

    await clearTokens();
  }

  static Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    final url = Uri.parse('$baseUrl/change-password/');
    final response = await authorizedPost(
      url,
      body: jsonEncode({
        'old_password': oldPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPasswordConfirmation,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        _extractErrorMessage(response, 'Failed to change password'),
      );
    }
  }

  static Future<void> changePIN({
    required String oldPin,
    required String newPin,
    required String newPinConfirmation,
  }) async {
    final url = Uri.parse('$baseUrl/change-pin/');
    final response = await authorizedPost(
      url,
      body: jsonEncode({
        'old_pin': oldPin,
        'new_pin': newPin,
        'new_pin_confirmation': newPinConfirmation,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(_extractErrorMessage(response, 'Failed to change PIN'));
    }
  }

  static Future<Map<String, dynamic>> getProfile() async {
    final url = Uri.parse('$baseUrl/user-details/');
    final response = await authorizedGet(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        _extractErrorMessage(response, 'Failed to fetch profile'),
      );
    }
  }
}
