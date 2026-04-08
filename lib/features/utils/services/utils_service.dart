// lib/core/services/utils_service.dart

import 'dart:io';
import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/errors/errors.dart';

import '../models/selector_item_model.dart';
import '../models/uploaded_file_model.dart';

class UtilsService {
  UtilsService._();
  static final UtilsService instance = UtilsService._();
  
  Dio get _dio => ApiClient.instance.dio;

  // =========================================================================
  // UPLOAD MEDIA
  // =========================================================================

  /// Upload nhiều file (multipart/form-data).
  ///
  /// [targetContainer]: bucket đích — ví dụ:
  ///   `'tai-lieu-cu-tru'` | `'tai-lieu-phuong-tien'`
  Future<List<UploadedFileModel>> uploadMedia({
    required List<File> files,
    required String targetContainer,
  }) async {
    try {
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

      final response = await _dio.post(
        '/api/upload-media',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      final data = response.data as Map<String, dynamic>;
      final list = data['result'] as List<dynamic>? ?? [];
      return list
          .map((e) => UploadedFileModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ErrorParser.parse(
        e.response?.data,
        statusCode: e.response?.statusCode,
      );
    } catch (_) {
      throw const AppException('Lỗi không xác định');
    }
  }

  // =========================================================================
  // CATALOG
  // =========================================================================

  Future<List<SelectorItemModel>> getGioiTinhSelector() =>
      _fetchSelector('/api/catalog/gioi-tinh-for-selector');
  //   {
  //   "result": [
  //     {
  //       "id": 1,
  //       "name": "Nam"
  //     },
  //     {
  //       "id": 2,
  //       "name": "Nữ"
  //     }
  //   ],
  //   "warningMessages": [],
  //   "errors": [],
  //   "isOk": true
  // }

  Future<List<SelectorItemModel>> getLoaiCanHoSelector() =>
      _fetchSelector('/api/catalog/loai-can-ho-for-selector');
  // {
  //   "result": [
  //     {
  //       "id": 1,
  //       "name": "Standard"
  //     },
  //     {
  //       "id": 2,
  //       "name": "Studio"
  //     },
  //     {
  //       "id": 3,
  //       "name": "Penthouse"
  //     },
  //     {
  //       "id": 4,
  //       "name": "Shophouse"
  //     }
  //   ],
  //   "warningMessages": [],
  //   "errors": [],
  //   "isOk": true
  // }

  Future<List<SelectorItemModel>> getLoaiPhuongTienSelector() =>
      _fetchSelector('/api/catalog/loai-phuong-tien-for-selector');
  // {
  //   "result": [
  //     {
  //       "id": 1,
  //       "name": "Xe máy"
  //     },
  //     {
  //       "id": 2,
  //       "name": "Ô tô"
  //     },
  //     {
  //       "id": 3,
  //       "name": "Xe đạp"
  //     },
  //     {
  //       "id": 4,
  //       "name": "Xe điện"
  //     }
  //   ],
  //   "warningMessages": [],
  //   "errors": [],
  //   "isOk": true
  // }

  Future<List<SelectorItemModel>> getLoaiQuanHeCuTruSelector() =>
      _fetchSelector('/api/catalog/loai-quan-he-cu-tru-for-selector');
  // {
  //   "result": [
  //     {
  //       "id": 1,
  //       "name": "Chủ hộ"
  //     },
  //     {
  //       "id": 2,
  //       "name": "Người thuê"
  //     },
  //     {
  //       "id": 3,
  //       "name": "Người ở cùng"
  //     },
  //     {
  //       "id": 4,
  //       "name": "Khác"
  //     }
  //   ],
  //   "warningMessages": [],
  //   "errors": [],
  //   "isOk": true
  // }

  Future<List<SelectorItemModel>> getLoaiTangSelector() =>
      _fetchSelector('/api/catalog/loai-tang-for-selector');
  // {
  //   "result": [
  //     {
  //       "id": 1,
  //       "name": "Tầng lầu"
  //     },
  //     {
  //       "id": 2,
  //       "name": "Tầng hầm"
  //     }
  //   ],
  //   "warningMessages": [],
  //   "errors": [],
  //   "isOk": true
  // }

  Future<List<SelectorItemModel>> getTinhTrangCanHoSelector() =>
      _fetchSelector('/api/catalog/tinh-trang-can-ho-for-selector');
  // {
  //   "result": [
  //     {
  //       "id": 1,
  //       "name": "Chưa bàn giao"
  //     },
  //     {
  //       "id": 2,
  //       "name": "Đang trống"
  //     },
  //     {
  //       "id": 3,
  //       "name": "Có cư dân"
  //     },
  //     {
  //       "id": 4,
  //       "name": "Đang thi công"
  //     }
  //   ],
  //   "warningMessages": [],
  //   "errors": [],
  //   "isOk": true
  // }

  Future<List<SelectorItemModel>> getTrangThaiToaNhaSelector() =>
      _fetchSelector('/api/catalog/trang-thai-toa-nha-for-selector');
  // {
  //   "result": [
  //     {
  //       "id": 1,
  //       "name": "Đang hoạt động"
  //     },
  //     {
  //       "id": 2,
  //       "name": "Bảo trì"
  //     },
  //     {
  //       "id": 3,
  //       "name": "Ngưng hoạt động"
  //     }
  //   ],
  //   "warningMessages": [],
  //   "errors": [],
  //   "isOk": true
  // }

  Future<List<SelectorItemModel>> getTrangThaiPhuongTienSelector() =>
      _fetchSelector('/api/catalog/trang-thai-phuong-tien-for-selector');
  // {
  //   "result": [
  //     {
  //       "id": 1,
  //       "name": "Đang hoạt động"
  //     },
  //     {
  //       "id": 2,
  //       "name": "Đã hủy"
  //     },
  //     {
  //       "id": 3,
  //       "name": "Bị khóa"
  //     }
  //   ],
  //   "warningMessages": [],
  //   "errors": [],
  //   "isOk": true
  // }

  Future<List<SelectorItemModel>> getTrangThaiCuTruSelector() =>
      _fetchSelector('/api/catalog/trang-thai-cu-tru-for-selector');
  // {
  //   "result": [
  //     {
  //       "id": 1,
  //       "name": "Đang cư trú"
  //     },
  //     {
  //       "id": 2,
  //       "name": "Đã kết thúc"
  //     },
  //     {
  //       "id": 3,
  //       "name": "Chờ duyệt"
  //     }
  //   ],
  //   "warningMessages": [],
  //   "errors": [],
  //   "isOk": true
  // }

  Future<List<SelectorItemModel>> getLoaiGiayToSelector() =>
      _fetchSelector('/api/catalog/loai-giay-to-for-selector');
  // {
  //   "result": [
  //     {
  //       "id": 1,
  //       "name": "Căn cước công dân"
  //     },
  //     {
  //       "id": 2,
  //       "name": "Sổ hộ khẩu"
  //     },
  //     {
  //       "id": 3,
  //       "name": "Giấy khai sinh"
  //     },
  //     {
  //       "id": 4,
  //       "name": "Hợp đồng thuê"
  //     },
  //     {
  //       "id": 5,
  //       "name": "Khác"
  //     }
  //   ],
  //   "warningMessages": [],
  //   "errors": [],
  //   "isOk": true
  // }

  Future<List<SelectorItemModel>> getLoaiYeuCauCuTruSelector() =>
      _fetchSelector('/api/catalog/loai-yeu-cau-for-selector');
  // {
  //   "result": [
  //     {
  //       "id": 1,
  //       "name": "Thêm"
  //     },
  //     {
  //       "id": 2,
  //       "name": "Sửa"
  //     },
  //     {
  //       "id": 3,
  //       "name": "Xóa"
  //     }
  //   ],
  //   "warningMessages": [],
  //   "errors": [],
  //   "isOk": true
  // }

  Future<List<SelectorItemModel>> getTrangThaiYeuCauCuTruSelector() =>
      _fetchSelector('/api/catalog/trang-thai-yeu-cau-cu-tru-for-selector');
  // {
  //   "result": [
  //     {
  //       "id": 1,
  //       "name": "Đang chờ duyệt"
  //     },
  //     {
  //       "id": 2,
  //       "name": "Đã duyệt"
  //     },
  //     {
  //       "id": 3,
  //       "name": "Từ chối"
  //     }
  //   ],
  //   "warningMessages": [],
  //   "errors": [],
  //   "isOk": true
  // }

  // =========================================================================
  // PRIVATE
  // =========================================================================

  Future<List<SelectorItemModel>> _fetchSelector(String path) async {
    try {
      final response = await _dio.post(path);
      final data = response.data as Map<String, dynamic>;
      final list = data['result'] as List<dynamic>? ?? [];
      return list
          .map((e) => SelectorItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ErrorParser.parse(
        e.response?.data,
        statusCode: e.response?.statusCode,
      );
    } catch (_) {
      throw const AppException('Lỗi không xác định');
    }
  }
}
