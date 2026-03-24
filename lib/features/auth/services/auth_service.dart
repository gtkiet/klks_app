import 'package:dio/dio.dart';

import '../../../core/network/auth_api.dart';
import '../../../core/storage/user_session.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_parser.dart';

class AuthService {
  final AuthApi _authApi = AuthApi();
  final UserSession _session = UserSession();

  /// ===================== LOGIN =====================
  Future<void> login({
    required String username,
    required String password,
  }) async {
    try {
      _validateLoginInput(username, password);

      final response = await _authApi.login(
        username: username.trim(),
        password: password.trim(),
      );

      final data = response.data;

      if (data['isOk'] == true && data['result'] != null) {
        final result = data['result'];

        final accessToken = result['accessToken'];
        final refreshToken = result['refreshToken'];

        if (accessToken == null || refreshToken == null) {
          throw AppException('Token không hợp lệ');
        }

        await _session.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
      } else {
        throw AppException(ErrorParser.parse(data));
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException('Đã có lỗi xảy ra');
    }
  }

  /// ===================== REGISTER =====================
  Future<Map<String, dynamic>> register({
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
  }) async {
    try {
      final response = await _authApi.register(
        username: username,
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        idCard: idCard,
        dob: dob,
        gioiTinhId: gioiTinhId,
        diaChi: diaChi,
      );

      final data = response.data;

      if (data['isOk'] == true && data['result'] != null) {
        return data['result'];
      }

      throw AppException(ErrorParser.parse(data));
    } on DioException catch (e) {
      throw _handleDioError(e);
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException('Đã có lỗi xảy ra');
    }
  }

  /// ===================== REFRESH TOKEN =====================
  Future<void> refreshToken() async {
    try {
      final refreshToken = await _session.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        throw AppException('Không có refresh token');
      }

      final response = await _authApi.refreshToken(
        refreshToken: refreshToken,
      );

      final data = response.data;

      if (data['isOk'] == true && data['result'] != null) {
        final result = data['result'];

        await _session.saveTokens(
          accessToken: result['accessToken'],
          refreshToken: result['refreshToken'],
        );
      } else {
        throw AppException(ErrorParser.parse(data));
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (_) {
      throw AppException('Không thể refresh token');
    }
  }

  /// ===================== AUTO LOGIN =====================
  Future<bool> tryAutoLogin() async {
    try {
      final accessToken = await _session.getAccessToken();

      if (accessToken != null && accessToken.isNotEmpty) {
        return true;
      }

      final refreshToken = await _session.getRefreshToken();

      if (refreshToken != null && refreshToken.isNotEmpty) {
        await this.refreshToken().timeout(const Duration(seconds: 5));
        return true;
      }

      return false;
    } catch (_) {
      await _session.clearSession();
      return false;
    }
  }

  /// ===================== LOGOUT =====================
  Future<void> logout() async {
    try {
      await _authApi.logout();
    } catch (_) {
      // ignore server error
    } finally {
      await _session.clearSession();
    }
  }

  /// ===================== FORGOT PASSWORD =====================
  Future<void> forgotPassword({required String username}) async {
    try {
      final response = await _authApi.forgotPassword(username: username);

      final data = response.data;

      if (data['isOk'] != true) {
        throw AppException(ErrorParser.parse(data));
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// ===================== RESET PASSWORD =====================
  Future<void> resetPassword({
    required String username,
    required String resetCode,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      if (newPassword != confirmPassword) {
        throw AppException('Mật khẩu không khớp');
      }

      final response = await _authApi.resetPassword(
        username: username,
        resetCode: resetCode,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      final data = response.data;

      if (data['isOk'] != true) {
        throw AppException(ErrorParser.parse(data));
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// ===================== DIO ERROR =====================
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
    if (username.trim().isEmpty) {
      throw AppException('Vui lòng nhập username');
    }

    if (password.trim().isEmpty) {
      throw AppException('Vui lòng nhập password');
    }
  }
}