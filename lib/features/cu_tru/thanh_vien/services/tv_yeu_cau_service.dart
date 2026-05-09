
// lib/features/cu_tru/thanh_vien/services/tv_yeu_cau_service.dart

import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';

import '../../quan_he/models/uploaded_file_model.dart';
import '../../quan_he/models/selector_item_model.dart';

import '../models/yeu_cau_cu_tru_model.dart';
import '../models/thanh_vien_request.dart';

class YeuCauCuTruService {
  YeuCauCuTruService._();
  static final YeuCauCuTruService instance = YeuCauCuTruService._();

  static final _client = ApiClient.instance;

  Future<YeuCauCuTruListResult> getYeuCauList(
    GetListYeuCauCuTruRequest request,
  ) async {
    final res = await _client.post(
      '/api/quan-he-cu-tru/yeu-cau/get-list',
      body: request.toJson(),
    );
    return YeuCauCuTruListResult.fromJson(res.item((j) => j));
  }

  Future<YeuCauCuTruModel> getYeuCauById(int requestId) async {
    final res = await _client.post(
      '/api/quan-he-cu-tru/yeu-cau/get-by-id',
      body: {'requestId': requestId},
    );
    return res.item(YeuCauCuTruModel.fromJson);
  }

  Future<YeuCauCuTruModel> createYeuCau(TaoYeuCauCuTruRequest request) async {
    final res = await _client.post(
      '/api/quan-he-cu-tru/yeu-cau',
      body: request.toJson(),
    );
    return res.item(YeuCauCuTruModel.fromJson);
  }

  Future<YeuCauCuTruModel> updateYeuCau(
    CapNhatYeuCauCuTruRequest request,
  ) async {
    final res = await _client.put(
      '/api/quan-he-cu-tru/yeu-cau',
      body: request.toJson(),
    );
    return res.item(YeuCauCuTruModel.fromJson);
  }

  Future<List<UploadedFileModel>> uploadMedia({
    required List<File> files,
    required String targetContainer,
  }) async {
    final formData = FormData()
      ..fields.add(MapEntry('targetContainer', targetContainer));
    for (final file in files) {
      formData.files.add(MapEntry(
        'files',
        await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      ));
    }
    final res = await _client.postForm('/api/upload-media', formData);
    return res.list(UploadedFileModel.fromJson);
  }

  Future<List<SelectorItemModel>> getGioiTinhSelector() =>
      _fetchSelector('/api/catalog/gioi-tinh-for-selector');

  Future<List<SelectorItemModel>> getLoaiQuanHeCuTruSelector() =>
      _fetchSelector('/api/catalog/loai-quan-he-cu-tru-for-selector');

  Future<List<SelectorItemModel>> getLoaiGiayToSelector() =>
      _fetchSelector('/api/catalog/loai-giay-to-for-selector');

  Future<List<SelectorItemModel>> _fetchSelector(String path) async {
    final res = await _client.post(path);
    return res.list(SelectorItemModel.fromJson);
  }
}
