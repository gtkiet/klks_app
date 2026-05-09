// lib/features/tien_ich/dich_vu/services/dich_vu_service.dart

import '../../../../core/network/api_client.dart';

import '../../../cu_tru/quan_he/models/quan_he_cu_tru_model.dart';
import '../../../cu_tru/quan_he/services/cu_tru_service.dart';

import '../models/selector_item.dart';
import '../models/dich_vu_model.dart';
import '../models/khung_gio_model.dart';
import '../models/dang_ky_model.dart';

class DichVuService {
  DichVuService._();
  static final DichVuService instance = DichVuService._();

  static final _client = ApiClient.instance;

  // ── Cư trú (delegate) ─────────────────────────────────────────────────────

  Future<List<QuanHeCuTruModel>> getCanHoList() =>
      CuTruService.instance.getQuanHeCuTruList();

  // ── Catalog ───────────────────────────────────────────────────────────────

  Future<List<SelectorItem>> getLoaiDichVu() =>
      _fetchSelector('/api/catalog/loai-dich-vu-for-selector');

  Future<List<SelectorItem>> getTrangThaiDichVu() =>
      _fetchSelector('/api/catalog/trang-thai-dich-vu-for-selector');

  Future<List<SelectorItem>> getLoaiDinhGia() =>
      _fetchSelector('/api/catalog/loai-dinh-gia-for-selector');

  Future<List<SelectorItem>> getTrangThaiDangKy() =>
      _fetchSelector('/api/catalog/trang-thai-dang-ky-for-selector');

  Future<List<SelectorItem>> getNgayTrongTuan() =>
      _fetchSelector('/api/catalog/ngay-trong-tuan-for-selector');

  Future<List<SelectorItem>> _fetchSelector(String path) async {
    final res = await _client.post(path);
    return res.list(SelectorItem.fromJson);
  }

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