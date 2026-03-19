import 'package:flutter/material.dart';

import '../../../main.dart';
import '../../../config/app_routes.dart';
import '../../../core/network/api_response.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.unknown;
  bool _isLoading = false;       // trạng thái chung (login/register/forgot/reset)
  bool _isLoggingOut = false;    // trạng thái riêng cho logout
  String? _error;

  AuthStatus get status => _status;
  bool get isLoading => _isLoading;
  bool get isLoggingOut => _isLoggingOut;
  String? get error => _error;
  bool get isLoggedIn => _status == AuthStatus.authenticated;

  // ================= INIT =================
  Future<void> init() async {
    _setLoading(true);

    try {
      final success = await _authService.tryAutoLogin();
      _status =
          success ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    }

    _setLoading(false);
  }

  // ================= LOGIN =================
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final ApiResponse res = await _authService.login(
        username: username,
        password: password,
      );

      if (res.isOk) {
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _error = res.message;
        return false;
      }
    } catch (_) {
      _error = "Lỗi kết nối, vui lòng thử lại";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ================= REGISTER =================
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String idCard,
    required DateTime? dob,
    required int genderId,
    required String address,
  }) async {
    _setLoading(true);
    _error = null;

    if (username.isEmpty ||
        password.isEmpty ||
        email.isEmpty ||
        dob == null ||
        genderId == 0) {
      _error = "Vui lòng nhập đầy đủ thông tin";
      _setLoading(false);
      return false;
    }

    try {
      final ApiResponse res = await _authService.register(
        username: username,
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        idCard: idCard,
        dob: dob.toIso8601String(),
        gioiTinhId: genderId,
        address: address,
      );

      if (res.isOk) {
        return true;
      } else {
        _error = res.message;
        return false;
      }
    } catch (_) {
      _error = "Lỗi kết nối, vui lòng thử lại";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    _isLoggingOut = true;
    notifyListeners();

    try {
      await _authService.logout();
    } catch (_) {}

    _isLoggingOut = false;
    _status = AuthStatus.unauthenticated;
    notifyListeners();

    _navigateToLogin();
  }

  // ================= FORCE LOGOUT =================
  void forceLogout() {
    _status = AuthStatus.unauthenticated;
    notifyListeners();
    _navigateToLogin();
  }

  // ================= NAVIGATION =================
  void _navigateToLogin() {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  // ================= HELPER =================
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // ================= FORGOT PASSWORD =================
  Future<ApiResponse<void>> forgotPassword({required String username}) async {
    _setLoading(true);
    _error = null;

    try {
      final res = await _authService.forgotPassword(username: username);
      if (!res.isOk) _error = res.message;
      return res;
    } catch (_) {
      _error = "Lỗi kết nối, vui lòng thử lại";
      return ApiResponse.failure(message: _error);
    } finally {
      _setLoading(false);
    }
  }

  // ================= RESET PASSWORD =================
  Future<ApiResponse<void>> resetPassword({
    required String username,
    required String resetCode,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final res = await _authService.resetPassword(
        username: username,
        resetCode: resetCode,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      if (!res.isOk) _error = res.message;
      return res;
    } catch (_) {
      _error = "Lỗi kết nối, vui lòng thử lại";
      return ApiResponse.failure(message: _error);
    } finally {
      _setLoading(false);
    }
  }
}