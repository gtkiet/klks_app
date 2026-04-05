// lib/features/cu_tru/services/cu_tru_service.dart

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_parser.dart';

import '../models/quan_he_cu_tru_model.dart';

class CuTruService {
  CuTruService._();

  static final CuTruService instance = CuTruService._();

  Dio get _dio => ApiClient.instance.dio;

  // ── Danh sách cư trú của người dùng hiện tại ──────────────────────────

  Future<List<QuanHeCuTruModel>> getQuanHeCuTruList() async {
    try {
      final response = await _dio.post('/api/cu-dan/quan-he-cu-tru');
      final data = response.data as Map<String, dynamic>;
      final list = data['result'] as List<dynamic>? ?? [];
      return list
          .map((e) => QuanHeCuTruModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ErrorParser.parse(
        e.response?.data,
        statusCode: e.response?.statusCode,
      );
    } catch (_) {
      throw const AppException('Lỗi không xác định');
    }
  }
}
