// lib/features/yeu_cau_sua_chua/services/yeu_cau_sua_chua_service.dart

import 'package:dio/dio.dart';

// import '../../../../core/errors/errors.dart';
import '../../../../core/network/api_client.dart';
import '../models/sua_chua_model.dart';
import '../models/sua_chua_request.dart';

class YeuCauSuaChuaService {
  YeuCauSuaChuaService._();
  static final YeuCauSuaChuaService instance = YeuCauSuaChuaService._();

  Dio get _dio => ApiClient.instance.dio;

  // ── Helper ────────────────────────────────────────────────────────────────

  /// Server envelope: { "isOk": bool, "result": ..., "errors": [] }
  dynamic _extractResult(Response response) {
    final data = response.data as Map<String, dynamic>;
    final isOk = data['isOk'] as bool? ?? false;
    if (!isOk) {
      throw ErrorParser.parse(data, statusCode: response.statusCode);
    }
    return data['result'];
  }

  // ── Catalog APIs ─────────────────────────────────────────────────────────

  Future<List<CatalogItem>> getTrangThaiYeuCau() async {
    try {
      final response = await _dio.post(
        '/api/catalog/trang-thai-yeu-cau-for-selector',
      );
      final result = _extractResult(response) as List<dynamic>;
      return result
          .map((e) => CatalogItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw ErrorParser.parse(
        e.response?.data,
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Trạng thái của quy trình sửa chữa (Đã điều phối, Chờ báo giá,
  /// Đã duyệt báo giá, Đã hẹn lịch, ...) – từ Enums server.
  Future<List<CatalogItem>> getTrangThaiSuaChua() async {
    try {
      final response = await _dio.post(
        '/api/catalog/trang-thai-sua-chua-for-selector',
      );
      final result = _extractResult(response) as List<dynamic>;
      return result
          .map((e) => CatalogItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw ErrorParser.parse(
        e.response?.data,
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<List<CatalogItem>> getLoaiSuCo() async {
    try {
      final response = await _dio.post(
        '/api/catalog/loai-su-co-ky-thuat-for-selector',
      );
      final result = _extractResult(response) as List<dynamic>;
      return result
          .map((e) => CatalogItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw ErrorParser.parse(
        e.response?.data,
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<List<CatalogItem>> getPhamViSuaChua() async {
    try {
      final response = await _dio.post(
        '/api/catalog/pham-vi-sua-chua-for-selector',
      );
      final result = _extractResult(response) as List<dynamic>;
      return result
          .map((e) => CatalogItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw ErrorParser.parse(
        e.response?.data,
        statusCode: e.response?.statusCode,
      );
    }
  }

  // ── Upload media ──────────────────────────────────────────────────────────

  /// Upload nhiều file, trả về list [UploadedFile] (chứa fileId để gửi kèm request)
  Future<List<UploadedFile>> uploadMedia(List<String> filePaths) async {
    try {
      final formData = FormData();

      for (final path in filePaths) {
        formData.files.add(
          MapEntry('files', await MultipartFile.fromFile(path)),
        );
      }

      // targetContainer cho ảnh hiện trạng sửa chữa
      formData.fields.add(const MapEntry('targetContainer', 'tai-lieu-cu-tru'));

      final response = await _dio.post(
        '/api/upload-media',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final result = _extractResult(response) as List<dynamic>;
      return result
          .map((e) => UploadedFile.fromJson(e as Map<String, dynamic>))
          .toList();
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw ErrorParser.parse(
        e.response?.data,
        statusCode: e.response?.statusCode,
      );
    }
  }

  // ── CRUD ─────────────────────────────────────────────────────────────────

  Future<PagedResult<YeuCauSuaChua>> getList(
    GetListYeuCauRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/api/yeu-cau-sua-chua/get-list',
        data: request.toJson(),
      );

      final result = _extractResult(response) as Map<String, dynamic>;
      final pagingInfo = result['pagingInfo'] as Map<String, dynamic>? ?? {};

      final items = (result['items'] as List<dynamic>? ?? [])
          .map((e) => YeuCauSuaChua.fromJson(e as Map<String, dynamic>))
          .toList();

      return PagedResult<YeuCauSuaChua>(
        items: items,
        totalItems: pagingInfo['totalItems'] as int? ?? items.length,
        pageNumber: pagingInfo['pageNumber'] as int? ?? request.pageNumber,
        pageSize: pagingInfo['pageSize'] as int? ?? request.pageSize,
      );
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw ErrorParser.parse(
        e.response?.data,
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<YeuCauSuaChua> getById(int id) async {
    try {
      final response = await _dio.post(
        '/api/yeu-cau-sua-chua/get-by-id',
        data: {'id': id},
      );
      final result = _extractResult(response) as Map<String, dynamic>;
      return YeuCauSuaChua.fromJson(result);
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw ErrorParser.parse(
        e.response?.data,
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<YeuCauSuaChua> taoYeuCau(TaoYeuCauRequest request) async {
    try {
      final response = await _dio.post(
        '/api/yeu-cau-sua-chua',
        data: request.toJson(),
      );
      final result = _extractResult(response) as Map<String, dynamic>;
      return YeuCauSuaChua.fromJson(result);
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw ErrorParser.parse(
        e.response?.data,
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Cập nhật (isWithdraw: false) hoặc Thu hồi (isWithdraw: true)
  Future<YeuCauSuaChua> capNhatYeuCau(CapNhatYeuCauRequest request) async {
    try {
      final response = await _dio.put(
        '/api/yeu-cau-sua-chua',
        data: request.toJson(),
      );
      final result = _extractResult(response) as Map<String, dynamic>;
      return YeuCauSuaChua.fromJson(result);
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw ErrorParser.parse(
        e.response?.data,
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Shortcut thu hồi – dùng PUT với isWithdraw=true
  Future<YeuCauSuaChua> thuHoiYeuCau({
    required int id,
    required int phamViId,
    required int loaiSuCoId,
    required String noiDung,
  }) async {
    return capNhatYeuCau(
      CapNhatYeuCauRequest(
        id: id,
        phamViId: phamViId,
        loaiSuCoId: loaiSuCoId,
        noiDung: noiDung,
        isSubmit: false,
        isWithdraw: true,
      ),
    );
  }
}
