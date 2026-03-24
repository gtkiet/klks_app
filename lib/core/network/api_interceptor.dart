// File: lib/core/network/api_interceptor.dart

import 'dart:async';
import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../constants/api_constants.dart';
import '../constants/storage_keys.dart';
import '../guards/auth_guard.dart';
import '../storage/user_session.dart';
import '../controllers/loading_controller.dart';
import 'auth_api.dart';

class ApiInterceptor extends Interceptor {
  final Dio dio;

  ApiInterceptor(this.dio);

  final _session = UserSession();
  final _authApi = AuthApi();

  bool _isRefreshing = false;
  final List<_PendingRequest> _queue = [];

  int _requestCount = 0;

  void _showLoading(bool skip) {
    if (skip) return;
    _requestCount++;
    if (_requestCount == 1) {
      LoadingController.instance.show();
    }
  }

  void _hideLoading(bool skip) {
    if (skip) return;

    if (_requestCount > 0) {
      _requestCount--;
    }

    if (_requestCount == 0) {
      LoadingController.instance.hide();
    }
  }

  @override
  Future<void> onRequest(options, handler) async {
    final skipLoading = options.extra['skipLoading'] == true;
    _showLoading(skipLoading);

    if (options.extra['skipAuth'] == true) {
      return handler.next(options);
    }

    final token = await _session.getAccessToken();

    if (token != null && token.isNotEmpty) {
      options.headers[ApiConstants.authorization] = '${ApiConstants.bearer} $token';
    }

    handler.next(options);
  }

  @override
  void onResponse(response, handler) {
    final skipLoading = response.requestOptions.extra['skipLoading'] == true;
    _hideLoading(skipLoading);

    handler.next(response);
  }

  @override
  Future<void> onError(err, handler) async {
    final request = err.requestOptions;
    final skipLoading = request.extra['skipLoading'] == true;

    _hideLoading(skipLoading);

    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    if (request.extra['skipAuth'] == true || request.extra['isRetry'] == true) {
      await _logout();
      return handler.next(err);
    }

    /// 🔁 queue khi đang refresh
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
      final success = await _refreshToken();

      if (!success) {
        await _failQueue();
        await _logout();
        return handler.next(err);
      }

      final response = await _retry(request);

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

  Future<bool> _refreshToken() async {
    try {
      final refresh = await _session.getRefreshToken();

      if (refresh == null || refresh.isEmpty) return false;

      final res = await _authApi
          .refreshToken(refreshToken: refresh)
          .timeout(const Duration(seconds: AppConfig.timeout));

      final data = res.data;

      if (data['isOk'] == true && data['result'] != null) {
        final r = data['result'];

        await _session.saveTokens(
          accessToken: r[StorageKeys.accessToken],
          refreshToken: r[StorageKeys.refreshToken],
        );

        return true;
      }

      return false;
    } catch (_) {
      return false;
    }
  }

  Future<Response> _retry(RequestOptions request) async {
    final token = await _session.getAccessToken();

    final options = Options(
      method: request.method,
      headers: {
        ...request.headers,
        if (token != null) ApiConstants.authorization: '${ApiConstants.bearer} $token',
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
      p.completer.completeError(Exception('Refresh failed'));
    }
    _queue.clear();
  }

  Future<void> _logout() async {
    await _session.clearSession();
    AuthGuard.instance.forceLogout();
  }
}

class _PendingRequest {
  final RequestOptions request;
  final Completer<Response> completer;

  _PendingRequest(this.request, this.completer);
}
