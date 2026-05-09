// lib/core/network/api_client.dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'api_interceptor.dart';

class ApiClient {
  static const String baseUrl =
      "https://chungcu-webapi-fwf7cva4c7c6ajae.eastasia-01.azurewebsites.net";

  ApiClient._internal();
  static final ApiClient instance = ApiClient._internal();

  late final Dio dio = _createDio();

  /// Dio không có ApiInterceptor — dùng cho refresh token
  /// để tránh vòng lặp vô hạn khi 401
  late final Dio plainDio = _createPlainDio();

  Dio _createDio() {
    final dio = Dio(_baseOptions());
    dio.interceptors.add(ApiInterceptor(dio));
    return dio;
  }

  Dio _createPlainDio() => Dio(_baseOptions());

  BaseOptions _baseOptions() => BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
    headers: {'Content-Type': 'application/json'},
  );
}

enum ErrorType { network, unauthorized, validation, server, unknown }

class AppException implements Exception {
  /// Message gộp để show nhanh (dùng trong Text / SnackBar).
  final String message;

  /// Danh sách lỗi chi tiết – có khi server trả về nhiều lỗi cùng lúc.
  final List<String>? messages;

  final ErrorType type;

  /// HTTP status code gốc (nếu có).
  final int? code;

  /// Giữ response body gốc để debug.
  final dynamic raw;

  const AppException(
    this.message, {
    this.messages,
    this.type = ErrorType.unknown,
    this.code,
    this.raw,
  });

  @override
  String toString() => message;
}

class ErrorParser {
  ErrorParser._();

  /// Chuyển response body + status code thành [AppException].
  ///
  /// Thứ tự ưu tiên:
  ///   1. `errors[].description`  (validation từ server)
  ///   2. `warningMessages[]`
  ///   3. `message`               (fallback đơn giản)
  ///   4. Generic "Có lỗi xảy ra"
  static AppException parse(dynamic data, {int? statusCode}) {
    try {
      if (data == null) {
        return AppException(
          'Có lỗi xảy ra',
          type: _mapType(statusCode),
          code: statusCode,
        );
      }

      if (data is Map<String, dynamic>) {
        // ── 1. errors[] ───────────────────────────────────────────────────
        final errors = data['errors'];
        if (errors is List && errors.isNotEmpty) {
          final msgs = errors
              .map<String>((e) => e['description']?.toString() ?? '')
              .where((s) => s.isNotEmpty)
              .toList();

          if (msgs.isNotEmpty) {
            return AppException(
              msgs.join('\n'),
              messages: msgs,
              type: ErrorType.validation,
              code: statusCode,
              raw: data,
            );
          }
        }

        // ── 2. warningMessages[] ──────────────────────────────────────────
        final warnings = data['warningMessages'];
        if (warnings is List && warnings.isNotEmpty) {
          final msgs = warnings.map((e) => e.toString()).toList();
          return AppException(
            msgs.join('\n'),
            messages: msgs,
            type: ErrorType.validation,
            code: statusCode,
            raw: data,
          );
        }

        // ── 3. message field ──────────────────────────────────────────────
        final msg = data['message'];
        if (msg != null) {
          return AppException(
            msg.toString(),
            type: _mapType(statusCode),
            code: statusCode,
            raw: data,
          );
        }
      }

      // ── 4. generic fallback ───────────────────────────────────────────────
      return AppException(
        'Có lỗi xảy ra',
        type: _mapType(statusCode),
        code: statusCode,
        raw: data,
      );
    } catch (_) {
      return AppException(
        'Có lỗi xảy ra',
        type: ErrorType.unknown,
        code: statusCode,
        raw: data,
      );
    }
  }

  /// Map HTTP status code → [ErrorType].
  static ErrorType _mapType(int? statusCode) {
    if (statusCode == null) return ErrorType.unknown;
    if (statusCode == 401) return ErrorType.unauthorized;
    if (statusCode >= 400 && statusCode < 500) return ErrorType.validation;
    if (statusCode >= 500) return ErrorType.server;
    return ErrorType.unknown;
  }
}


/// Widget hiển thị lỗi từ [AppException].
///
/// - Nếu chỉ có một lỗi → hiển thị `message` dạng Text đơn.
/// - Nếu có nhiều lỗi   → hiển thị danh sách bullet.
class AppErrorWidget extends StatelessWidget {
  final AppException error;

  const AppErrorWidget({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    final msgs = error.messages;

    if (msgs == null || msgs.length <= 1) {
      return _ErrorText(error.message);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: msgs.map((msg) => _ErrorText('• $msg')).toList(),
    );
  }
}

class _ErrorText extends StatelessWidget {
  final String text;
  const _ErrorText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      // style: TextStyle(color: Theme.of(context).colorScheme.error),
      style: TextStyle(color: Colors.red),
    );
  }
}
