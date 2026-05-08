// lib/features/hoa_don/services/hoa_don_service.dart

import '../../../core/errors/errors.dart';
import '../../../core/network/api_client.dart';
import '../models/hoa_don_model.dart';

class HoaDonService {
  HoaDonService._();
  static final instance = HoaDonService._();

  // ─── HELPER ─────────────────────────────────────────────────────────────────

  /// Unwrap response: nếu isOk == false hoặc có errors → throw AppException.
  T _unwrap<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromResult,
  ) {
    final isOk = json['isOk'] as bool? ?? false;
    if (!isOk) {
      throw ErrorParser.parse(json);
    }
    final result = json['result'];
    if (result == null) {
      throw AppException('Không có dữ liệu trả về', type: ErrorType.server);
    }
    return fromResult(result as Map<String, dynamic>);
  }

  // ─── 1. DANH SÁCH HÓA ĐƠN ───────────────────────────────────────────────────

  /// Lấy danh sách hóa đơn của một căn hộ.
  ///
  /// [canHoId]          – ID căn hộ (bắt buộc với cư dân)
  /// [trangThaiHoaDonId]– 2=Chưa thanh toán, 3=Đã thanh toán, 4=Quá hạn...
  /// [pageNumber]       – trang hiện tại (bắt đầu từ 1)
  Future<HoaDonListResult> getList({
    required int canHoId,
    int? trangThaiHoaDonId,
    int? thang,
    int? nam,
    String? keyword,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final body = <String, dynamic>{
      'canHoId': canHoId,
      'trangThaiHoaDonId': ?trangThaiHoaDonId,
      'thang': ?thang,
      'nam': ?nam,
      if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
      'pageNumber': pageNumber,
      'pageSize': pageSize,
      'isAsc': false,
    };

    final json = await ApiClient.instance.dio.post(
      '/api/hoa-don/get-list',
      data: body,
    );

    return _unwrap(json as Map<String, dynamic>, HoaDonListResult.fromJson);
  }

  // ─── 2. CHI TIẾT HÓA ĐƠN ────────────────────────────────────────────────────

  Future<HoaDonDetail> getById(int id) async {
    final json = await ApiClient.instance.dio.post(
      '/api/hoa-don/get-by-id',
      data: {'id': id},
    );
    return _unwrap(json as Map<String, dynamic>, HoaDonDetail.fromJson);
  }

  // ─── 3. CHI TIẾT CỐ ĐỊNH ─────────────────────────────────────────────────────

  Future<ChiTietCoDinh> getChiTietCoDinh(int chiTietId) async {
    final json = await ApiClient.instance.dio.post(
      '/api/hoa-don/get-chi-tiet-co-dinh',
      data: {'id': chiTietId},
    );
    return _unwrap(json as Map<String, dynamic>, ChiTietCoDinh.fromJson);
  }

  // ─── 4. CHI TIẾT LŨY TIẾN ────────────────────────────────────────────────────

  Future<ChiTietLuyTien> getChiTietLuyTien(int chiTietId) async {
    final json = await ApiClient.instance.dio.post(
      '/api/hoa-don/get-chi-tiet-luy-tien',
      data: {'id': chiTietId},
    );
    return _unwrap(json as Map<String, dynamic>, ChiTietLuyTien.fromJson);
  }

  // ─── 5. CHI TIẾT DIỆN TÍCH ───────────────────────────────────────────────────

  Future<ChiTietDienTich> getChiTietDienTich(int chiTietId) async {
    final json = await ApiClient.instance.dio.post(
      '/api/hoa-don/get-chi-tiet-dien-tich',
      data: {'id': chiTietId},
    );
    return _unwrap(json as Map<String, dynamic>, ChiTietDienTich.fromJson);
  }

  // ─── 6. CHI TIẾT KHUNG GIỜ ───────────────────────────────────────────────────

  Future<ChiTietKhungGio> getChiTietKhungGio(int chiTietId) async {
    final json = await ApiClient.instance.dio.post(
      '/api/hoa-don/get-chi-tiet-khung-gio',
      data: {'id': chiTietId},
    );
    return _unwrap(json as Map<String, dynamic>, ChiTietKhungGio.fromJson);
  }

  // ─── 7. TẠO PHIÊN THANH TOÁN ─────────────────────────────────────────────────

  /// Tạo phiên thanh toán online, trả về mã QR VietQR.
  ///
  /// [chiTietHoaDonIds] – để trống [] để thanh toán toàn bộ hóa đơn.
  Future<PhienThanhToan> taoPhienThanhToan({
    required int hoaDonId,
    List<int> chiTietHoaDonIds = const [],
  }) async {
    final json = await ApiClient.instance.dio.post(
      '/api/giao-dich-thanh-toan/tao-phien',
      data: {
        'hoaDonId': hoaDonId,
        'chiTietHoaDonIds': chiTietHoaDonIds,
      },
    );
    return _unwrap(json as Map<String, dynamic>, PhienThanhToan.fromJson);
  }
}