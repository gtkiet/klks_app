// lib/features/cu_tru/services/cu_tru_service.dart

import 'dart:io';
import 'package:dio/dio.dart';

import '../models/quan_he_cu_tru_model.dart';
import '../models/thanh_vien_cu_tru_model.dart';
import '../models/thong_tin_cu_dan_model.dart';
import '../models/yeu_cau_cu_tru_model.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/error_parser.dart';

class CuTruService {
  Dio get _dio => ApiClient.instance.dio;

  // ─── 1. Danh sach can ho cu tru ─────────────────────────────────────────────

  Future<List<QuanHeCuTruModel>> getQuanHeCuTruList() async {
    try {
      final response = await _dio.post('/api/cu-dan/quan-he-cu-tru');
      final data = response.data as Map<String, dynamic>;
      final list = data['result'] as List<dynamic>? ?? [];
      return list.map((e) => QuanHeCuTruModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ErrorParser.parse(
        e.response?.data,
        statusCode: e.response?.statusCode,
      );
    } catch (_) {
      throw AppException('Lỗi không xác định');
    }
  }

  // ─── 2. Thanh vien dang cu tru trong can ho ──────────────────────────────────

  Future<List<ThanhVienCuTruModel>> getThanhVienCuTru(int canHoId) async {
    try {
      final response = await _dio.post(
        '/api/cu-dan/thanh-vien-cu-tru',
        data: {'canHoId': canHoId},
      );
      final data = response.data as Map<String, dynamic>;
      final list = data['result'] as List<dynamic>? ?? [];
      return list.map((e) => ThanhVienCuTruModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ErrorParser.parse(
        e.response?.data,
        statusCode: e.response?.statusCode,
      );
    } catch (_) {
      throw AppException('Lỗi không xác định');
    }
  }

  // ─── 3. Thong tin chi tiet cu dan ────────────────────────────────────────────

  Future<ThongTinCuDanModel> getThongTinCuDan(int quanHeCuTruId) async {
    try {
      final response = await _dio.post(
        '/api/cu-dan/thong-tin',
        data: {'quanHeCuTruId': quanHeCuTruId},
      );
      final data = response.data as Map<String, dynamic>;
      return ThongTinCuDanModel.fromJson(data['result']);
    } on DioException catch (e) {
      throw ErrorParser.parse(
        e.response?.data,
        statusCode: e.response?.statusCode,
      );
    } catch (_) {
      throw AppException('Lỗi không xác định');
    }
  }

  // ─── 4. Catalog: Loai yeu cau (Them/Sua/Xoa) ────────────────────────────────

  Future<List<SelectorItemModel>> getLoaiYeuCauSelector() async {
    try {
      final response = await _dio.post(
        '/api/catalog/loai-yeu-cau-for-selector',
      );
      final data = response.data as Map<String, dynamic>;
      final list = data['result'] as List<dynamic>? ?? [];
      return list.map((e) => SelectorItemModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ErrorParser.parse(
        e.response?.data,
        statusCode: e.response?.statusCode,
      );
    } catch (_) {
      throw AppException('Lỗi không xác định');
    }
  }

  // ─── 5. Catalog: Trang thai yeu cau cu tru ──────────────────────────────────

  Future<List<SelectorItemModel>> getTrangThaiYeuCauSelector() async {
    try {
      final response = await _dio.post(
        '/api/catalog/trang-thai-yeu-cau-cu-tru-for-selector',
      );
      final data = response.data as Map<String, dynamic>;
      final list = data['result'] as List<dynamic>? ?? [];
      return list.map((e) => SelectorItemModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ErrorParser.parse(
        e.response?.data,
        statusCode: e.response?.statusCode,
      );
    } catch (_) {
      throw AppException('Lỗi không xác định');
    }
  }

  // ─── 6. Catalog: Gioi tinh ───────────────────────────────────────────────────

  Future<List<SelectorItemModel>> getGioiTinhSelector() async {
    try {
      final response = await _dio.post('/api/catalog/gioi-tinh-for-selector');
      final data = response.data as Map<String, dynamic>;
      final list = data['result'] as List<dynamic>? ?? [];
      return list.map((e) => SelectorItemModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ErrorParser.parse(
        e.response?.data,
        statusCode: e.response?.statusCode,
      );
    } catch (_) {
      throw AppException('Lỗi không xác định');
    }
  }

  // ─── 7. Catalog: Loai quan he cu tru ────────────────────────────────────────

  Future<List<SelectorItemModel>> getLoaiQuanHeCuTruSelector() async {
    try {
      final response = await _dio.post(
        '/api/catalog/loai-quan-he-cu-tru-for-selector',
      );
      final data = response.data as Map<String, dynamic>;
      final list = data['result'] as List<dynamic>? ?? [];
      return list.map((e) => SelectorItemModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ErrorParser.parse(
        e.response?.data,
        statusCode: e.response?.statusCode,
      );
    } catch (_) {
      throw AppException('Lỗi không xác định');
    }
  }

  // ─── 8. Danh sach yeu cau (co phan trang) ───────────────────────────────────

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
      return YeuCauCuTruListResult.fromJson(data['result']);
    } on DioException catch (e) {
      throw ErrorParser.parse(
        e.response?.data,
        statusCode: e.response?.statusCode,
      );
    } catch (_) {
      throw AppException('Lỗi không xác định');
    }
  }

  // ─── 9. Chi tiet yeu cau ─────────────────────────────────────────────────────

  Future<YeuCauCuTruModel> getYeuCauById(int requestId) async {
    try {
      final response = await _dio.post(
        '/api/quan-he-cu-tru/yeu-cau/get-by-id',
        data: {'requestId': requestId},
      );
      final data = response.data as Map<String, dynamic>;
      return YeuCauCuTruModel.fromJson(data['result']);
    } on DioException catch (e) {
      throw ErrorParser.parse(
        e.response?.data,
        statusCode: e.response?.statusCode,
      );
    } catch (_) {
      throw AppException('Lỗi không xác định');
    }
  }

  // ─── 10. Upload file (multipart) ─────────────────────────────────────────────

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
      final list = data['result'] as List<dynamic>? ?? [];
      return list.map((e) => UploadedFileModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ErrorParser.parse(
        e.response?.data,
        statusCode: e.response?.statusCode,
      );
    } catch (_) {
      throw AppException('Lỗi không xác định');
    }
  }

  // ─── 11. Tao yeu cau moi (POST) ──────────────────────────────────────────────
  //
  // FIX: taiLieuCuTrus chi gui khi co fileIds thuc su.
  // Chi gui cac field bat buoc, khong gui null/empty string de tranh 400.

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
    // FIX: Nhan thang List<TaiLieuCuTruRequest> thay vi Map de control chinh xac
    List<TaiLieuCuTruRequest>? taiLieuCuTrus,
    bool isSubmit = false,
  }) async {
    final body = <String, dynamic>{
      'canHoId': canHoId,
      'loaiYeuCauId': loaiYeuCauId,
      'isSubmit': isSubmit,
    };

    if (targetQuanHeCuTruId != null) {
      body['targetQuanHeCuTruId'] = targetQuanHeCuTruId;
    }
    if (firstName != null && firstName.isNotEmpty) {
      body['firstName'] = firstName;
    }
    if (lastName != null && lastName.isNotEmpty) {
      body['lastName'] = lastName;
    }
    if (gioiTinhId != null) body['gioiTinhId'] = gioiTinhId;
    if (dob != null) body['dob'] = dob.toIso8601String();
    if (cccd != null && cccd.isNotEmpty) body['cccd'] = cccd;
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      body['phoneNumber'] = phoneNumber;
    }
    if (diaChi != null && diaChi.isNotEmpty) body['diaChi'] = diaChi;
    if (loaiQuanHeId != null) body['loaiQuanHeId'] = loaiQuanHeId;
    if (noiDung != null && noiDung.isNotEmpty) body['noiDung'] = noiDung;

    // FIX: Chi gui taiLieuCuTrus khi co it nhat 1 item co fileIds
    if (taiLieuCuTrus != null && taiLieuCuTrus.isNotEmpty) {
      final validItems = taiLieuCuTrus
          .where((t) => t.fileIds.isNotEmpty)
          .map((t) => t.toJson())
          .toList();
      if (validItems.isNotEmpty) {
        body['taiLieuCuTrus'] = validItems;
      }
    }

    try {
      final response = await _dio.post(
        '/api/quan-he-cu-tru/yeu-cau',
        data: body,
      );
      final data = response.data as Map<String, dynamic>;
      return YeuCauCuTruModel.fromJson(data['result']);
    } on DioException catch (e) {
      throw ErrorParser.parse(
        e.response?.data,
        statusCode: e.response?.statusCode,
      );
    } catch (_) {
      throw AppException('Lỗi không xác định');
    }
  }

  // ─── 12. Cap nhat yeu cau (PUT) ──────────────────────────────────────────────

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
    List<TaiLieuCuTruRequest>? taiLieuCuTrus,
    bool isSubmit = false,
    bool isWithdraw = false,
  }) async {
    final body = <String, dynamic>{
      'id': id,
      'isSubmit': isSubmit,
      'isWithdraw': isWithdraw,
    };

    if (firstName != null && firstName.isNotEmpty) {
      body['firstName'] = firstName;
    }
    if (lastName != null && lastName.isNotEmpty) {
      body['lastName'] = lastName;
    }
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      body['phoneNumber'] = phoneNumber;
    }
    if (dob != null) body['dob'] = dob.toIso8601String();
    if (gioiTinhId != null) body['gioiTinhId'] = gioiTinhId;
    if (cccd != null && cccd.isNotEmpty) body['cccd'] = cccd;
    if (diaChi != null && diaChi.isNotEmpty) body['diaChi'] = diaChi;
    if (loaiQuanHeId != null) body['loaiQuanHeId'] = loaiQuanHeId;
    if (noiDung != null && noiDung.isNotEmpty) body['noiDung'] = noiDung;

    if (taiLieuCuTrus != null && taiLieuCuTrus.isNotEmpty) {
      final validItems = taiLieuCuTrus
          .where((t) => t.fileIds.isNotEmpty)
          .map((t) => t.toJson())
          .toList();
      if (validItems.isNotEmpty) {
        body['taiLieuCuTrus'] = validItems;
      }
    }

    try {
      final response = await _dio.put(
        '/api/quan-he-cu-tru/yeu-cau',
        data: body,
      );
      final data = response.data as Map<String, dynamic>;
      return YeuCauCuTruModel.fromJson(data['result']);
    } on DioException catch (e) {
      throw ErrorParser.parse(
        e.response?.data,
        statusCode: e.response?.statusCode,
      );
    } catch (_) {
      throw AppException('Lỗi không xác định');
    }
  }
}

// ─── TaiLieuCuTruRequest ──────────────────────────────────────────────────────
//
// Model rieng de build taiLieuCuTrus dung format, tranh gui null/empty string.
//
// Su dung:
//   TaiLieuCuTruRequest(fileIds: [1, 2, 3])
//   TaiLieuCuTruRequest(loaiGiayToId: 5, soGiayTo: 'ABC123', fileIds: [4])

class TaiLieuCuTruRequest {
  /// 0 = tao moi, != 0 = cap nhat tai lieu cu
  final int taiLieuCuTruId;

  /// Loai giay to (0 neu khong ro)
  final int? loaiGiayToId;

  /// So giay to (null neu khong co)
  final String? soGiayTo;

  /// Ngay phat hanh (null neu khong co)
  final DateTime? ngayPhatHanh;

  /// Danh sach fileId tu /api/upload-media — bat buoc phai co
  final List<int> fileIds;

  const TaiLieuCuTruRequest({
    this.taiLieuCuTruId = 0,
    this.loaiGiayToId,
    this.soGiayTo,
    this.ngayPhatHanh,
    required this.fileIds,
  });

  /// Chi serialize cac field co gia tri thuc su
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'fileIds': fileIds};
    // Chi them taiLieuCuTruId neu != 0 (update)
    if (taiLieuCuTruId != 0) {
      map['taiLieuCuTruId'] = taiLieuCuTruId;
    }
    // Chi them loaiGiayToId neu co va != 0
    if (loaiGiayToId != null && loaiGiayToId != 0) {
      map['loaiGiayToId'] = loaiGiayToId;
    }
    // Chi them soGiayTo neu co gia tri
    if (soGiayTo != null && soGiayTo!.isNotEmpty) {
      map['soGiayTo'] = soGiayTo;
    }
    // Chi them ngayPhatHanh neu co
    if (ngayPhatHanh != null) {
      map['ngayPhatHanh'] = ngayPhatHanh!.toIso8601String();
    }
    return map;
  }
}
