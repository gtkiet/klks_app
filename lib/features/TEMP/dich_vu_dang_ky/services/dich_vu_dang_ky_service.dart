// // lib/features/dich_vu_dang_ky/services/dich_vu_dang_ky_service.dart

// import 'package:dio/dio.dart';

// import '../../../core/network/api_client.dart';
// import '../../../core/errors/errors.dart';
// // import '../../dich_vu/models/dich_vu_model.dart' show PagingInfo, PagedResult;
// import '../../dich_vu/models/selector_item.dart';
// import '../../dich_vu/services/dich_vu_service.dart'; // tái dùng catalog

// import '../models/dich_vu_dang_ky_model.dart';
// import '../models/dich_vu_dang_ky_request.dart';

// class DichVuDangKyService {
//   DichVuDangKyService._();

//   static final DichVuDangKyService instance = DichVuDangKyService._();

//   final Dio _dio = ApiClient.instance.dio;

//   // ── Helper (copy pattern từ DichVuService) ────────────────────────────────

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

//   // ── CATALOG (delegate sang DichVuService, không duplicate) ────────────────

//   /// Lấy danh sách loại dịch vụ cho dropdown filter
//   Future<List<SelectorItem>> getLoaiDichVu() =>
//       DichVuService.instance.getLoaiDichVu();

//   // ── ĐĂNG KÝ APIs ──────────────────────────────────────────────────────────

//   /// Lấy danh sách dịch vụ đã đăng ký của cư dân.
//   /// NguoiDungId được ApiClient tự inject qua token.
//   Future<PagedResult<DichVuDangKyItem>> getDanhSachDangKy(
//     DichVuDangKyRequest request,
//   ) async {
//     final json = await _post(
//       '/api/dich-vu/dang-ky/get-list',
//       body: request.toJson(),
//     );

//     final result = json['result'] as Map<String, dynamic>;
//     final items = (result['items'] as List<dynamic>)
//         .map((e) => DichVuDangKyItem.fromJson(e as Map<String, dynamic>))
//         .toList();

//     return PagedResult(
//       items: items,
//       pagingInfo: PagingInfo.fromJson(
//         result['pagingInfo'] as Map<String, dynamic>,
//       ),
//     );
//   }
// }