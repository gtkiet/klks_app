// lib/features/auth/services/auth_service.dart
import 'package:dio/dio.dart';
import '../../../core/config/app_config.dart';
import '../../../core/storage/user_session.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_parser.dart';
import '../models/user_model.dart';

class AuthService {
  AuthService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  late final Dio _dio;
  final UserSession _session = UserSession();

  /// ===================== LOGIN =====================
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

      final data = response.data;
      final user = UserModel.fromJson(data['result']);

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

  /// ===================== REGISTER =====================
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

      final data = response.data;
      final user = UserModel.fromJson(data['result']);
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

  /// ===================== LOGOUT =====================
  Future<void> logout() async {
    try {
      await _dio.post('/api/auth/logout');
    } catch (_) {
      // ignore server error
    } finally {
      await _session.clearSession();
    }
  }

  /// ===================== FORGOT PASSWORD =====================
  Future<String> forgotPassword({required String username}) async {
    if (username.trim().isEmpty) throw AppException('Vui lòng nhập username');

    try {
      final response = await _dio.post(
        '/api/auth/forgot-password',
        data: {'username': username.trim()},
      );

      final data = response.data;

      return data['result'] ?? '';
    } on DioException catch (e) {
      throw ErrorParser.parse(
        e.response?.data,
        statusCode: e.response?.statusCode,
      );
    } catch (_) {
      throw AppException('Lỗi không xác định');
    }
  }

  /// ===================== RESET PASSWORD =====================
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

      final data = response.data;
      return data['result'] ?? '';
    } on DioException catch (e) {
      throw ErrorParser.parse(
        e.response?.data,
        statusCode: e.response?.statusCode,
      );
    } catch (_) {
      throw AppException('Lỗi không xác định');
    }
  }

  /// ===================== VALIDATION =====================
  void _validateLoginInput(String username, String password) {
    if (username.trim().isEmpty) throw AppException('Vui lòng nhập username');
    if (password.trim().isEmpty) throw AppException('Vui lòng nhập password');
  }
}
