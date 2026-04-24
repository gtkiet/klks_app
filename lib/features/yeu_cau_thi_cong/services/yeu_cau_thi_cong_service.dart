// lib/features/yeu_cau_thi_cong/services/yeu_cau_thi_cong_service.dart

import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/errors/errors.dart';

import '../models/trang_thai_thi_cong_model.dart';
import '../models/yeu_cau_thi_cong_list_item_model.dart';
import '../models/yeu_cau_thi_cong_detail_model.dart';
import '../models/uploaded_file_model.dart';
import '../models/paging_info_model.dart';
import '../models/nhan_su_thi_cong_model.dart';

/// Kết quả phân trang cho danh sách yêu cầu thi công.
class YeuCauThiCongListResult {
  final List<YeuCauThiCongListItemModel> items;
  final PagingInfoModel pagingInfo;

  const YeuCauThiCongListResult({
    required this.items,
    required this.pagingInfo,
  });
}

class YeuCauThiCongService {
  YeuCauThiCongService._();
  static final YeuCauThiCongService instance = YeuCauThiCongService._();

  Dio get _dio => ApiClient.instance.dio;

  // ── 1. Danh sách trạng thái thi công (catalog) ──────────────────────────

  Future<List<TrangThaiThiCongModel>> getTrangThaiThiCongList() async {
    try {
      final response = await _dio.post(
        '/api/catalog/trang-thai-thi-cong-for-selector',
      );
      final data = response.data as Map<String, dynamic>;

      if (data['isOk'] != true) {
        throw ErrorParser.parse(data);
      }

      final list = data['result'] as List<dynamic>? ?? [];
      return list
          .map((e) => TrangThaiThiCongModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ErrorParser.parse(
        e.response?.data,
        statusCode: e.response?.statusCode,
      );
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException(
        'Lỗi không xác định khi tải trạng thái thi công',
      );
    }
  }

  // ── 2. Danh sách yêu cầu thi công (có phân trang + lọc) ─────────────────

  Future<YeuCauThiCongListResult> getList({
    int? canHoId,
    int? trangThaiId,
    int? trangThaiThiCongId,
    String? keyword,
    DateTime? ngayTaoTu,
    DateTime? ngayTaoDen,
    DateTime? batDauTu,
    DateTime? batDauDen,
    DateTime? ketThucTu,
    DateTime? ketThucDen,
    String sortCol = 'CreatedAt',
    bool isAsc = false,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final body = {
        'canHoId': ?canHoId,
        'trangThaiId': ?trangThaiId,
        'trangThaiThiCongId': ?trangThaiThiCongId,
        if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
        if (ngayTaoTu != null) 'ngayTaoTu': ngayTaoTu.toIso8601String(),
        if (ngayTaoDen != null) 'ngayTaoDen': ngayTaoDen.toIso8601String(),
        if (batDauTu != null) 'batDauTu': batDauTu.toIso8601String(),
        if (batDauDen != null) 'batDauDen': batDauDen.toIso8601String(),
        if (ketThucTu != null) 'ketThucTu': ketThucTu.toIso8601String(),
        if (ketThucDen != null) 'ketThucDen': ketThucDen.toIso8601String(),
        'sortCol': sortCol,
        'isAsc': isAsc,
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      };

      final response = await _dio.post(
        '/api/yeu-cau-thi-cong/get-list',
        data: body,
      );
      final data = response.data as Map<String, dynamic>;

      if (data['isOk'] != true) {
        throw ErrorParser.parse(data);
      }

      final result = data['result'] as Map<String, dynamic>;
      final items = (result['items'] as List<dynamic>? ?? [])
          .map(
            (e) =>
                YeuCauThiCongListItemModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
      final paging = PagingInfoModel.fromJson(
        result['pagingInfo'] as Map<String, dynamic>? ?? {},
      );

      return YeuCauThiCongListResult(items: items, pagingInfo: paging);
    } on DioException catch (e) {
      throw ErrorParser.parse(
        e.response?.data,
        statusCode: e.response?.statusCode,
      );
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException('Lỗi không xác định khi tải danh sách yêu cầu');
    }
  }

  // ── 3. Chi tiết yêu cầu thi công ─────────────────────────────────────────

  Future<YeuCauThiCongDetailModel> getById(int id) async {
    try {
      final response = await _dio.post(
        '/api/yeu-cau-thi-cong/get-by-id',
        data: {'id': id},
      );
      final data = response.data as Map<String, dynamic>;

      if (data['isOk'] != true) {
        throw ErrorParser.parse(data);
      }

      return YeuCauThiCongDetailModel.fromJson(
        data['result'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ErrorParser.parse(
        e.response?.data,
        statusCode: e.response?.statusCode,
      );
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException('Lỗi không xác định khi tải chi tiết yêu cầu');
    }
  }

  // ── 4. Tạo mới yêu cầu thi công ──────────────────────────────────────────

  Future<YeuCauThiCongListItemModel> create({
    required int canHoId,
    required String hangMucThiCong,
    required DateTime duKienBatDau,
    required DateTime duKienKetThuc,
    required String noiDung,
    required String tenDonViThiCong,
    required String nguoiDaiDien,
    required String soDienThoaiDaiDien,
    required List<NhanSuThiCongModel> danhSachNhanSu,
    required List<int> danhSachTepIds,
    required bool isSubmit,
  }) async {
    try {
      final body = {
        'canHoId': canHoId,
        'hangMucThiCong': hangMucThiCong,
        'duKienBatDau': duKienBatDau.toIso8601String(),
        'duKienKetThuc': duKienKetThuc.toIso8601String(),
        'noiDung': noiDung,
        'tenDonViThiCong': tenDonViThiCong,
        'nguoiDaiDien': nguoiDaiDien,
        'soDienThoaiDaiDien': soDienThoaiDaiDien,
        'danhSachNhanSu': danhSachNhanSu.map((e) => e.toJson()).toList(),
        'danhSachTepIds': danhSachTepIds,
        'isSubmit': isSubmit,
      };

      final response = await _dio.post('/api/yeu-cau-thi-cong', data: body);
      final data = response.data as Map<String, dynamic>;

      if (data['isOk'] != true) {
        throw ErrorParser.parse(data);
      }

      return YeuCauThiCongListItemModel.fromJson(
        data['result'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ErrorParser.parse(
        e.response?.data,
        statusCode: e.response?.statusCode,
      );
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException('Lỗi không xác định khi tạo yêu cầu');
    }
  }

  // ── 5. Cập nhật yêu cầu thi công ─────────────────────────────────────────
  // Dành cho cư dân: sửa bản nháp (Saved) hoặc cập nhật theo BQL (Returned)
  // QUAN TRỌNG: luôn gửi toàn bộ dữ liệu cũ, không chỉ phần thay đổi

  Future<YeuCauThiCongListItemModel> update({
    required int id,
    required String hangMucThiCong,
    required DateTime duKienBatDau,
    required DateTime duKienKetThuc,
    required String noiDung,
    required String tenDonViThiCong,
    required String nguoiDaiDien,
    required String soDienThoaiDaiDien,
    required List<NhanSuThiCongModel> danhSachNhanSu,
    required List<int> danhSachTepIds,
    required bool isSubmit,
    bool isWithdraw = false,
  }) async {
    try {
      final body = {
        'id': id,
        'hangMucThiCong': hangMucThiCong,
        'duKienBatDau': duKienBatDau.toIso8601String(),
        'duKienKetThuc': duKienKetThuc.toIso8601String(),
        'noiDung': noiDung,
        'tenDonViThiCong': tenDonViThiCong,
        'nguoiDaiDien': nguoiDaiDien,
        'soDienThoaiDaiDien': soDienThoaiDaiDien,
        'danhSachNhanSu': danhSachNhanSu.map((e) => e.toJson()).toList(),
        'danhSachTepIds': danhSachTepIds,
        'isSubmit': isSubmit,
        'isWithdraw': isWithdraw,
      };

      final response = await _dio.put('/api/yeu-cau-thi-cong', data: body);
      final data = response.data as Map<String, dynamic>;

      if (data['isOk'] != true) {
        throw ErrorParser.parse(data);
      }

      return YeuCauThiCongListItemModel.fromJson(
        data['result'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ErrorParser.parse(
        e.response?.data,
        statusCode: e.response?.statusCode,
      );
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException('Lỗi không xác định khi cập nhật yêu cầu');
    }
  }

  // ── 6. Thu hồi yêu cầu ───────────────────────────────────────────────────
  // Gọi PUT với isWithdraw = true, isSubmit = false
  // Gửi kèm toàn bộ dữ liệu hiện tại của yêu cầu

  Future<YeuCauThiCongListItemModel> withdraw(
    YeuCauThiCongDetailModel detail,
  ) async {
    return update(
      id: detail.id,
      hangMucThiCong: detail.hangMucThiCong,
      duKienBatDau: detail.duKienBatDau ?? DateTime.now(),
      duKienKetThuc: detail.duKienKetThuc ?? DateTime.now(),
      noiDung: detail.noiDung,
      tenDonViThiCong: detail.tenDonViThiCong,
      nguoiDaiDien: detail.nguoiDaiDien,
      soDienThoaiDaiDien: detail.soDienThoaiDaiDien,
      danhSachNhanSu: detail.nhanSuThiCongs,
      danhSachTepIds: detail.danhSachTep.map((e) => e.id).toList(),
      isSubmit: false,
      isWithdraw: true,
    );
  }

  // ── 7. Upload file ────────────────────────────────────────────────────────

  Future<List<UploadedFileModel>> uploadFiles({
    required List<File> files,
    String targetContainer = 'tai-lieu-nhan-vien',
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

      if (data['isOk'] != true) {
        throw ErrorParser.parse(data);
      }

      final list = data['result'] as List<dynamic>? ?? [];
      return list
          .map((e) => UploadedFileModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ErrorParser.parse(
        e.response?.data,
        statusCode: e.response?.statusCode,
      );
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException('Lỗi không xác định khi upload file');
    }
  }
}
