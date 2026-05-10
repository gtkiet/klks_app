// lib/features/cu_tru/thanh_vien/services/thanh_vien_service.dart
import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';

import '../../quan_he/models/quan_he_cu_tru_model.dart';
import '../models/thanh_vien_model.dart';

class ThanhVienService {
  ThanhVienService._();
  static final ThanhVienService instance = ThanhVienService._();

  static final _client = ApiClient.instance;

  Future<List<ThanhVienCuTruModel>> getThanhVienCuTru(int canHoId) async {
    final res = await _client.post(
      '/api/cu-dan/thanh-vien-cu-tru',
      body: {'canHoId': canHoId},
    );
    return res.list(ThanhVienCuTruModel.fromJson);
  }

  Future<ThongTinCuDanModel> getThongTinCuDan(int quanHeCuTruId) async {
    final res = await _client.post(
      '/api/cu-dan/thong-tin',
      body: {'quanHeCuTruId': quanHeCuTruId},
    );
    return res.item(ThongTinCuDanModel.fromJson);
  }

  
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
