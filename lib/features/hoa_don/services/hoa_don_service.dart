// lib/features/hoa_don/services/hoa_don_service.dart

import '../../../core/network/api_client.dart';
import '../models/hoa_don_model.dart';

class HoaDonService {
  HoaDonService._();
  static final instance = HoaDonService._();

  static final _client = ApiClient.instance;

  // ── 1. Danh sách hóa đơn ─────────────────────────────────────────────────

  /// [trangThaiHoaDonId] 2=Chưa TT, 3=Đã TT, 4=Quá hạn, null=tất cả
  Future<HoaDonListResult> getList({
    required int canHoId,
    int? trangThaiHoaDonId,
    int? thang,
    int? nam,
    String? keyword,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final res = await _client.post(
      '/api/hoa-don/get-list',
      body: {
        'canHoId': canHoId,
        'trangThaiHoaDonId': ?trangThaiHoaDonId,
        'thang': ?thang,
        'nam': ?nam,
        if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
        'pageNumber': pageNumber,
        'pageSize': pageSize,
        'isAsc': false,
      },
    );
    return res.item(HoaDonListResult.fromJson);
  }

  // ── 2. Chi tiết hóa đơn ──────────────────────────────────────────────────

  Future<HoaDonDetail> getById(int id) async {
    final res = await _client.post('/api/hoa-don/get-by-id', body: {'id': id});
    return res.item(HoaDonDetail.fromJson);
  }

  // ── 3. Chi tiết cố định ───────────────────────────────────────────────────

  Future<ChiTietCoDinh> getChiTietCoDinh(int chiTietId) async {
    final res = await _client.post(
      '/api/hoa-don/get-chi-tiet-co-dinh',
      body: {'id': chiTietId},
    );
    return res.item(ChiTietCoDinh.fromJson);
  }

  // ── 4. Chi tiết lũy tiến ─────────────────────────────────────────────────

  Future<ChiTietLuyTien> getChiTietLuyTien(int chiTietId) async {
    final res = await _client.post(
      '/api/hoa-don/get-chi-tiet-luy-tien',
      body: {'id': chiTietId},
    );
    return res.item(ChiTietLuyTien.fromJson);
  }

  // ── 5. Chi tiết diện tích ─────────────────────────────────────────────────

  Future<ChiTietDienTich> getChiTietDienTich(int chiTietId) async {
    final res = await _client.post(
      '/api/hoa-don/get-chi-tiet-dien-tich',
      body: {'id': chiTietId},
    );
    return res.item(ChiTietDienTich.fromJson);
  }

  // ── 6. Chi tiết khung giờ ─────────────────────────────────────────────────

  Future<ChiTietKhungGio> getChiTietKhungGio(int chiTietId) async {
    final res = await _client.post(
      '/api/hoa-don/get-chi-tiet-khung-gio',
      body: {'id': chiTietId},
    );
    return res.item(ChiTietKhungGio.fromJson);
  }

  // ── 7. Tạo phiên thanh toán ───────────────────────────────────────────────

  /// [chiTietHoaDonIds] để trống [] → thanh toán toàn bộ hóa đơn.
  Future<PhienThanhToan> taoPhienThanhToan({
    required int hoaDonId,
    List<int> chiTietHoaDonIds = const [],
  }) async {
    final res = await _client.post(
      '/api/giao-dich-thanh-toan/tao-phien',
      body: {
        'hoaDonId': hoaDonId,
        'chiTietHoaDonIds': chiTietHoaDonIds,
      },
    );
    return res.item(PhienThanhToan.fromJson);
  }
}