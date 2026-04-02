// lib/features/residence_request/services/residence_request_service.dart

import 'dart:io';
import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_parser.dart';

// import '../models/residence_models.dart';
import '../models/member.dart';
import '../models/residence_apartment.dart';
import '../models/residence_request.dart';
import '../models/selector_item.dart';
import '../models/upload_file_response.dart';

class ResidenceService {
  ResidenceService._();
  static final ResidenceService instance = ResidenceService._();

  final Dio _dio = ApiClient.instance.dio;

  // ── helpers ──────────────────────────────────────────────────────────────────

  void _assertOk(Map<String, dynamic> json) {
    final isOk = json['isOk'] as bool? ?? false;
    if (!isOk) {
      final errors = json['errors'] as List<dynamic>?;
      throw AppException(ErrorParser.parse(errors));
    }
  }

  // ── 0. Danh sách căn hộ cư trú của user ──────────────────────────────────────

  Future<List<ResidenceApartment>> getMyApartments() async {
    try {
      final res = await _dio.post('/api/cu-dan/quan-he-cu-tru');
      final body = res.data as Map<String, dynamic>;
      _assertOk(body);
      final items = body['result'] as List<dynamic>;
      return items
          .map((e) => ResidenceApartment.fromJson(e as Map<String, dynamic>))
          .toList();
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw AppException(e.message ?? 'Lỗi kết nối');
    }
  }

  // ── 1. Danh sách thành viên ───────────────────────────────────────────────────

  Future<List<Member>> getMembers({required int canHoId}) async {
    try {
      final res = await _dio.post(
        '/api/cu-dan/thanh-vien-cu-tru',
        data: {'canHoId': canHoId},
      );
      final body = res.data as Map<String, dynamic>;
      _assertOk(body);
      final items = body['result'] as List<dynamic>;
      return items
          .map((e) => Member.fromJson(e as Map<String, dynamic>))
          .toList();
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw AppException(e.message ?? 'Lỗi kết nối');
    }
  }

  // ── 2. Chi tiết thành viên ────────────────────────────────────────────────────

  Future<MemberDetail> getMemberDetail({required int quanHeCuTruId}) async {
    try {
      final res = await _dio.post(
        '/api/cu-dan/thong-tin',
        data: {'QuanHeCuTruId': quanHeCuTruId.toString()},
      );
      final body = res.data as Map<String, dynamic>;
      _assertOk(body);
      return MemberDetail.fromJson(body['result'] as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw AppException(e.message ?? 'Lỗi kết nối');
    }
  }

  // ── 3. Upload tài liệu ────────────────────────────────────────────────────────

  Future<UploadFileResponse> uploadFile({
    required File file,
    String targetContainer = 'tai-lieu-cu-tru',
  }) async {
    try {
      final formData = FormData.fromMap({
        'files': await MultipartFile.fromFile(file.path,
            filename: file.path.split('/').last),
        'targetContainer': targetContainer,
      });
      final res = await _dio.post('/api/upload-media', data: formData);
      final body = res.data;
      // API trả về object đơn (không wrap result/isOk)
      if (body is Map<String, dynamic>) {
        return UploadFileResponse.fromJson(body);
      }
      throw AppException('Upload thất bại');
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw AppException(e.message ?? 'Lỗi upload');
    }
  }

  // ── 4. Tạo yêu cầu ───────────────────────────────────────────────────────────

  Future<void> createRequest({
    required int canHoId,
    required int loaiYeuCauId,
    int? targetQuanHeCuTruId,
    String? noiDung,
    String? firstName,
    String? lastName,
    int? gioiTinhId,
    DateTime? dob,
    String? cccd,
    String? phoneNumber,
    String? diaChi,
    int? loaiQuanHeId,
    List<Map<String, dynamic>>? taiLieuCuTrus,
    bool isSubmit = false,
  }) async {
    try {
      final data = <String, dynamic>{
        'canHoId': canHoId,
        'loaiYeuCauId': loaiYeuCauId,
        'isSubmit': isSubmit,
        'targetQuanHeCuTruId': ?targetQuanHeCuTruId,
        'noiDung': ?noiDung,
        'firstName': ?firstName,
        'lastName': ?lastName,
        'gioiTinhId': ?gioiTinhId,
        if (dob != null) 'dob': dob.toIso8601String(),
        'cccd': ?cccd,
        'phoneNumber': ?phoneNumber,
        'diaChi': ?diaChi,
        'loaiQuanHeId': ?loaiQuanHeId,
        'taiLieuCuTrus': ?taiLieuCuTrus,
      };
      final res = await _dio.post('/api/quan-he-cu-tru/yeu-cau', data: data);
      final body = res.data as Map<String, dynamic>;
      _assertOk(body);
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw AppException(e.message ?? 'Lỗi kết nối');
    }
  }

  // ── 5. Danh sách yêu cầu ─────────────────────────────────────────────────────

  Future<ResidenceRequestListResult> getRequestList({
    required int pageNumber,
    required int pageSize,
    int? canHoId,
    int? loaiYeuCauId,
    int? trangThaiId,
  }) async {
    try {
      final data = <String, dynamic>{
        'pageNumber': pageNumber,
        'pageSize': pageSize,
        'canHoId': ?canHoId,
        'loaiYeuCauId': ?loaiYeuCauId,
        'trangThaiId': ?trangThaiId,
      };
      final res = await _dio.post(
        '/api/quan-he-cu-tru/yeu-cau/get-list',
        data: data,
      );
      final body = res.data as Map<String, dynamic>;
      _assertOk(body);
      return ResidenceRequestListResult.fromJson(
          body['result'] as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw AppException(e.message ?? 'Lỗi kết nối');
    }
  }

  // ── 6. Chi tiết yêu cầu ──────────────────────────────────────────────────────

  Future<ResidenceRequestDetail> getRequestDetail({
    required int requestId,
  }) async {
    try {
      final res = await _dio.post(
        '/api/quan-he-cu-tru/yeu-cau/get-by-id',
        data: {'requestId': requestId},
      );
      final body = res.data as Map<String, dynamic>;
      _assertOk(body);
      return ResidenceRequestDetail.fromJson(
          body['result'] as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw AppException(e.message ?? 'Lỗi kết nối');
    }
  }

  // ── 7. Update / Submit / Withdraw ────────────────────────────────────────────

  Future<ResidenceRequestDetail> updateRequest({
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
      final data = <String, dynamic>{
        'id': id,
        'isSubmit': isSubmit,
        'isWithdraw': isWithdraw,
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
      };
      final res =
          await _dio.put('/api/quan-he-cu-tru/yeu-cau', data: data);
      final body = res.data as Map<String, dynamic>;
      _assertOk(body);
      return ResidenceRequestDetail.fromJson(
          body['result'] as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw AppException(e.message ?? 'Lỗi kết nối');
    }
  }

  // ── Catalogs ──────────────────────────────────────────────────────────────────

  Future<List<SelectorItem>> getLoaiYeuCau() async =>
      _fetchSelector('/api/catalog/loai-yeu-cau-for-selector');

  Future<List<SelectorItem>> getGioiTinh() async =>
      _fetchSelector('/api/catalog/gioi-tinh-for-selector');

  Future<List<SelectorItem>> getLoaiQuanHe() async =>
      _fetchSelector('/api/catalog/loai-quan-he-cu-tru-for-selector');

  Future<List<SelectorItem>> getTrangThaiYeuCau() async =>
      _fetchSelector('/api/catalog/trang-thai-yeu-cau-cu-tru-for-selector');

  Future<List<SelectorItem>> _fetchSelector(String path) async {
    try {
      final res = await _dio.post(path);
      final body = res.data as Map<String, dynamic>;
      _assertOk(body);
      final items = body['result'] as List<dynamic>;
      return items
          .map((e) => SelectorItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw AppException(e.message ?? 'Lỗi kết nối');
    }
  }
}