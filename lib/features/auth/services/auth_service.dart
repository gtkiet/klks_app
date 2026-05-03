// lib/features/auth/services/auth_service.dart
import 'dart:async';
import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/user_session.dart';
import '../../../core/errors/errors.dart';

import '../models/user_model.dart';

import '../../thong_bao/services/thong_bao_hub_service.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  Dio get _dio => ApiClient.instance.dio;
  final UserSession _session = UserSession();

  // ===================== LOGIN =====================
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    _validateLoginInput(username, password);
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {'username': username.trim(), 'password': password.trim()},
      );
      final user = UserModel.fromJson(response.data['result']);
      if (user.accessToken.isEmpty || user.refreshToken.isEmpty) {
        throw AppException('Token không hợp lệ');
      }
      await _session.saveTokens(
        accessToken: user.accessToken,
        refreshToken: user.refreshToken,
      );
      await _session.saveProfile(
        userId: user.userId.toString(),
        accountId: user.accountId.toString(),
        username: user.username,
        email: user.email,
        fullName: user.fullName,
        role: user.role,
        anhDaiDienUrl: user.anhDaiDienUrl,
      );
      unawaited(ThongBaoHubService.instance.connect());
      return user;
    } on DioException catch (e) {
      throw ErrorParser.parse(
        e.response?.data,
        statusCode: e.response?.statusCode,
      );
    } catch (_) {
      throw AppException('Lỗi không xác định');
    }
  }

  // ===================== REGISTER =====================
  Future<UserModel> register({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/register',
        data: {
          'email': email.trim(),
          'password': password.trim(),
          'confirmPassword': confirmPassword.trim(),
        },
      );
      final user = UserModel.fromJson(response.data['result']);
      await _session.saveTokens(
        accessToken: user.accessToken,
        refreshToken: user.refreshToken,
      );
      return user;
    } on DioException catch (e) {
      throw ErrorParser.parse(
        e.response?.data,
        statusCode: e.response?.statusCode,
      );
    } catch (_) {
      throw AppException('Lỗi không xác định');
    }
  }

  // ===================== LOGOUT =====================
  Future<void> logout() async {
    try {
      await ApiClient.instance.plainDio.post(
        '/api/auth/logout',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${await _session.getAccessToken() ?? ''}',
          },
        ),
      );
    } catch (_) {
      // ignore
    } finally {
      await _session.clearSession();
      await ThongBaoHubService.instance.disconnect();
    }
  }

  // ===================== FORGOT PASSWORD =====================
  Future<String> forgotPassword({required String username}) async {
    if (username.trim().isEmpty) throw AppException('Vui lòng nhập username');
    try {
      final response = await _dio.post(
        '/api/auth/forgot-password',
        data: {'username': username.trim()},
      );
      return response.data['result'] ?? '';
    } on DioException catch (e) {
      throw ErrorParser.parse(
        e.response?.data,
        statusCode: e.response?.statusCode,
      );
    } catch (_) {
      throw AppException('Lỗi không xác định');
    }
  }

  // ===================== RESET PASSWORD =====================
  Future<String> resetPassword({
    required String username,
    required String resetCode,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (newPassword.trim() != confirmPassword.trim()) {
      throw AppException('Mật khẩu không khớp');
    }
    try {
      final response = await _dio.post(
        '/api/auth/reset-password',
        data: {
          'username': username.trim(),
          'resetCode': resetCode.trim(),
          'newPassword': newPassword.trim(),
          'confirmPassword': confirmPassword.trim(),
        },
      );
      return response.data['result'] ?? '';
    } on DioException catch (e) {
      throw ErrorParser.parse(
        e.response?.data,
        statusCode: e.response?.statusCode,
      );
    } catch (_) {
      throw AppException('Lỗi không xác định');
    }
  }

  // ===================== REFRESH TOKEN =====================
  Future<String?> refreshToken({String? refreshToken}) async {
    try {
      final token = refreshToken ?? await _session.getRefreshToken();
      if (token == null || token.isEmpty) return null;

      final plainDio = ApiClient.instance.plainDio;

      final response = await plainDio.post(
        '/api/auth/refresh-token',
        data: {'refreshToken': token},
      );
      final data = response.data;
      if (data['isOk'] == true && data['result'] != null) {
        final newAccess = data['result']['accessToken'] as String?;
        final newRefresh = data['result']['refreshToken'] as String?;
        if (newAccess != null && newRefresh != null) {
          await _session.saveTokens(
            accessToken: newAccess,
            refreshToken: newRefresh,
          );
          return newAccess;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ===================== VALIDATION =====================
  void _validateLoginInput(String username, String password) {
    if (username.trim().isEmpty) throw AppException('Vui lòng nhập username');
    if (password.trim().isEmpty) throw AppException('Vui lòng nhập password');
  }
}
