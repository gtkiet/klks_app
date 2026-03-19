import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/network/api_response.dart';
import '../../../config/api_config.dart';

class AuthService {
  final SecureStorage _storage = SecureStorage();

  // ================= REGISTER =================
  Future<ApiResponse<void>> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String idCard,
    required String dob,
    required int gioiTinhId,
    required String address,
  }) async {
    return await ApiClient.post<void>(
      "/api/auth/register",
      body: {
        "username": username,
        "email": email,
        "password": password,
        "firstName": firstName,
        "lastName": lastName,
        "phoneNumber": phoneNumber,
        "idCard": idCard,
        "dob": dob,
        "gioiTinhId": gioiTinhId,
        "diaChi": address,
      },
    );
  }

  // ================= LOGIN =================
  Future<ApiResponse<void>> login({
    required String username,
    required String password,
  }) async {
    final res = await ApiClient.post<dynamic>(
      "/api/auth/login",
      body: {
        "username": username,
        "password": password,
      },
    );

    if (res.isOk && res.data != null) {
      final result = res.data;

      await _storage.saveTokens(
        accessToken: result["accessToken"],
        refreshToken: result["refreshToken"],
      );
    }

    return ApiResponse<void>(
      isOk: res.isOk,
      errors: res.errors,
    );
  }

  // ================= REFRESH TOKEN =================
  Future<bool> refreshAccessToken() async {
    final refreshToken = await _storage.getRefreshToken();

    if (refreshToken == null) return false;

    try {
      final url =
          Uri.parse("${ApiConfig.baseUrl}/api/auth/refresh-token");

      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"refreshToken": refreshToken}),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (data["isOk"] == true && data["result"] != null) {
        await _storage.saveTokens(
          accessToken: data["result"]["accessToken"],
          refreshToken: data["result"]["refreshToken"],
        );

        return true;
      }
    } catch (_) {}

    return false;
  }

  // ================= AUTO LOGIN =================
  Future<bool> tryAutoLogin() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null) return false;

    return await refreshAccessToken();
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    try {
      await ApiClient.post<void>("/api/auth/logout");
    } catch (_) {}

    await _storage.clearTokens();
  }

  // ================= FORGOT PASSWORD =================
  Future<ApiResponse<void>> forgotPassword({
    required String username,
  }) async {
    return await ApiClient.post<void>(
      "/api/auth/forgot-password",
      body: {"username": username},
    );
  }

  // ================= RESET PASSWORD =================
  Future<ApiResponse<void>> resetPassword({
    required String username,
    required String resetCode,
    required String newPassword,
    required String confirmPassword,
  }) async {
    return await ApiClient.post<void>(
      "/api/auth/reset-password",
      body: {
        "username": username,
        "resetCode": resetCode,
        "newPassword": newPassword,
        "confirmPassword": confirmPassword,
      },
    );
  }
}