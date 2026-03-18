import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../config/api_config.dart';

class AuthService {
  final SecureStorage _storage = SecureStorage();

  // ================= REGISTER =================
  Future<Map<String, dynamic>> register({
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
    try {
      return await ApiClient.post(
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
    } catch (e) {
      return _error("Lỗi kết nối");
    }
  }

  // ================= LOGIN =================
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final data = await ApiClient.post(
        "/api/auth/login",
        body: {
          "username": username,
          "password": password,
        },
      );

      if (data["isOk"] == true && data["result"] != null) {
        await _storage.saveTokens(
          accessToken: data["result"]["accessToken"],
          refreshToken: data["result"]["refreshToken"],
        );
      }

      return data;
    } catch (e) {
      return _error("Lỗi kết nối");
    }
  }

  // ================= REFRESH TOKEN (FIXED) =================
  Future<bool> refreshAccessToken() async {
    final refreshToken = await _storage.getRefreshToken();

    if (refreshToken == null) return false;

    try {
      final url =
          Uri.parse("${ApiConfig.baseUrl}/api/auth/refresh-token");

      /// 🔥 KHÔNG dùng ApiClient ở đây
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
    } catch (e) {
      // có thể log debug nếu cần
    }

    return false;
  }

  // ================= AUTO LOGIN (SIMPLIFIED) =================
  Future<bool> tryAutoLogin() async {
    final refreshToken = await _storage.getRefreshToken();

    if (refreshToken == null) return false;

    return await refreshAccessToken();
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    try {
      await ApiClient.post("/api/auth/logout", body: {});
    } catch (_) {}

    await _storage.clearTokens();
  }

  // ================= FORGOT PASSWORD =================
  Future<Map<String, dynamic>> forgotPassword({
    required String username,
  }) async {
    try {
      return await ApiClient.post(
        "/api/auth/forgot-password",
        body: {"username": username},
      );
    } catch (e) {
      return _error("Lỗi kết nối");
    }
  }

  // ================= RESET PASSWORD =================
  Future<Map<String, dynamic>> resetPassword({
    required String username,
    required String resetCode,
    required String newPassword,
  }) async {
    try {
      return await ApiClient.post(
        "/api/auth/reset-password",
        body: {
          "username": username,
          "resetCode": resetCode,
          "newPassword": newPassword,
        },
      );
    } catch (e) {
      return _error("Lỗi kết nối");
    }
  }

  // ================= HELPER =================
  Map<String, dynamic> _error(String message) {
    return {
      "isOk": false,
      "errors": [
        {"description": message}
      ]
    };
  }
}