// // lib/features/dich_vu/services/dich_vu_service.dart

// import 'package:dio/dio.dart';

// import '../../../core/network/api_client.dart';
// import '../../../core/errors/errors.dart';

// import '../models/selector_item.dart';
// import '../models/dich_vu_model.dart';
// import '../models/khung_gio_model.dart';

// class DichVuService {
//   final Dio _dio = ApiClient.instance.dio;

//   // ── Helper gọi POST ───────────────────────────────────────────────────────

//   Future<Map<String, dynamic>> _post(
//     String path, {
//     Map<String, dynamic>? body,
//   }) async {
//     try {
//       final response = await _dio.post<Map<String, dynamic>>(
//         path,
//         data: body ?? {},
//       );

//       final data = response.data;

//       if (data == null) {
//         throw AppException(
//           'Không nhận được dữ liệu từ server',
//           type: ErrorType.server,
//         );
//       }

//       if (data['isOk'] != true) {
//         throw ErrorParser.parse(data, statusCode: response.statusCode);
//       }

//       return data;
//     } on AppException {
//       rethrow;
//     } on DioException catch (e) {
//       throw ErrorParser.parse(
//         e.response?.data,
//         statusCode: e.response?.statusCode,
//       );
//     } catch (e) {
//       throw AppException('Có lỗi không xác định: $e', type: ErrorType.unknown);
//     }
//   }

//   // ── CATALOG APIs ──────────────────────────────────────────────────────────

//   /// Lấy danh sách loại dịch vụ (Điện, Nước, ...)
//   Future<List<SelectorItem>> getLoaiDichVu() async {
//     final json = await _post('/api/catalog/loai-dich-vu-for-selector');
//     final list = json['result'] as List<dynamic>;
//     return list
//         .map((e) => SelectorItem.fromJson(e as Map<String, dynamic>))
//         .toList();
//   }

//   /// Lấy danh sách trạng thái dịch vụ
//   Future<List<SelectorItem>> getTrangThaiDichVu() async {
//     final json = await _post('/api/catalog/trang-thai-dich-vu-for-selector');
//     final list = json['result'] as List<dynamic>;
//     return list
//         .map((e) => SelectorItem.fromJson(e as Map<String, dynamic>))
//         .toList();
//   }

//   /// Lấy danh sách loại định giá
//   Future<List<SelectorItem>> getLoaiDinhGia() async {
//     final json = await _post('/api/catalog/loai-dinh-gia-for-selector');
//     final list = json['result'] as List<dynamic>;
//     return list
//         .map((e) => SelectorItem.fromJson(e as Map<String, dynamic>))
//         .toList();
//   }

//   /// Lấy danh sách ngày trong tuần
//   Future<List<SelectorItem>> getNgayTrongTuan() async {
//     final json = await _post('/api/catalog/ngay-trong-tuan-for-selector');
//     final list = json['result'] as List<dynamic>;
//     return list
//         .map((e) => SelectorItem.fromJson(e as Map<String, dynamic>))
//         .toList();
//   }

//   // ── DICH VU APIs ──────────────────────────────────────────────────────────

//   /// Lấy danh sách dịch vụ có filter + phân trang
//   Future<PagedResult<DichVuItem>> getDichVuList({
//     int? loaiDichVuId,
//     int? trangThaiDichVuId,
//     bool? isBatBuoc,
//     String? keyword,
//     int pageNumber = 1,
//     int pageSize = 10,
//   }) async {
//     final json = await _post(
//       '/api/dich-vu/get-list',
//       body: {
//         'loaiDichVuId': ?loaiDichVuId,
//         'trangThaiDichVuId': ?trangThaiDichVuId,
//         'isBatBuoc': ?isBatBuoc,
//         if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
//         'pageNumber': pageNumber,
//         'pageSize': pageSize,
//       },
//     );

//     final result = json['result'] as Map<String, dynamic>;
//     final items = (result['items'] as List<dynamic>)
//         .map((e) => DichVuItem.fromJson(e as Map<String, dynamic>))
//         .toList();
//     final paging = PagingInfo.fromJson(
//       result['pagingInfo'] as Map<String, dynamic>,
//     );

//     return PagedResult(items: items, pagingInfo: paging);
//   }

//   /// Lấy chi tiết 1 dịch vụ
//   Future<DichVuDetail> getDichVuById(int id) async {
//     final json = await _post('/api/dich-vu/get-by-id', body: {'id': id});
//     return DichVuDetail.fromJson(json['result'] as Map<String, dynamic>);
//   }

//   // ── KHUNG GIO APIs ────────────────────────────────────────────────────────

//   /// Lấy danh sách khung giờ của 1 dịch vụ
//   Future<PagedResult<KhungGioItem>> getKhungGioList({
//     int? dichVuId,
//     String? keyword,
//     bool? isActive,
//     int pageNumber = 1,
//     int pageSize = 20,
//   }) async {
//     final json = await _post(
//       '/api/dich-vu/khung-gio/get-list',
//       body: {
//         'dichVuId': ?dichVuId,
//         if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
//         'isActive': ?isActive,
//         'pageNumber': pageNumber,
//         'pageSize': pageSize,
//       },
//     );

//     final result = json['result'] as Map<String, dynamic>;
//     final items = (result['items'] as List<dynamic>)
//         .map((e) => KhungGioItem.fromJson(e as Map<String, dynamic>))
//         .toList();
//     final paging = PagingInfo.fromJson(
//       result['pagingInfo'] as Map<String, dynamic>,
//     );

//     return PagedResult(items: items, pagingInfo: paging);
//   }

//   // ── DANG KY ───────────────────────────────────────────────────────────────

//   /// Đăng ký dịch vụ cho căn hộ
//   /// Trả về id của bản ghi đăng ký (int)
//   Future<int> dangKyDichVu({
//     required int canHoId,
//     required int dichVuId,
//     required DateTime ngaySuDung,
//     int soLuong = 1,
//     int? khungGioId,
//   }) async {
//     final json = await _post(
//       '/api/dich-vu/dang-ky',
//       body: {
//         'canHoId': canHoId,
//         'dichVuId': dichVuId,
//         'ngaySuDung': ngaySuDung.toIso8601String(),
//         'soLuong': soLuong,
//         'khungGioId': ?khungGioId,
//       },
//     );

//     return json['result'] as int;
//   }
// }

// lib/features/dich_vu/services/dich_vu_service.dart

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/errors/errors.dart';

import '../../cu_tru/models/quan_he_cu_tru_model.dart';
import '../../cu_tru/services/cu_tru_service.dart';

import '../models/selector_item.dart';
import '../models/dich_vu_model.dart';
import '../models/khung_gio_model.dart';

class DichVuService {
  DichVuService._();

  static final DichVuService instance = DichVuService._();

  final Dio _dio = ApiClient.instance.dio;

  // ── Helper ────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> _post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: body ?? {},
      );
      final data = response.data;
      if (data == null) {
        throw AppException(
          'Không nhận được dữ liệu từ server',
          type: ErrorType.server,
        );
      }
      if (data['isOk'] != true) {
        throw ErrorParser.parse(data, statusCode: response.statusCode);
      }
      return data;
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw ErrorParser.parse(
        e.response?.data,
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw AppException('Có lỗi không xác định: $e', type: ErrorType.unknown);
    }
  }

  // ── CƯ TRÚ (delegate) ─────────────────────────────────────────────────────

  /// Lấy danh sách quan hệ cư trú → dùng để chọn căn hộ khi đăng ký.
  /// Delegate sang CuTruService để không duplicate logic.
  Future<List<QuanHeCuTruModel>> getCanHoList() =>
      CuTruService.instance.getQuanHeCuTruList();

  // ── CATALOG APIs ──────────────────────────────────────────────────────────

  Future<List<SelectorItem>> getLoaiDichVu() async {
    final json = await _post('/api/catalog/loai-dich-vu-for-selector');
    return (json['result'] as List<dynamic>)
        .map((e) => SelectorItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<SelectorItem>> getTrangThaiDichVu() async {
    final json = await _post('/api/catalog/trang-thai-dich-vu-for-selector');
    return (json['result'] as List<dynamic>)
        .map((e) => SelectorItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<SelectorItem>> getLoaiDinhGia() async {
    final json = await _post('/api/catalog/loai-dinh-gia-for-selector');
    return (json['result'] as List<dynamic>)
        .map((e) => SelectorItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<SelectorItem>> getNgayTrongTuan() async {
    final json = await _post('/api/catalog/ngay-trong-tuan-for-selector');
    return (json['result'] as List<dynamic>)
        .map((e) => SelectorItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── DICH VU APIs ──────────────────────────────────────────────────────────

  Future<PagedResult<DichVuItem>> getDichVuList({
    int? loaiDichVuId,
    int? trangThaiDichVuId,
    bool? isBatBuoc,
    String? keyword,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final json = await _post(
      '/api/dich-vu/get-list',
      body: {
        'loaiDichVuId': ?loaiDichVuId,
        'trangThaiDichVuId': ?trangThaiDichVuId,
        'isBatBuoc': ?isBatBuoc,
        if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      },
    );
    final result = json['result'] as Map<String, dynamic>;
    final items = (result['items'] as List<dynamic>)
        .map((e) => DichVuItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return PagedResult(
      items: items,
      pagingInfo: PagingInfo.fromJson(
        result['pagingInfo'] as Map<String, dynamic>,
      ),
    );
  }

  Future<DichVuDetail> getDichVuById(int id) async {
    final json = await _post('/api/dich-vu/get-by-id', body: {'id': id});
    return DichVuDetail.fromJson(json['result'] as Map<String, dynamic>);
  }

  // ── KHUNG GIO APIs ────────────────────────────────────────────────────────

  Future<PagedResult<KhungGioItem>> getKhungGioList({
    int? dichVuId,
    String? keyword,
    bool? isActive,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    final json = await _post(
      '/api/dich-vu/khung-gio/get-list',
      body: {
        'dichVuId': ?dichVuId,
        if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
        'isActive': ?isActive,
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      },
    );
    final result = json['result'] as Map<String, dynamic>;
    final items = (result['items'] as List<dynamic>)
        .map((e) => KhungGioItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return PagedResult(
      items: items,
      pagingInfo: PagingInfo.fromJson(
        result['pagingInfo'] as Map<String, dynamic>,
      ),
    );
  }

  // ── DANG KY ───────────────────────────────────────────────────────────────

  Future<int> dangKyDichVu({
    required int canHoId,
    required int dichVuId,
    required DateTime ngaySuDung,
    int soLuong = 1,
    int? khungGioId,
  }) async {
    final json = await _post(
      '/api/dich-vu/dang-ky',
      body: {
        'canHoId': canHoId,
        'dichVuId': dichVuId,
        'ngaySuDung': ngaySuDung.toIso8601String(),
        'soLuong': soLuong,
        'khungGioId': ?khungGioId,
      },
    );
    return json['result'] as int;
  }
}
