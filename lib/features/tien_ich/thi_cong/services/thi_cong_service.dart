// lib/features/tien_ich/thi_cong/services/thi_cong_service.dart

import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';

import '../../../cu_tru/quan_he/services/cu_tru_service.dart';

import '../models/thi_cong_model.dart';

class YeuCauThiCongService {
  YeuCauThiCongService._();
  static final YeuCauThiCongService instance = YeuCauThiCongService._();

  static final _client = ApiClient.instance;

  // ── Cư trú (delegate) ─────────────────────────────────────────────────────

  Future<List<QuanHeCuTruModel>> getCanHoList() =>
      CuTruService.instance.getQuanHeCuTruList();

  // ── 1. Catalog ────────────────────────────────────────────────────────────

  Future<List<SelectorItem>> getTrangThaiThiCongList() async {
    final res = await _client.post(
      '/api/catalog/trang-thai-thi-cong-for-selector',
    );
    return res.list(SelectorItem.fromJson);
  }

  // ── 2. Danh sách (phân trang + lọc) ──────────────────────────────────────

  Future<PagedResult<YeuCauThiCongListItem>> getList({
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
    final res = await _client.post(
      '/api/yeu-cau-thi-cong/get-list',
      body: {
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
      },
    );
    return res.pagedResult(YeuCauThiCongListItem.fromJson);
  }

  // ── 3. Chi tiết ───────────────────────────────────────────────────────────

  Future<YeuCauThiCongDetail> getById(int id) async {
    final res = await _client.post(
      '/api/yeu-cau-thi-cong/get-by-id',
      body: {'id': id},
    );
    return res.item(YeuCauThiCongDetail.fromJson);
  }

  // ── 4. Tạo mới ────────────────────────────────────────────────────────────

  Future<YeuCauThiCongListItem> create({
    required int canHoId,
    required String hangMucThiCong,
    required DateTime duKienBatDau,
    required DateTime duKienKetThuc,
    required String noiDung,
    required String tenDonViThiCong,
    required String nguoiDaiDien,
    required String soDienThoaiDaiDien,
    required List<NhanSuThiCong> danhSachNhanSu,
    required List<int> danhSachTepIds,
    required bool isSubmit,
  }) async {
    final res = await _client.post(
      '/api/yeu-cau-thi-cong',
      body: {
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
      },
    );
    return res.item(YeuCauThiCongListItem.fromJson);
  }

  // ── 5. Cập nhật ───────────────────────────────────────────────────────────

  Future<YeuCauThiCongListItem> update({
    required int id,
    required String hangMucThiCong,
    required DateTime duKienBatDau,
    required DateTime duKienKetThuc,
    required String noiDung,
    required String tenDonViThiCong,
    required String nguoiDaiDien,
    required String soDienThoaiDaiDien,
    required List<NhanSuThiCong> danhSachNhanSu,
    required List<int> danhSachTepIds,
    required bool isSubmit,
    bool isWithdraw = false,
  }) async {
    final res = await _client.put(
      '/api/yeu-cau-thi-cong',
      body: {
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
      },
    );
    return res.item(YeuCauThiCongListItem.fromJson);
  }

  // ── 6. Thu hồi ────────────────────────────────────────────────────────────

  Future<YeuCauThiCongListItem> withdraw(YeuCauThiCongDetail detail) => update(
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

  // ── 7. Upload file ────────────────────────────────────────────────────────

  Future<List<UploadedFile>> uploadFiles({
    required List<File> files,
    String targetContainer = 'tai-lieu-nhan-vien',
  }) async {
    final formData = FormData()
      ..fields.add(MapEntry('targetContainer', targetContainer));
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
    final res = await _client.postForm('/api/upload-media', formData);
    return res.list(UploadedFile.fromJson);
  }
}
