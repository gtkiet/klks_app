// lib/features/cu_tru/phuong_tien/services/phuong_tien_service.dart

import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';

import '../models/phuong_tien_model.dart';

class PhuongTienService {
  PhuongTienService._();
  static final instance = PhuongTienService._();

  static final _client = ApiClient.instance;

  Future<PagedResult<PhuongTien>> getListPhuongTien(
    GetListPhuongTienRequest request,
  ) async {
    final res = await _client.post(
      '/api/phuong-tien/get-list',
      body: request.toJson(),
    );
    return res.pagedResult(PhuongTien.fromJson);
  }

  Future<PhuongTien> getPhuongTienById(int id) async {
    final res = await _client.post(
      '/api/phuong-tien/get-by-id',
      body: {'id': id},
    );
    return res.item(PhuongTien.fromJson);
  }

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

  Future<YeuCauPhuongTien> taoYeuCau(TaoYeuCauPhuongTienRequest request) async {
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

  // TODO: tạo shared service để upload file dùng chung cho tất cả các module
  Future<List<UploadedFile>> uploadMedia({
    required List<File> files,
    required String targetContainer,
  }) async {
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
    final res = await _client.postForm('/api/upload-media', formData);
    return res.list(UploadedFile.fromJson);
  }

  Future<List<SelectorItem>> getLoaiPhuongTienSelector() =>
      _fetchSelector('/api/catalog/loai-phuong-tien-for-selector');

  Future<List<SelectorItem>> _fetchSelector(String path) async {
    final res = await _client.post(path);
    return res.list(SelectorItem.fromJson);
  }
}
