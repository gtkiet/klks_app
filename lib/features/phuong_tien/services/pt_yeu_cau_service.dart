// lib/features/phuong_tien/services/pt_yeu_cau_service.dart

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/errors/errors.dart';

import '../../utils/models/paged_result.dart';
import '../models/yeu_cau_phuong_tien_model.dart';
import '../models/phuong_tien_request_models.dart';

class PTYeuCauService {
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
  // YEU CAU PHUONG TIEN
  // =========================================================================

  Future<PagedResult<YeuCauPhuongTien>> getListYeuCau(
    GetListYeuCauPhuongTienRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/api/phuong-tien/yeu-cau/get-list',
        data: request.toJson(),
      );
      return PagedResult.fromJson(
        _getResult(response.data),
        YeuCauPhuongTien.fromJson,
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

  Future<YeuCauPhuongTien> getYeuCauById(int requestId) async {
    try {
      final response = await _dio.post(
        '/api/phuong-tien/yeu-cau/get-by-id',
        data: {'requestId': requestId},
      );
      return YeuCauPhuongTien.fromJson(_getResult(response.data));
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

  Future<YeuCauPhuongTien> taoYeuCau(TaoYeuCauPhuongTienRequest request) async {
    try {
      final response = await _dio.post(
        '/api/phuong-tien/yeu-cau',
        data: request.toJson(),
      );
      return YeuCauPhuongTien.fromJson(_getResult(response.data));
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

  Future<YeuCauPhuongTien> capNhatYeuCau(
    CapNhatYeuCauPhuongTienRequest request,
  ) async {
    try {
      final response = await _dio.put(
        '/api/phuong-tien/yeu-cau',
        data: request.toJson(),
      );
      return YeuCauPhuongTien.fromJson(_getResult(response.data));
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

  // =========================================================================
  // THE PHUONG TIEN
  // =========================================================================

  Future<void> baoMatThe(List<int> theIds) async {
    try {
      final response = await _dio.put(
        '/api/phuong-tien/the-phuong-tien/bao-mat',
        data: {'theIds': theIds},
      );
      // _getResult kiêm luôn vai trò kiểm tra isOk
      _getResult(response.data);
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
