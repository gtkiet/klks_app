// lib/features/tien_ich/dich_vu/services/dich_vu_service.dart

import 'package:klks_app/features/shared/services/shared_services.dart';

import '../../../../core/network/api_client.dart';

import '../../../cu_tru/quan_he/services/cu_tru_service.dart';

import '../models/dich_vu_model.dart';

class DichVuService {
  DichVuService._();
  static final DichVuService instance = DichVuService._();

  static final _client = ApiClient.instance;

  // ── Cư trú (delegate) ─────────────────────────────────────────────────────

  Future<List<QuanHeCuTruModel>> getCanHoList() =>
      CuTruService.instance.getQuanHeCuTruList();

  final _selector = SelectorService.instance;

  // ── Catalog ───────────────────────────────────────────────────────────────
  Future<List<SelectorItem>> getLoaiDichVu() => _selector.getLoaiDichVu();

  Future<List<SelectorItem>> getTrangThaiDichVu() =>
      _selector.getTrangThaiDichVu();

  Future<List<SelectorItem>> getLoaiDinhGia() => _selector.getLoaiDinhGia();

  Future<List<SelectorItem>> getTrangThaiDangKy() =>
      _selector.getTrangThaiDangKy();

  Future<List<SelectorItem>> getNgayTrongTuan() => _selector.getNgayTrongTuan();

  // ── Dịch vụ ───────────────────────────────────────────────────────────────

  Future<PagedResult<DichVuItem>> getDichVuList({
    int loaiDichVuId = 3,
    int trangThaiDichVuId = 1,
    bool isBatBuoc = false,
    String? keyword,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final res = await _client.post(
      '/api/dich-vu/get-list',
      body: {
        'loaiDichVuId': loaiDichVuId,
        'trangThaiDichVuId': trangThaiDichVuId,
        'isBatBuoc': isBatBuoc,
        if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      },
    );
    return res.pagedResult(DichVuItem.fromJson);
  }

  Future<DichVuDetail> getDichVuById(int id) async {
    final res = await _client.post('/api/dich-vu/get-by-id', body: {'id': id});
    return res.item(DichVuDetail.fromJson);
  }

  // ── Khung giờ ─────────────────────────────────────────────────────────────

  Future<PagedResult<KhungGioItem>> getKhungGioList({
    int? dichVuId,
    String? keyword,
    bool? isActive,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    final res = await _client.post(
      '/api/dich-vu/khung-gio/get-list',
      body: {
        'dichVuId': dichVuId,
        if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
        'isActive': isActive,
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      },
    );
    return res.pagedResult(KhungGioItem.fromJson);
  }

  // ── Đăng ký ───────────────────────────────────────────────────────────────

  Future<PagedResult<DichVuDangKyItem>> getDanhSachDangKy(
    DichVuDangKyRequest request,
  ) async {
    final res = await _client.post(
      '/api/dich-vu/dang-ky/get-list',
      body: request.toJson(),
    );
    return res.pagedResult(DichVuDangKyItem.fromJson);
  }

  Future<int> dangKyDichVu({
    required int canHoId,
    required int dichVuId,
    required DateTime ngaySuDung,
    int soLuong = 1,
    int? khungGioId,
  }) async {
    final res = await _client.post(
      '/api/dich-vu/dang-ky',
      body: {
        'canHoId': canHoId,
        'dichVuId': dichVuId,
        'ngaySuDung': ngaySuDung.toIso8601String(),
        'soLuong': soLuong,
        'khungGioId': khungGioId,
      },
    );
    return res.raw<int>();
  }
}
