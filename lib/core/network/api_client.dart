// lib/core/network/api_client.dart
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'api_interceptor.dart';

class ApiClient {
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
    baseUrl: AppConfig.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
    headers: {'Content-Type': 'application/json'},
  );
}
