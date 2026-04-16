// lib/features/thanh_vien/services/thanh_vien_service.dart

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/errors/errors.dart';
import '../models/thanh_vien_cu_tru_model.dart';
import '../models/thong_tin_cu_dan_model.dart';

class ThanhVienService {
  ThanhVienService._();

  static final ThanhVienService instance = ThanhVienService._();

  Dio get _dio => ApiClient.instance.dio;

  // ── Thành viên đang cư trú trong một căn hộ ───────────────────────────

  Future<List<ThanhVienCuTruModel>> getThanhVienCuTru(int canHoId) async {
    try {
      final response = await _dio.post(
        '/api/cu-dan/thanh-vien-cu-tru',
        data: {'canHoId': canHoId},
      );
      final data = response.data as Map<String, dynamic>;
      final list = data['result'] as List<dynamic>? ?? [];
      return list
          .map((e) => ThanhVienCuTruModel.fromJson(e as Map<String, dynamic>))
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

  // ── Thông tin chi tiết một cư dân ─────────────────────────────────────

  Future<ThongTinCuDanModel> getThongTinCuDan(int quanHeCuTruId) async {
    try {
      final response = await _dio.post(
        '/api/cu-dan/thong-tin',
        data: {'quanHeCuTruId': quanHeCuTruId},
      );
      final data = response.data as Map<String, dynamic>;
      return ThongTinCuDanModel.fromJson(
        data['result'] as Map<String, dynamic>,
      );
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
