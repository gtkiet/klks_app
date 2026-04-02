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
      if (data['isOk'] == true && data['result'] != null) {
        final user = UserModel.fromJson(data['result']);

        if (user.accessToken.isEmpty || user.refreshToken.isEmpty) {
          throw AppException('Token không hợp lệ');
        }

        await _session.saveTokens(
          accessToken: user.accessToken,
          refreshToken: user.refreshToken,
        );

        return user;
      } else {
        throw AppException(ErrorParser.parse(data));
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw AppException('Đã có lỗi xảy ra: $e');
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
      if (data['isOk'] == true && data['result'] != null) {
        final user = UserModel.fromJson(data['result']);
        await _session.saveTokens(
          accessToken: user.accessToken,
          refreshToken: user.refreshToken,
        );
        return user;
      }

      throw AppException(ErrorParser.parse(data));
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw AppException('Đã có lỗi xảy ra: $e');
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
      if (data['isOk'] == true) {
        return data['result'] ?? '';
      }

      throw AppException(ErrorParser.parse(data));
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw AppException('Đã có lỗi xảy ra: $e');
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
      if (data['isOk'] == true) {
        return data['result'] ?? '';
      }

      throw AppException(ErrorParser.parse(data));
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw AppException('Đã có lỗi xảy ra: $e');
    }
  }

  /// ===================== DIO ERROR HANDLER =====================
  AppException _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return AppException('Kết nối quá chậm, vui lòng thử lại');
    }

    if (e.response != null) {
      final statusCode = e.response?.statusCode;

      if (statusCode == 401) {
        return AppException('Sai tài khoản hoặc mật khẩu', code: 401);
      }

      return AppException(
        ErrorParser.parse(e.response?.data),
        code: statusCode,
      );
    }

    return AppException('Không thể kết nối đến server');
  }

  /// ===================== VALIDATION =====================
  void _validateLoginInput(String username, String password) {
    if (username.trim().isEmpty) throw AppException('Vui lòng nhập username');
    if (password.trim().isEmpty) throw AppException('Vui lòng nhập password');
  }
}
