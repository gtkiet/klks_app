// lib/core/network/api_interceptor.dart

import 'dart:async';
import 'package:dio/dio.dart';

import 'package:klks_app/core/storage/user_session.dart';

/// FIX: Thay vì import AuthService trực tiếp — tạo ra circular dependency:
///   ApiInterceptor → AuthService → ApiClient → ApiInterceptor
///
/// Interceptor nhận 2 callback được inject từ ngoài (bởi ApiClient
/// sau khi AuthService đã init xong), phá vỡ cycle hoàn toàn.
///
/// Setup (gọi một lần trong main() sau khi cả hai singleton đã ready):
/// ```dart
/// ApiClient.instance.interceptor.setAuthCallbacks(
///   onRefresh: () => AuthService.instance.refreshToken(),
///   onLogout:  () => AuthService.instance.logout(),
/// );
/// ```
typedef RefreshCallback = Future<String?> Function();
typedef LogoutCallback = Future<void> Function();

class ApiInterceptor extends Interceptor {
  final Dio dio;
  final UserSession _session = UserSession.instance;

  RefreshCallback? _onRefresh;
  LogoutCallback? _onLogout;

  ApiInterceptor(this.dio);

  /// Inject auth callbacks sau khi AuthService đã sẵn sàng.
  /// Gọi một lần duy nhất trong main() hoặc app bootstrap.
  void setAuthCallbacks({
    required RefreshCallback onRefresh,
    required LogoutCallback onLogout,
  }) {
    _onRefresh = onRefresh;
    _onLogout = onLogout;
  }

  bool _isRefreshing = false;
  final List<_PendingRequest> _queue = [];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.extra['skipAuth'] == true) return handler.next(options);
    final token = _session.accessToken;
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

    if (err.response?.statusCode != 401) return handler.next(err);

    // skipAuth: endpoint public → không xử lý 401.
    // isRetry: đã retry rồi vẫn 401 → token thực sự hết hạn → logout.
    if (request.extra['skipAuth'] == true || request.extra['isRetry'] == true) {
      await _logout();
      return handler.next(err);
    }

    // Đang refresh: xếp vào queue, đợi kết quả từ request đang refresh.
    if (_isRefreshing) {
      final completer = Completer<Response>();
      _queue.add(_PendingRequest(request, completer));
      try {
        return handler.resolve(await completer.future);
      } catch (_) {
        return handler.next(err);
      }
    }

    _isRefreshing = true;

    try {
      final newAccess = await _onRefresh?.call();

      if (newAccess == null) {
        await _failQueue();
        await _logout();
        return handler.next(err);
      }

      // Retry request gốc với token mới.
      final retried = await _retry(request);

      // Resolve tất cả request đang chờ trong queue.
      for (final p in _queue) {
        try {
          p.completer.complete(await _retry(p.request));
        } catch (e) {
          p.completer.completeError(e);
        }
      }
      _queue.clear();
      return handler.resolve(retried);
    } catch (_) {
      await _failQueue();
      await _logout();
      return handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }

  Future<Response> _retry(RequestOptions request) {
    final token = _session.accessToken;
    return dio.request(
      request.path,
      data: request.data,
      queryParameters: request.queryParameters,
      options: Options(
        method: request.method,
        headers: {
          ...request.headers,
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
        extra: {...request.extra, 'isRetry': true},
      ),
    );
  }

  Future<void> _failQueue() async {
    for (final p in _queue) {
      p.completer.completeError(Exception('Refresh token failed'));
    }
    _queue.clear();
  }

  Future<void> _logout() async {
    if (_onLogout != null) {
      await _onLogout!();
    } else {
      // Fallback an toàn khi callback chưa được inject.
      await _session.clear();
    }
  }
}

class _PendingRequest {
  final RequestOptions request;
  final Completer<Response> completer;
  _PendingRequest(this.request, this.completer);
}
