// lib/core/network/api_client.dart

import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'api_interceptor.dart';

class ApiClient {
  ApiClient._internal();
  static final ApiClient instance = ApiClient._internal();

  late final Dio dio = _createDio();

  Dio _createDio() {
    final options = BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    );

    final dio = Dio(options);
    dio.interceptors.add(ApiInterceptor(dio));
    return dio;
  }
}
