// lib/features/cu_tru/services/cu_tru_service.dart

import 'dart:io';
import 'package:dio/dio.dart';

import '../models/quan_he_cu_tru_model.dart';
import '../models/thanh_vien_cu_tru_model.dart';
import '../models/thong_tin_cu_dan_model.dart';
import '../models/yeu_cau_cu_tru_model.dart';

import '../../../core/network/api_client.dart';
// import '../../../core/errors/app_exception.dart';
// import '../../../core/errors/error_parser.dart';

class CuTruService {
  // Dùng singleton Dio từ ApiClient
  Dio get _dio => ApiClient.instance.dio;

  // ────────────────────────────────────────────────────────────────────────────
  // 1. Lấy danh sách căn hộ cư trú của user hiện tại
  // ────────────────────────────────────────────────────────────────────────────

  Future<List<QuanHeCuTruModel>> getQuanHeCuTruList() async {
    try {
      final response = await _dio.post('/api/cu-dan/quan-he-cu-tru');
      final data = response.data as Map<String, dynamic>;

      if (data['isOk'] == true) {
        final list = data['result'] as List<dynamic>? ?? [];
        return list.map((e) => QuanHeCuTruModel.fromJson(e)).toList();
      }

      throw AppException(ErrorParser.parseErrors(data['errors']));
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw AppException(_dioErrorMessage(e));
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 2. Lấy danh sách thành viên đang cư trú trong một căn hộ
  // ────────────────────────────────────────────────────────────────────────────

  Future<List<ThanhVienCuTruModel>> getThanhVienCuTru(int canHoId) async {
    try {
      final response = await _dio.post(
        '/api/cu-dan/thanh-vien-cu-tru',
        data: {'canHoId': canHoId},
      );
      final data = response.data as Map<String, dynamic>;

      if (data['isOk'] == true) {
        final list = data['result'] as List<dynamic>? ?? [];
        return list.map((e) => ThanhVienCuTruModel.fromJson(e)).toList();
      }

      throw AppException(ErrorParser.parseErrors(data['errors']));
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw AppException(_dioErrorMessage(e));
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 3. Lấy thông tin chi tiết của một cư dân theo quanHeCuTruId
  // ────────────────────────────────────────────────────────────────────────────

  Future<ThongTinCuDanModel> getThongTinCuDan(int quanHeCuTruId) async {
    try {
      final response = await _dio.post(
        '/api/cu-dan/thong-tin',
        data: {'quanHeCuTruId': quanHeCuTruId},
      );
      final data = response.data as Map<String, dynamic>;

      if (data['isOk'] == true) {
        return ThongTinCuDanModel.fromJson(data['result']);
      }

      throw AppException(ErrorParser.parseErrors(data['errors']));
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw AppException(_dioErrorMessage(e));
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 4. Catalog: Loại yêu cầu (Thêm/Sửa/Xóa)
  // ────────────────────────────────────────────────────────────────────────────

  Future<List<SelectorItemModel>> getLoaiYeuCauSelector() async {
    try {
      final response = await _dio.post(
        '/api/catalog/loai-yeu-cau-for-selector',
      );
      final data = response.data as Map<String, dynamic>;

      if (data['isOk'] == true) {
        final list = data['result'] as List<dynamic>? ?? [];
        return list.map((e) => SelectorItemModel.fromJson(e)).toList();
      }

      throw AppException(ErrorParser.parseErrors(data['errors']));
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw AppException(_dioErrorMessage(e));
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 5. Catalog: Trạng thái yêu cầu cư trú
  // ────────────────────────────────────────────────────────────────────────────

  Future<List<SelectorItemModel>> getTrangThaiYeuCauSelector() async {
    try {
      final response = await _dio.post(
        '/api/catalog/trang-thai-yeu-cau-cu-tru-for-selector',
      );
      final data = response.data as Map<String, dynamic>;

      if (data['isOk'] == true) {
        final list = data['result'] as List<dynamic>? ?? [];
        return list.map((e) => SelectorItemModel.fromJson(e)).toList();
      }

      throw AppException(ErrorParser.parseErrors(data['errors']));
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw AppException(_dioErrorMessage(e));
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 6. Catalog: Giới tính
  // ────────────────────────────────────────────────────────────────────────────

  Future<List<SelectorItemModel>> getGioiTinhSelector() async {
    try {
      final response = await _dio.post('/api/catalog/gioi-tinh-for-selector');
      final data = response.data as Map<String, dynamic>;

      if (data['isOk'] == true) {
        final list = data['result'] as List<dynamic>? ?? [];
        return list.map((e) => SelectorItemModel.fromJson(e)).toList();
      }

      throw AppException(ErrorParser.parseErrors(data['errors']));
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw AppException(_dioErrorMessage(e));
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 7. Catalog: Loại quan hệ cư trú (Chủ hộ, Thành viên, ...)
  // ────────────────────────────────────────────────────────────────────────────

  Future<List<SelectorItemModel>> getLoaiQuanHeCuTruSelector() async {
    try {
      final response = await _dio.post(
        '/api/catalog/loai-quan-he-cu-tru-for-selector',
      );
      final data = response.data as Map<String, dynamic>;

      if (data['isOk'] == true) {
        final list = data['result'] as List<dynamic>? ?? [];
        return list.map((e) => SelectorItemModel.fromJson(e)).toList();
      }

      throw AppException(ErrorParser.parseErrors(data['errors']));
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw AppException(_dioErrorMessage(e));
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 8. Lấy danh sách yêu cầu cư trú (có phân trang & filter)
  // ────────────────────────────────────────────────────────────────────────────

  Future<YeuCauCuTruListResult> getYeuCauList({
    required int pageNumber,
    required int pageSize,
    int? toaNhaId,
    int? tangId,
    int? canHoId,
    int? loaiYeuCauId,
    int? trangThaiId,
    String? sortCol,
    bool isAsc = true,
  }) async {
    try {
      final response = await _dio.post(
        '/api/quan-he-cu-tru/yeu-cau/get-list',
        data: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
          'toaNhaId': ?toaNhaId,
          'tangId': ?tangId,
          'canHoId': ?canHoId,
          'loaiYeuCauId': ?loaiYeuCauId,
          'trangThaiId': ?trangThaiId,
          'sortCol': ?sortCol,
          'isAsc': isAsc,
        },
      );
      final data = response.data as Map<String, dynamic>;

      if (data['isOk'] == true) {
        return YeuCauCuTruListResult.fromJson(data['result']);
      }

      throw AppException(ErrorParser.parseErrors(data['errors']));
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw AppException(_dioErrorMessage(e));
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 9. Lấy chi tiết một yêu cầu cư trú theo ID
  // ────────────────────────────────────────────────────────────────────────────

  Future<YeuCauCuTruModel> getYeuCauById(int requestId) async {
    try {
      final response = await _dio.post(
        '/api/quan-he-cu-tru/yeu-cau/get-by-id',
        data: {'requestId': requestId},
      );
      final data = response.data as Map<String, dynamic>;

      if (data['isOk'] == true) {
        return YeuCauCuTruModel.fromJson(data['result']);
      }

      throw AppException(ErrorParser.parseErrors(data['errors']));
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw AppException(_dioErrorMessage(e));
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 10. Upload file (multipart/form-data)
  // ────────────────────────────────────────────────────────────────────────────

  Future<List<UploadedFileModel>> uploadMedia({
    required List<File> files,
    String targetContainer = 'tai-lieu-cu-tru',
  }) async {
    try {
      final formData = FormData();
      formData.fields.add(MapEntry('targetContainer', targetContainer));

      for (final file in files) {
        formData.files.add(
          MapEntry(
            'files',
            await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            ),
          ),
        );
      }

      final response = await _dio.post('/api/upload-media', data: formData);
      final data = response.data as Map<String, dynamic>;

      if (data['isOk'] == true) {
        final list = data['result'] as List<dynamic>? ?? [];
        return list.map((e) => UploadedFileModel.fromJson(e)).toList();
      }

      throw AppException(ErrorParser.parseErrors(data['errors']));
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw AppException(_dioErrorMessage(e));
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 11. Tạo yêu cầu cư trú mới (POST)
  // ────────────────────────────────────────────────────────────────────────────

  Future<YeuCauCuTruModel> createYeuCau({
    required int canHoId,
    required int loaiYeuCauId,
    int? targetQuanHeCuTruId,
    String? firstName,
    String? lastName,
    int? gioiTinhId,
    DateTime? dob,
    String? cccd,
    String? phoneNumber,
    String? diaChi,
    int? loaiQuanHeId,
    String? noiDung,
    List<Map<String, dynamic>>? taiLieuCuTrus,
    bool isSubmit = false,
  }) async {
    try {
      final response = await _dio.post(
        '/api/quan-he-cu-tru/yeu-cau',
        data: {
          'canHoId': canHoId,
          'loaiYeuCauId': loaiYeuCauId,
          'targetQuanHeCuTruId': ?targetQuanHeCuTruId,
          'firstName': ?firstName,
          'lastName': ?lastName,
          'gioiTinhId': ?gioiTinhId,
          if (dob != null) 'dob': dob.toIso8601String(),
          'cccd': ?cccd,
          'phoneNumber': ?phoneNumber,
          'diaChi': ?diaChi,
          'loaiQuanHeId': ?loaiQuanHeId,
          'noiDung': ?noiDung,
          'taiLieuCuTrus': ?taiLieuCuTrus,
          'isSubmit': isSubmit,
        },
      );
      final data = response.data as Map<String, dynamic>;

      if (data['isOk'] == true) {
        return YeuCauCuTruModel.fromJson(data['result']);
      }

      throw AppException(ErrorParser.parseErrors(data['errors']));
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw AppException(_dioErrorMessage(e));
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 12. Cập nhật yêu cầu cư trú (PUT)
  // ────────────────────────────────────────────────────────────────────────────

  Future<YeuCauCuTruModel> updateYeuCau({
    required int id,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    DateTime? dob,
    int? gioiTinhId,
    String? cccd,
    String? diaChi,
    int? loaiQuanHeId,
    String? noiDung,
    List<Map<String, dynamic>>? taiLieuCuTrus,
    bool isSubmit = false,
    bool isWithdraw = false,
  }) async {
    try {
      final response = await _dio.put(
        '/api/quan-he-cu-tru/yeu-cau',
        data: {
          'id': id,
          'firstName': ?firstName,
          'lastName': ?lastName,
          'phoneNumber': ?phoneNumber,
          if (dob != null) 'dob': dob.toIso8601String(),
          'gioiTinhId': ?gioiTinhId,
          'cccd': ?cccd,
          'diaChi': ?diaChi,
          'loaiQuanHeId': ?loaiQuanHeId,
          'noiDung': ?noiDung,
          'taiLieuCuTrus': ?taiLieuCuTrus,
          'isSubmit': isSubmit,
          'isWithdraw': isWithdraw,
        },
      );
      final data = response.data as Map<String, dynamic>;

      if (data['isOk'] == true) {
        return YeuCauCuTruModel.fromJson(data['result']);
      }

      throw AppException(ErrorParser.parseErrors(data['errors']));
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw AppException(_dioErrorMessage(e));
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Helper: chuyển DioException thành message thân thiện
  // ────────────────────────────────────────────────────────────────────────────

  String _dioErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Kết nối hết thời gian. Vui lòng thử lại.';
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        if (status == 401) return 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.';
        if (status == 403) return 'Bạn không có quyền thực hiện thao tác này.';
        if (status == 404) return 'Không tìm thấy dữ liệu.';
        return 'Lỗi server ($status). Vui lòng thử lại.';
      default:
        return 'Không thể kết nối mạng. Kiểm tra lại kết nối của bạn.';
    }
  }
}

class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

class ErrorParser {
  static String parseErrors(dynamic errors) {
    if (errors == null) return 'Có lỗi xảy ra. Vui lòng thử lại.';

    if (errors is List) {
      final messages = errors
          .whereType<Map<String, dynamic>>()
          .map(
            (e) => e['description']?.toString() ?? e['code']?.toString() ?? '',
          )
          .where((s) => s.isNotEmpty)
          .toList();
      if (messages.isNotEmpty) return messages.join('\n');
    }

    return 'Có lỗi xảy ra. Vui lòng thử lại.';
  }
}
