// lib/features/hoa_don/services/hoa_don_service.dart

import 'package:dio/dio.dart';
import '../../../core/errors/errors.dart';
import '../../../core/network/api_client.dart';
import '../models/hoa_don_model.dart';

class HoaDonService {
  HoaDonService._();
  static final instance = HoaDonService._();

  // ─── HELPER ──────────────────────────────────────────────────────────────────

  /// Gọi POST, extract `.data` từ Dio Response, rồi unwrap business logic.
  ///
  /// Dio trả về `Response<dynamic>` — `.data` mới là body JSON đã decode.
  /// DioException được bắt ở đây để convert sang AppException nhất quán.
  Future<T> _post<T>(
    String path, {
    required Map<String, dynamic> body,
    required T Function(Map<String, dynamic>) fromResult,
  }) async {
    try {
      final response = await ApiClient.instance.dio.post<Map<String, dynamic>>(
        path,
        data: body,
      );

      final data = response.data;
      if (data == null) {
        throw AppException('Không có dữ liệu trả về', type: ErrorType.server);
      }

      return _unwrap(data, fromResult);
    } on DioException catch (e) {
      // ApiInterceptor thường đã handle 401, nhưng các lỗi khác vẫn qua đây
      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;

      // Nếu server trả về body JSON có errors[] → parse business error
      if (responseData is Map<String, dynamic>) {
        throw ErrorParser.parse(responseData, statusCode: statusCode);
      }

      // Network timeout / no internet / unknown
      throw AppException(
        _dioErrorMessage(e),
        type: e.type == DioExceptionType.connectionError ||
                e.type == DioExceptionType.connectionTimeout
            ? ErrorType.network
            : ErrorType.unknown,
        code: statusCode,
      );
    }
  }

  /// Unwrap business response: isOk == false → throw, result == null → throw.
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

  String _dioErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Kết nối quá thời gian, vui lòng thử lại';
      case DioExceptionType.connectionError:
        return 'Không có kết nối mạng';
      default:
        return e.message ?? 'Có lỗi xảy ra';
    }
  }

  // ─── 1. DANH SÁCH HÓA ĐƠN ────────────────────────────────────────────────────

  /// [trangThaiHoaDonId] 2=Chưa TT, 3=Đã TT, 4=Quá hạn, null=tất cả
  Future<HoaDonListResult> getList({
    required int canHoId,
    int? trangThaiHoaDonId,
    int? thang,
    int? nam,
    String? keyword,
    int pageNumber = 1,
    int pageSize = 10,
  }) {
    return _post(
      '/api/hoa-don/get-list',
      body: {
        'canHoId': canHoId,
        // Chỉ đưa vào body nếu có giá trị — tránh gửi null làm server filter sai
        'trangThaiHoaDonId': ?trangThaiHoaDonId,
        'thang': ?thang,
        'nam': ?nam,
        if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
        'pageNumber': pageNumber,
        'pageSize': pageSize,
        'isAsc': false,
      },
      fromResult: HoaDonListResult.fromJson,
    );
  }

  // ─── 2. CHI TIẾT HÓA ĐƠN ─────────────────────────────────────────────────────

  Future<HoaDonDetail> getById(int id) {
    return _post(
      '/api/hoa-don/get-by-id',
      body: {'id': id},
      fromResult: HoaDonDetail.fromJson,
    );
  }

  // ─── 3. CHI TIẾT CỐ ĐỊNH ──────────────────────────────────────────────────────

  Future<ChiTietCoDinh> getChiTietCoDinh(int chiTietId) {
    return _post(
      '/api/hoa-don/get-chi-tiet-co-dinh',
      body: {'id': chiTietId},
      fromResult: ChiTietCoDinh.fromJson,
    );
  }

  // ─── 4. CHI TIẾT LŨY TIẾN ────────────────────────────────────────────────────

  Future<ChiTietLuyTien> getChiTietLuyTien(int chiTietId) {
    return _post(
      '/api/hoa-don/get-chi-tiet-luy-tien',
      body: {'id': chiTietId},
      fromResult: ChiTietLuyTien.fromJson,
    );
  }

  // ─── 5. CHI TIẾT DIỆN TÍCH ───────────────────────────────────────────────────

  Future<ChiTietDienTich> getChiTietDienTich(int chiTietId) {
    return _post(
      '/api/hoa-don/get-chi-tiet-dien-tich',
      body: {'id': chiTietId},
      fromResult: ChiTietDienTich.fromJson,
    );
  }

  // ─── 6. CHI TIẾT KHUNG GIỜ ───────────────────────────────────────────────────

  Future<ChiTietKhungGio> getChiTietKhungGio(int chiTietId) {
    return _post(
      '/api/hoa-don/get-chi-tiet-khung-gio',
      body: {'id': chiTietId},
      fromResult: ChiTietKhungGio.fromJson,
    );
  }

  // ─── 7. TẠO PHIÊN THANH TOÁN ─────────────────────────────────────────────────

  /// [chiTietHoaDonIds] để trống [] → thanh toán toàn bộ hóa đơn.
  Future<PhienThanhToan> taoPhienThanhToan({
    required int hoaDonId,
    List<int> chiTietHoaDonIds = const [],
  }) {
    return _post(
      '/api/giao-dich-thanh-toan/tao-phien',
      body: {
        'hoaDonId': hoaDonId,
        'chiTietHoaDonIds': chiTietHoaDonIds,
      },
      fromResult: PhienThanhToan.fromJson,
    );
  }
}