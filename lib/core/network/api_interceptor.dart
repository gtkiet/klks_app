// lib/core/network/api_interceptor.dart

import 'dart:async';
import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../guards/auth_guard.dart';
import '../storage/user_session.dart';

/// ===================== REFRESH TOKEN CLIENT =====================
class RefreshTokenClient {
  RefreshTokenClient() {
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

  /// Trả về accessToken mới nếu thành công, null nếu thất bại
  Future<String?> refreshToken({String? refreshToken}) async {
    try {
      final token = refreshToken ?? await _session.getRefreshToken();
      if (token == null || token.isEmpty) return null;

      final response = await _dio.post(
        '/api/auth/refresh-token',
        data: {'refreshToken': token},
      );

      final data = response.data;
      if (data['isOk'] == true && data['result'] != null) {
        final result = data['result'];
        final newAccess = result['accessToken'] as String?;
        final newRefresh = result['refreshToken'] as String?;

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
}

/// ===================== API INTERCEPTOR =====================
class ApiInterceptor extends Interceptor {
  final Dio dio;
  final UserSession _session = UserSession();
  final RefreshTokenClient _refreshClient = RefreshTokenClient();

  ApiInterceptor(this.dio);

  bool _isRefreshing = false;
  final List<_PendingRequest> _queue = [];

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra['skipAuth'] == true) {
      return handler.next(options);
    }

    final token = await _session.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final request = err.requestOptions;

    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Nếu đã retry hoặc skipAuth → logout
    if (request.extra['skipAuth'] == true || request.extra['isRetry'] == true) {
      await _logout();
      return handler.next(err);
    }

    // Nếu đang refresh → queue
    if (_isRefreshing) {
      final completer = Completer<Response>();
      _queue.add(_PendingRequest(request, completer));
      try {
        final res = await completer.future;
        return handler.resolve(res);
      } catch (_) {
        return handler.next(err);
      }
    }

    _isRefreshing = true;

    try {
      final success = await _handleRefreshToken();
      if (!success) {
        await _failQueue();
        await _logout();
        return handler.next(err);
      }

      // Retry request hiện tại
      final response = await _retry(request);

      // Retry queue
      for (final p in _queue) {
        try {
          final res = await _retry(p.request);
          p.completer.complete(res);
        } catch (e) {
          p.completer.completeError(e);
        }
      }
      _queue.clear();

      return handler.resolve(response);
    } catch (_) {
      await _failQueue();
      await _logout();
      return handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }

  Future<bool> _handleRefreshToken() async {
    final refresh = await _session.getRefreshToken();
    if (refresh == null || refresh.isEmpty) return false;

    final newAccess = await _refreshClient.refreshToken(refreshToken: refresh);
    return newAccess != null;
  }

  Future<Response> _retry(RequestOptions request) async {
    final token = await _session.getAccessToken();

    final options = Options(
      method: request.method,
      headers: {
        ...request.headers,
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      extra: {...request.extra, 'isRetry': true},
    );

    return dio.request(
      request.path,
      data: request.data,
      queryParameters: request.queryParameters,
      options: options,
    );
  }

  Future<void> _failQueue() async {
    for (final p in _queue) {
      p.completer.completeError(Exception('Refresh token failed'));
    }
    _queue.clear();
  }

  Future<void> _logout() async {
    // await _session.clearSession();
    AuthGuard.instance.logout();
  }
}

/// ===================== PENDING REQUEST =====================
class _PendingRequest {
  final RequestOptions request;
  final Completer<Response> completer;

  _PendingRequest(this.request, this.completer);
}
