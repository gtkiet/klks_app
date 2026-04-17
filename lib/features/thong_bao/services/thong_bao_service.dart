// lib/features/thong_bao/services/thong_bao_service.dart

import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/thong_bao_model.dart';

class ServiceResult<T> {
  final T? data;
  final String? errorMessage;

  bool get isOk => errorMessage == null;

  const ServiceResult.success(this.data) : errorMessage = null;
  const ServiceResult.failure(this.errorMessage) : data = null;
}

class ThongBaoService {
  ThongBaoService._internal();
  static final ThongBaoService instance = ThongBaoService._internal();

  // Dùng ApiClient.instance.dio — đã có interceptor gắn Bearer token
  final Dio _dio = ApiClient.instance.dio;

  /// POST /api/thong-bao/get-list
  Future<ServiceResult<ThongBaoListResult>> getList({
    String keyword = '',
    int pageNumber = 0,
    int pageSize = 20,
    bool onlyUnread = false,
    String sortCol = 'createdAt',
    bool isAsc = false,
  }) async {
    try {
      final response = await _dio.post(
        '/api/thong-bao/get-list',
        data: {
          'keyword': keyword,
          'sortCol': sortCol,
          'isAsc': isAsc,
          'pageNumber': pageNumber,
          'pageSize': pageSize,
          'onlyUnread': onlyUnread,
        },
      );

      final body = response.data as Map<String, dynamic>;

      if (body['isOk'] != true) {
        final errors = body['errors'] as List<dynamic>? ?? [];
        final msg = errors.isNotEmpty
            ? (errors.first as Map<String, dynamic>)['description'] as String?
            : null;
        return ServiceResult.failure(msg ?? 'Lấy danh sách thông báo thất bại');
      }

      final result = ThongBaoListResult.fromJson(
        body['result'] as Map<String, dynamic>,
      );
      return ServiceResult.success(result);
    } on DioException catch (e) {
      return ServiceResult.failure(_parseDioError(e));
    } catch (e) {
      return ServiceResult.failure('Lỗi không xác định: $e');
    }
  }

  /// PUT /api/thong-bao/da-doc
  Future<ServiceResult<bool>> daDDoc({required int phanBoThongBaoId}) async {
    try {
      final response = await _dio.put(
        '/api/thong-bao/da-doc',
        data: {'phanBoThongBaoId': phanBoThongBaoId},
      );

      final body = response.data as Map<String, dynamic>;

      if (body['isOk'] != true) {
        final errors = body['errors'] as List<dynamic>? ?? [];
        final msg = errors.isNotEmpty
            ? (errors.first as Map<String, dynamic>)['description'] as String?
            : null;
        return ServiceResult.failure(msg ?? 'Đánh dấu đã đọc thất bại');
      }

      return const ServiceResult.success(true);
    } on DioException catch (e) {
      return ServiceResult.failure(_parseDioError(e));
    } catch (e) {
      return ServiceResult.failure('Lỗi không xác định: $e');
    }
  }

  String _parseDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Kết nối quá thời gian, vui lòng thử lại';
      default:
        break;
    }
    switch (e.response?.statusCode) {
      case 401:
        return 'Phiên đăng nhập hết hạn';
      case 403:
        return 'Bạn không có quyền thực hiện';
      case 500:
        return 'Lỗi máy chủ, vui lòng thử lại sau';
    }
    return e.message ?? 'Lỗi kết nối mạng';
  }
}
