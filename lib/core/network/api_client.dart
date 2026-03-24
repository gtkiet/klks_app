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
      connectTimeout: const Duration(seconds: AppConfig.timeout),
      receiveTimeout: const Duration(seconds: AppConfig.timeout),
      sendTimeout: const Duration(seconds: AppConfig.timeout),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    final dio = Dio(options);
    dio.interceptors.add(ApiInterceptor(dio));
    return dio;
  }

  /// Upload a file
  Future<Response> uploadFile(
    String path, {
    required String fieldName,
    required String filePath,
    Map<String, dynamic>? extraData,
  }) async {
    final file = await MultipartFile.fromFile(filePath);
    final formData = FormData.fromMap({
      fieldName: file,
      if (extraData != null) ...extraData,
    });

    return dio.post(path, data: formData);
  }
}