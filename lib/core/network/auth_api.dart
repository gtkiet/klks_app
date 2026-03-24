/// core/network/auth_api.dart

import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../constants/api_constants.dart';
import '../constants/storage_keys.dart';

/// ─────────────────────────────────────────────────────────
/// AUTH API (SAFE - NO INTERCEPTOR)
/// ─────────────────────────────────────────────────────────
///
/// 🔥 QUAN TRỌNG:
/// - Dùng Dio RIÊNG (không interceptor)
/// - Tránh loop vô hạn khi refresh token
///
class AuthApi {
  AuthApi() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: AppConfig.timeout),
        receiveTimeout: const Duration(seconds: AppConfig.timeout),
        sendTimeout: const Duration(seconds: AppConfig.timeout),
        headers: {'Content-Type': ApiConstants.applicationJson},
      ),
    );
  }

  late final Dio _dio;

  /// ===================== LOGIN =====================
  Future<Response> login({required String username, required String password}) {
    return _dio.post(
      ApiConstants.login,
      data: {'username': username, 'password': password},
    );
  }

  /// ===================== REGISTER =====================
  Future<Response> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String idCard,
    required DateTime dob,
    required int gioiTinhId,
    required String diaChi,
  }) {
    return _dio.post(
      ApiConstants.register,
      data: {
        "username": username,
        "email": email,
        "password": password,
        "firstName": firstName,
        "lastName": lastName,
        "phoneNumber": phoneNumber,
        "idCard": idCard,
        "dob": dob.toIso8601String(),
        "gioiTinhId": gioiTinhId,
        "diaChi": diaChi,
      },
    );
  }

  /// ===================== REFRESH TOKEN =====================
  Future<Response> refreshToken({required String refreshToken}) {
    return _dio.post(
      ApiConstants.refreshToken,
      data: {StorageKeys.refreshToken: refreshToken},
    );
  }

  /// ===================== LOGOUT =====================
  Future<Response> logout() {
    return _dio.post(ApiConstants.logout);
  }

  /// ===================== PROFILE =====================
  Future<Response> getProfile() {
    return _dio.get(ApiConstants.getProfile);
  }

  /// ===================== FORGOT PASSWORD =====================
  Future<Response> forgotPassword({required String username}) {
    return _dio.post(ApiConstants.forgotPassword, data: {'username': username});
  }

  /// ===================== RESET PASSWORD =====================
  Future<Response> resetPassword({
    required String username,
    required String resetCode,
    required String newPassword,
    required String confirmPassword,
  }) {
    return _dio.post(
      ApiConstants.resetPassword,
      data: {
        'username': username,
        'resetCode': resetCode,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );
  }
}
