// lib/core/guards/auth_guard.dart

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../storage/user_session.dart';
import '../config/app_config.dart';

class AuthGuard extends ChangeNotifier {
  AuthGuard._();
  static final AuthGuard instance = AuthGuard._();

  final UserSession _session = UserSession();

  AuthStatus _status = AuthStatus.unknown;
  AuthStatus get status => _status;

  bool _initialized = false;
  bool _isInitializing = false;

  late final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  /// ===================== INIT GUARD =====================
  Future<void> init() async {
    if (_initialized || _isInitializing) return;

    _isInitializing = true;

    try {
      final isLoggedIn = await tryAutoLogin();
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

  /// ===================== TRY AUTO LOGIN =====================
  Future<bool> tryAutoLogin() async {
    try {
      final accessToken = await _session.getAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) return true;

      final refreshToken = await _session.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        final success = await _refreshToken(refreshToken);
        return success;
      }

      return false;
    } catch (_) {
      await _session.clearSession();
      return false;
    }
  }

  /// ===================== REFRESH TOKEN =====================
  Future<bool> _refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        '/api/auth/refresh-token',
        data: {'refreshToken': refreshToken},
      );

      final data = response.data;

      if (data['isOk'] == true && data['result'] != null) {
        final result = data['result'];
        final newAccess = result['accessToken'];
        final newRefresh = result['refreshToken'];

        if (newAccess != null && newRefresh != null) {
          await _session.saveTokens(
            accessToken: newAccess,
            refreshToken: newRefresh,
          );
          return true;
        }
      }

      return false;
    } catch (_) {
      return false;
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
      _setStatus(AuthStatus.unauthenticated);
    }
  }

  /// ===================== SET STATUS =====================
  void _setStatus(AuthStatus status) {
    if (_status == status) return;
    _status = status;
    notifyListeners();
  }

  void setAuthenticated() => _setStatus(AuthStatus.authenticated);
}

enum AuthStatus { unknown, authenticated, unauthenticated }