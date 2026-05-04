// lib/features/cu_tru/thanh_vien/services/tv_yeu_cau_service.dart

import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../../core/network/api_client.dart';
import '../../../../../core/errors/errors.dart';

import '../models/yeu_cau_cu_tru_model.dart';
import '../models/thanh_vien_request.dart';
import '../../quan_he/models/uploaded_file_model.dart';
import '../../quan_he/models/selector_item_model.dart';

class YeuCauCuTruService {
  YeuCauCuTruService._();

  static final YeuCauCuTruService instance = YeuCauCuTruService._();

  Dio get _dio => ApiClient.instance.dio;

  // ── Danh sách yêu cầu (phân trang) ────────────────────────────────────

  Future<YeuCauCuTruListResult> getYeuCauList(
    GetListYeuCauCuTruRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/api/quan-he-cu-tru/yeu-cau/get-list',
        data: request.toJson(),
      );
      final data = response.data as Map<String, dynamic>;
      return YeuCauCuTruListResult.fromJson(
        data['result'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ErrorParser.parse(
        e.response?.data,
        statusCode: e.response?.statusCode,
      );
    } catch (_) {
      throw const AppException('Lỗi không xác định');
    }
  }

  // ── Chi tiết một yêu cầu ───────────────────────────────────────────────

  Future<YeuCauCuTruModel> getYeuCauById(int requestId) async {
    try {
      final response = await _dio.post(
        '/api/quan-he-cu-tru/yeu-cau/get-by-id',
        data: {'requestId': requestId},
      );
      final data = response.data as Map<String, dynamic>;
      return YeuCauCuTruModel.fromJson(data['result'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ErrorParser.parse(
        e.response?.data,
        statusCode: e.response?.statusCode,
      );
    } catch (_) {
      throw const AppException('Lỗi không xác định');
    }
  }

  // ── Tạo mới yêu cầu ───────────────────────────────────────────────────

  Future<YeuCauCuTruModel> createYeuCau(TaoYeuCauCuTruRequest request) async {
    try {
      final response = await _dio.post(
        '/api/quan-he-cu-tru/yeu-cau',
        data: request.toJson(),
      );
      final data = response.data as Map<String, dynamic>;
      return YeuCauCuTruModel.fromJson(data['result'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ErrorParser.parse(
        e.response?.data,
        statusCode: e.response?.statusCode,
      );
    } catch (_) {
      throw const AppException('Lỗi không xác định');
    }
  }

  // ── Cập nhật yêu cầu (submit / withdraw / edit) ───────────────────────

  Future<YeuCauCuTruModel> updateYeuCau(
    CapNhatYeuCauCuTruRequest request,
  ) async {
    try {
      final response = await _dio.put(
        '/api/quan-he-cu-tru/yeu-cau',
        data: request.toJson(),
      );
      final data = response.data as Map<String, dynamic>;
      return YeuCauCuTruModel.fromJson(data['result'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ErrorParser.parse(
        e.response?.data,
        statusCode: e.response?.statusCode,
      );
    } catch (_) {
      throw const AppException('Lỗi không xác định');
    }
  }

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

  Future<List<SelectorItemModel>> getGioiTinhSelector() =>
      _fetchSelector('/api/catalog/gioi-tinh-for-selector');

  Future<List<SelectorItemModel>> getLoaiQuanHeCuTruSelector() =>
      _fetchSelector('/api/catalog/loai-quan-he-cu-tru-for-selector');

  Future<List<SelectorItemModel>> getLoaiGiayToSelector() =>
      _fetchSelector('/api/catalog/loai-giay-to-for-selector');

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
