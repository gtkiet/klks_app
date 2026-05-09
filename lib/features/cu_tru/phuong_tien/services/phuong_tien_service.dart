// lib/features/cu_tru/phuong_tien/services/phuong_tien_service.dart

import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
// import '../../../../core/errors/errors.dart';

import '../models/phuong_tien_model.dart';
import '../models/phuong_tien_request_models.dart';

class PhuongTienService {
  PhuongTienService._();
  
  static final instance = PhuongTienService._();

  Dio get _dio => ApiClient.instance.dio;

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Parse response.data, kiểm tra isOk, trả về data['result'].
  /// Ném [AppException] ngay nếu isOk == false.
  Map<String, dynamic> _getResult(dynamic responseData) {
    final data = responseData as Map<String, dynamic>;
    final isOk = data['isOk'] as bool? ?? false;
    if (!isOk) {
      // Tái dụng ErrorParser để parse errors[] / warningMessages[] nhất quán
      throw ErrorParser.parse(data, statusCode: null);
    }
    return data['result'] as Map<String, dynamic>;
  }

  // =========================================================================
  // PHUONG TIEN
  // =========================================================================

  Future<PagedResult<PhuongTien>> getListPhuongTien(
    GetListPhuongTienRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/api/phuong-tien/get-list',
        data: request.toJson(),
      );
      return PagedResult.fromJson(
        _getResult(response.data),
        PhuongTien.fromJson,
      );
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw ErrorParser.parse(
        e.response?.data,
        statusCode: e.response?.statusCode,
      );
    } catch (_) {
      throw const AppException('Lỗi không xác định');
    }
  }

  Future<PhuongTien> getPhuongTienById(int id) async {
    try {
      final response = await _dio.post(
        '/api/phuong-tien/get-by-id',
        data: {'id': id},
      );
      return PhuongTien.fromJson(_getResult(response.data));
    } on AppException {
      rethrow;
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
