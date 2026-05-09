
// lib/features/cu_tru/phuong_tien/services/pt_yeu_cau_service.dart

import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';

import '../../quan_he/models/selector_item_model.dart';
import '../../quan_he/models/uploaded_file_model.dart';
import '../models/yeu_cau_phuong_tien_model.dart' hide PagedResult;
import '../models/phuong_tien_request_models.dart';

class PTYeuCauService {
  PTYeuCauService._();
  static final PTYeuCauService instance = PTYeuCauService._();

  static final _client = ApiClient.instance;

  Future<PagedResult<YeuCauPhuongTien>> getListYeuCau(
    GetListYeuCauPhuongTienRequest request,
  ) async {
    final res = await _client.post(
      '/api/phuong-tien/yeu-cau/get-list',
      body: request.toJson(),
    );
    return res.pagedResult(YeuCauPhuongTien.fromJson);
  }

  Future<YeuCauPhuongTien> getYeuCauById(int requestId) async {
    final res = await _client.post(
      '/api/phuong-tien/yeu-cau/get-by-id',
      body: {'requestId': requestId},
    );
    return res.item(YeuCauPhuongTien.fromJson);
  }

  Future<YeuCauPhuongTien> taoYeuCau(
    TaoYeuCauPhuongTienRequest request,
  ) async {
    final res = await _client.post(
      '/api/phuong-tien/yeu-cau',
      body: request.toJson(),
    );
    return res.item(YeuCauPhuongTien.fromJson);
  }

  Future<YeuCauPhuongTien> capNhatYeuCau(
    CapNhatYeuCauPhuongTienRequest request,
  ) async {
    final res = await _client.put(
      '/api/phuong-tien/yeu-cau',
      body: request.toJson(),
    );
    return res.item(YeuCauPhuongTien.fromJson);
  }

  Future<void> baoMatThe(List<int> theIds) async {
    await _client.put(
      '/api/phuong-tien/the-phuong-tien/bao-mat',
      body: {'theIds': theIds},
    );
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

  Future<List<SelectorItemModel>> getLoaiPhuongTienSelector() =>
      _fetchSelector('/api/catalog/loai-phuong-tien-for-selector');

  Future<List<SelectorItemModel>> _fetchSelector(String path) async {
    final res = await _client.post(path);
    return res.list(SelectorItemModel.fromJson);
  }
}