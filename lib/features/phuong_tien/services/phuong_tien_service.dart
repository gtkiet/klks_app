// lib/features/phuong_tien/services/phuong_tien_service.dart

import 'dart:io';
import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';

import '../models/phuong_tien_models.dart';

class PhuongTienService {
  // PhuongTienService._();

  // static final PhuongTienService instance = PhuongTienService._();

  final Dio _dio;

  PhuongTienService({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  // -------------------------------------------------------------------------
  // HELPER: parse response chung
  // -------------------------------------------------------------------------

  void _throwIfNotOk(Map<String, dynamic> data) {
    final isOk = data['isOk'] as bool? ?? false;
    if (!isOk) {
      final errors = data['errors'] as List<dynamic>? ?? [];
      final message = errors.isNotEmpty
          ? (errors.first as Map<String, dynamic>)['description'] as String?
          : 'Đã xảy ra lỗi không xác định';
      throw AppException(message ?? 'Lỗi không xác định');
    }
  }

  // =========================================================================
  // CU DAN
  // =========================================================================

  /// Lấy danh sách quan hệ cư trú của người dùng hiện tại.
  Future<List<QuanHeCuTru>> getQuanHeCuTru() async {
    try {
      final response = await _dio.post('/api/cu-dan/quan-he-cu-tru');
      final data = response.data as Map<String, dynamic>;
      _throwIfNotOk(data);

      final result = data['result'] as List<dynamic>? ?? [];
      return result
          .map((e) => QuanHeCuTru.fromJson(e as Map<String, dynamic>))
          .toList();
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw AppException(ErrorParser.fromDio(e));
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  // =========================================================================
  // CATALOG
  // =========================================================================

  /// Lấy danh sách loại phương tiện cho selector.
  Future<List<SelectorItem>> getLoaiPhuongTien() async {
    try {
      final response = await _dio.post(
        '/api/catalog/loai-phuong-tien-for-selector',
      );
      final data = response.data as Map<String, dynamic>;
      _throwIfNotOk(data);

      final result = data['result'] as List<dynamic>? ?? [];
      return result
          .map((e) => SelectorItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw AppException(ErrorParser.fromDio(e));
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  /// Lấy danh sách trạng thái phương tiện cho selector.
  Future<List<SelectorItem>> getTrangThaiPhuongTien() async {
    try {
      final response = await _dio.post(
        '/api/catalog/trang-thai-phuong-tien-for-selector',
      );
      final data = response.data as Map<String, dynamic>;
      _throwIfNotOk(data);

      final result = data['result'] as List<dynamic>? ?? [];
      return result
          .map((e) => SelectorItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw AppException(ErrorParser.fromDio(e));
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  // =========================================================================
  // PHUONG TIEN
  // =========================================================================

  /// Lấy danh sách phương tiện (có phân trang và filter).
  Future<PagedResult<PhuongTien>> getListPhuongTien(
    GetListPhuongTienRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/api/phuong-tien/get-list',
        data: request.toJson(),
      );
      final data = response.data as Map<String, dynamic>;
      _throwIfNotOk(data);

      final resultMap = data['result'] as Map<String, dynamic>;
      final items = (resultMap['items'] as List<dynamic>? ?? [])
          .map((e) => PhuongTien.fromJson(e as Map<String, dynamic>))
          .toList();
      final pagingInfo = PagingInfo.fromJson(
        resultMap['pagingInfo'] as Map<String, dynamic>,
      );

      return PagedResult(items: items, pagingInfo: pagingInfo);
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw AppException(ErrorParser.fromDio(e));
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  /// Lấy chi tiết một phương tiện theo Id.
  Future<PhuongTien> getPhuongTienById(int id) async {
    try {
      final response = await _dio.post(
        '/api/phuong-tien/get-by-id',
        data: {'id': id},
      );
      final data = response.data as Map<String, dynamic>;
      _throwIfNotOk(data);

      return PhuongTien.fromJson(data['result'] as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw AppException(ErrorParser.fromDio(e));
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  // =========================================================================
  // YEU CAU PHUONG TIEN
  // =========================================================================

  /// Lấy danh sách yêu cầu phương tiện (có phân trang và filter).
  Future<PagedResult<YeuCauPhuongTien>> getListYeuCau({
    int pageNumber = 1,
    int pageSize = 20,
    int? toaNhaId,
    int? tangId,
    int? canHoId,
    int? loaiYeuCauId,
    int? trangThaiId,
  }) async {
    try {
      final body = <String, dynamic>{
        'pageNumber': pageNumber,
        'pageSize': pageSize,
        'toaNhaId': ?toaNhaId,
        'tangId': ?tangId,
        'canHoId': ?canHoId,
        'loaiYeuCauId': ?loaiYeuCauId,
        'trangThaiId': ?trangThaiId,
      };

      final response = await _dio.post(
        '/api/phuong-tien/yeu-cau/get-list',
        data: body,
      );
      final data = response.data as Map<String, dynamic>;
      _throwIfNotOk(data);

      final resultMap = data['result'] as Map<String, dynamic>;
      final items = (resultMap['items'] as List<dynamic>? ?? [])
          .map((e) => YeuCauPhuongTien.fromJson(e as Map<String, dynamic>))
          .toList();
      final pagingInfo = PagingInfo.fromJson(
        resultMap['pagingInfo'] as Map<String, dynamic>,
      );

      return PagedResult(items: items, pagingInfo: pagingInfo);
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw AppException(ErrorParser.fromDio(e));
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  /// Lấy chi tiết một yêu cầu phương tiện theo requestId.
  Future<YeuCauPhuongTien> getYeuCauById(int requestId) async {
    try {
      final response = await _dio.post(
        '/api/phuong-tien/yeu-cau/get-by-id',
        data: {'requestId': requestId},
      );
      final data = response.data as Map<String, dynamic>;
      _throwIfNotOk(data);

      return YeuCauPhuongTien.fromJson(data['result'] as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw AppException(ErrorParser.fromDio(e));
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  /// Tạo mới yêu cầu phương tiện.
  Future<YeuCauPhuongTien> taoYeuCau(TaoYeuCauRequest request) async {
    try {
      final response = await _dio.post(
        '/api/phuong-tien/yeu-cau',
        data: request.toJson(),
      );
      final data = response.data as Map<String, dynamic>;
      _throwIfNotOk(data);

      return YeuCauPhuongTien.fromJson(data['result'] as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw AppException(ErrorParser.fromDio(e));
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  /// Cập nhật yêu cầu phương tiện (submit / withdraw / edit).
  Future<YeuCauPhuongTien> capNhatYeuCau(CapNhatYeuCauRequest request) async {
    try {
      final response = await _dio.put(
        '/api/phuong-tien/yeu-cau',
        data: request.toJson(),
      );
      final data = response.data as Map<String, dynamic>;
      _throwIfNotOk(data);

      return YeuCauPhuongTien.fromJson(data['result'] as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw AppException(ErrorParser.fromDio(e));
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  // =========================================================================
  // THE PHUONG TIEN - BÁO MẤT
  // =========================================================================

  /// Báo mất thẻ phương tiện (khóa thẻ ngay lập tức).
  Future<void> baoMatThe(List<int> theIds) async {
    try {
      final response = await _dio.put(
        '/api/phuong-tien/the-phuong-tien/bao-mat',
        data: {'theIds': theIds},
      );
      final data = response.data as Map<String, dynamic>;
      _throwIfNotOk(data);
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw AppException(ErrorParser.fromDio(e));
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  // =========================================================================
  // UPLOAD MEDIA
  // =========================================================================

  /// Upload nhiều file (multipart/form-data).
  /// [targetContainer]: 'tai-lieu-cu-tru' | 'tai-lieu-phuong-tien'
  Future<List<UploadedFile>> uploadMedia({
    required List<File> files,
    String targetContainer = 'tai-lieu-phuong-tien',
  }) async {
    try {
      final formData = FormData();

      formData.fields.add(MapEntry('targetContainer', targetContainer));

      for (final file in files) {
        final fileName = file.path.split('/').last;
        formData.files.add(
          MapEntry(
            'files',
            await MultipartFile.fromFile(file.path, filename: fileName),
          ),
        );
      }

      final response = await _dio.post(
        '/api/upload-media',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      final data = response.data as Map<String, dynamic>;
      _throwIfNotOk(data);

      final result = data['result'] as List<dynamic>? ?? [];
      return result
          .map((e) => UploadedFile.fromJson(e as Map<String, dynamic>))
          .toList();
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw AppException(ErrorParser.fromDio(e));
    } catch (e) {
      throw AppException(e.toString());
    }
  }
}

// =============================================================================
// STUB CLASSES - Xóa khi tích hợp vào project thật
// Thay thế bằng import từ core/network và core/error
// =============================================================================

class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

class ErrorParser {
  static String fromDio(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        final errors = data['errors'] as List<dynamic>?;
        if (errors != null && errors.isNotEmpty) {
          return (errors.first as Map<String, dynamic>)['description']
                  as String? ??
              'Lỗi từ server';
        }
      }
      return 'Lỗi HTTP ${e.response!.statusCode}';
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Kết nối bị timeout. Vui lòng thử lại.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Không có kết nối mạng. Vui lòng kiểm tra lại.';
    }
    return e.message ?? 'Lỗi không xác định';
  }
}
