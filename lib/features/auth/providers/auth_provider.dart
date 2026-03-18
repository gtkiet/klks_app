import 'package:flutter/material.dart';

import '../../../main.dart'; // 👈 dùng navigatorKey
import '../../../config/app_routes.dart';
import '../services/auth_service.dart';

enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.unknown;
  bool _isLoading = false;

  AuthStatus get status => _status;
  bool get isLoading => _isLoading;

  bool get isLoggedIn => _status == AuthStatus.authenticated;

  // ================= INIT =================
  Future<void> init() async {
    _setLoading(true);

    try {
      final success = await _authService.tryAutoLogin();

      _status = success
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    }

    _setLoading(false);
  }

  // ================= LOGIN =================
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    _setLoading(true);

    final result = await _authService.login(
      username: username,
      password: password,
    );

    if (result["isOk"] == true) {
      _status = AuthStatus.authenticated;
      notifyListeners();
    }

    _setLoading(false);
    return result;
  }

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
    _setLoading(true);

    final result = await _authService.register(
      username: username,
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      idCard: idCard,
      dob: dob,
      gioiTinhId: gioiTinhId,
      address: address,
    );

    _setLoading(false);
    return result;
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    _setLoading(true);

    await _authService.logout();

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
}