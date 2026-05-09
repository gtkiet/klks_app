// lib/features/phan_anh/services/phan_anh_service.dart

import 'package:dio/dio.dart';
// import '../../../core/errors/errors.dart';
import '../../../core/network/api_client.dart';
import '../models/phan_anh_model.dart';

class PhanAnhService {
  final Dio _dio = ApiClient.instance.dio;

  // ─── 1. Lấy danh sách phản ánh (có filter + phân trang) ─────────────────

  Future<PagedResult<PhanAnhResponse>> getList({
    int? canHoId,
    int? trangThaiPhanAnhId,
    int? loaiPhanAnhId,
    int? nguoiXuLyId,
    String? keyword,
    DateTime? ngayTaoTu,
    DateTime? ngayTaoDen,
    String sortCol = 'CreatedAt',
    bool isAsc = false,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final body = <String, dynamic>{
        'canHoId': ?canHoId,
        'trangThaiPhanAnhId': ?trangThaiPhanAnhId,
        'loaiPhanAnhId': ?loaiPhanAnhId,
        'nguoiXuLyId': ?nguoiXuLyId,
        if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
        if (ngayTaoTu != null) 'ngayTaoTu': ngayTaoTu.toIso8601String(),
        if (ngayTaoDen != null) 'ngayTaoDen': ngayTaoDen.toIso8601String(),
        'sortCol': sortCol,
        'isAsc': isAsc,
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      };

      final response = await _dio.post<Map<String, dynamic>>(
        '/api/phan-anh/get-list',
        data: body,
      );

      final data = response.data!;
      _assertOk(data, response.statusCode);

      final result = data['result'] as Map<String, dynamic>;
      final items = (result['items'] as List<dynamic>)
          .map((e) => PhanAnhResponse.fromJson(e as Map<String, dynamic>))
          .toList();
      final paging =
          PagingInfo.fromJson(result['pagingInfo'] as Map<String, dynamic>);

      return PagedResult(items: items, pagingInfo: paging);
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw ErrorParser.parse(e.response?.data, statusCode: e.response?.statusCode);
    }
  }

  // ─── 2. Lấy chi tiết một phản ánh ───────────────────────────────────────

  Future<PhanAnhDetailResponse> getById(int id) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/phan-anh/get-by-id',
        data: {'id': id},
      );

      final data = response.data!;
      _assertOk(data, response.statusCode);

      return PhanAnhDetailResponse.fromJson(
          data['result'] as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw ErrorParser.parse(e.response?.data, statusCode: e.response?.statusCode);
    }
  }

  // ─── 3. Tạo phản ánh mới (Nháp hoặc Gửi ngay) ──────────────────────────

  Future<PhanAnhResponse> create({
    required int canHoId,
    required String tieuDe,
    required String noiDung,
    required int loaiPhanAnhId,
    List<int> danhSachTepIds = const [],
    bool isSubmit = false,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/phan-anh',
        data: {
          'canHoId': canHoId,
          'tieuDe': tieuDe,
          'noiDung': noiDung,
          'loaiPhanAnhId': loaiPhanAnhId,
          'danhSachTepIds': danhSachTepIds,
          'isSubmit': isSubmit,
        },
      );

      final data = response.data!;
      _assertOk(data, response.statusCode);

      return PhanAnhResponse.fromJson(data['result'] as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw ErrorParser.parse(e.response?.data, statusCode: e.response?.statusCode);
    }
  }

  // ─── 4. Chỉnh sửa / Thu hồi / Gửi nháp ─────────────────────────────────

  Future<PhanAnhResponse> update({
    required int id,
    required String tieuDe,
    required String noiDung,
    required int loaiPhanAnhId,
    List<int> danhSachTepIds = const [],
    bool isSubmit = false,
    bool isWithdraw = false,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/api/phan-anh',
        data: {
          'id': id,
          'tieuDe': tieuDe,
          'noiDung': noiDung,
          'loaiPhanAnhId': loaiPhanAnhId,
          'danhSachTepIds': danhSachTepIds,
          'isSubmit': isSubmit,
          'isWithdraw': isWithdraw,
        },
      );

      final data = response.data!;
      _assertOk(data, response.statusCode);

      return PhanAnhResponse.fromJson(data['result'] as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw ErrorParser.parse(e.response?.data, statusCode: e.response?.statusCode);
    }
  }

  // ─── 5. Thu hồi nhanh (shorthand của update) ────────────────────────────

  Future<PhanAnhResponse> withdraw(int id) => update(
        id: id,
        tieuDe: '',
        noiDung: '',
        loaiPhanAnhId: 0,
        isWithdraw: true,
      );

  // ─── 6. Gửi tin nhắn chat phản hồi ─────────────────────────────────────

  Future<PhanAnhResponse> submitTraLoi({
    required int phanAnhId,
    required String noiDung,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/phan-anh/submit-tra-loi',
        data: {
          'phanAnhId': phanAnhId,
          'noiDung': noiDung,
        },
      );

      final data = response.data!;
      _assertOk(data, response.statusCode);

      return PhanAnhResponse.fromJson(data['result'] as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw ErrorParser.parse(e.response?.data, statusCode: e.response?.statusCode);
    }
  }

  // ─── 7. Cư dân chấm điểm & đóng ticket ─────────────────────────────────

  Future<PhanAnhResponse> danhGia({
    required int phanAnhId,
    required int diemDanhGia,
    String nhanXetDanhGia = '',
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/api/phan-anh/danh-gia',
        data: {
          'phanAnhId': phanAnhId,
          'diemDanhGia': diemDanhGia,
          'nhanXetDanhGia': nhanXetDanhGia,
        },
      );

      final data = response.data!;
      _assertOk(data, response.statusCode);

      return PhanAnhResponse.fromJson(data['result'] as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw ErrorParser.parse(e.response?.data, statusCode: e.response?.statusCode);
    }
  }

  // ─── Helper ─────────────────────────────────────────────────────────────

  /// Throw [AppException] nếu `isOk == false`.
  void _assertOk(Map<String, dynamic> data, int? statusCode) {
    final isOk = data['isOk'] as bool? ?? false;
    if (!isOk) {
      throw ErrorParser.parse(data, statusCode: statusCode);
    }
  }
}