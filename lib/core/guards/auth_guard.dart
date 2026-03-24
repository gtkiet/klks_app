/// core/guards/auth_guard.dart

import 'package:flutter/material.dart';
import '../storage/user_session.dart';
import '../../features/auth/services/auth_service.dart';

class AuthGuard extends ChangeNotifier {
  AuthGuard._();
  static final AuthGuard instance = AuthGuard._();

  final AuthService _authService = AuthService();
  final UserSession _session = UserSession();

  AuthStatus _status = AuthStatus.unknown;
  AuthStatus get status => _status;

  bool _initialized = false;
  bool _isInitializing = false;

  Future<void> init() async {
    if (_initialized || _isInitializing) return;

    _isInitializing = true;

    try {
      final isLoggedIn = await _authService.tryAutoLogin();

      _setStatus(
        isLoggedIn ? AuthStatus.authenticated : AuthStatus.unauthenticated,
      );
    } catch (_) {
      _setStatus(AuthStatus.unauthenticated);
    } finally {
      _initialized = true;
      _isInitializing = false;
    }
  }

  void _setStatus(AuthStatus status) {
    if (_status == status) return;
    _status = status;
    notifyListeners();
  }

  void setAuthenticated() => _setStatus(AuthStatus.authenticated);

  Future<void> logout() async {
    await _session.clearSession();
    _setStatus(AuthStatus.unauthenticated);
  }

  void forceLogout() => _setStatus(AuthStatus.unauthenticated);
}

enum AuthStatus { unknown, authenticated, unauthenticated }
