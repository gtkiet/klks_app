// lib/features/tien_ich/sua_chua/services/sua_chua_service.dart

import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../models/sua_chua_model.dart';

class YeuCauSuaChuaService {
  YeuCauSuaChuaService._();
  static final YeuCauSuaChuaService instance = YeuCauSuaChuaService._();

  static final _client = ApiClient.instance;

  // ── Catalog ───────────────────────────────────────────────────────────────

  Future<List<CatalogItem>> getTrangThaiYeuCau() async {
    final res = await _client.post(
      '/api/catalog/trang-thai-yeu-cau-for-selector',
    );
    return res.list(CatalogItem.fromJson);
  }

  Future<List<CatalogItem>> getTrangThaiSuaChua() async {
    final res = await _client.post(
      '/api/catalog/trang-thai-sua-chua-for-selector',
    );
    return res.list(CatalogItem.fromJson);
  }

  Future<List<CatalogItem>> getLoaiSuCo() async {
    final res = await _client.post(
      '/api/catalog/loai-su-co-ky-thuat-for-selector',
    );
    return res.list(CatalogItem.fromJson);
  }

  Future<List<CatalogItem>> getPhamViSuaChua() async {
    final res = await _client.post(
      '/api/catalog/pham-vi-sua-chua-for-selector',
    );
    return res.list(CatalogItem.fromJson);
  }

  // ── Upload ────────────────────────────────────────────────────────────────

  Future<List<UploadedFile>> uploadMedia(List<String> filePaths) async {
    final formData = FormData()
      ..fields.add(const MapEntry('targetContainer', 'tai-lieu-cu-tru'));
    for (final path in filePaths) {
      formData.files.add(MapEntry('files', await MultipartFile.fromFile(path)));
    }
    final res = await _client.postForm('/api/upload-media', formData);
    return res.list(UploadedFile.fromJson);
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────

  Future<PagedResult<YeuCauSuaChua>> getList(
    GetListYeuCauRequest request,
  ) async {
    final res = await _client.post(
      '/api/yeu-cau-sua-chua/get-list',
      body: request.toJson(),
    );
    return res.pagedResult(YeuCauSuaChua.fromJson);
  }

  Future<YeuCauSuaChua> getById(int id) async {
    final res = await _client.post(
      '/api/yeu-cau-sua-chua/get-by-id',
      body: {'id': id},
    );
    return res.item(YeuCauSuaChua.fromJson);
  }

  Future<YeuCauSuaChua> taoYeuCau(TaoYeuCauRequest request) async {
    final res = await _client.post(
      '/api/yeu-cau-sua-chua',
      body: request.toJson(),
    );
    return res.item(YeuCauSuaChua.fromJson);
  }

  Future<YeuCauSuaChua> capNhatYeuCau(CapNhatYeuCauRequest request) async {
    final res = await _client.put(
      '/api/yeu-cau-sua-chua',
      body: request.toJson(),
    );
    return res.item(YeuCauSuaChua.fromJson);
  }

  Future<YeuCauSuaChua> thuHoiYeuCau({
    required int id,
    required int phamViId,
    required int loaiSuCoId,
    required String noiDung,
  }) => capNhatYeuCau(
    CapNhatYeuCauRequest(
      id: id,
      phamViId: phamViId,
      loaiSuCoId: loaiSuCoId,
      noiDung: noiDung,
      isSubmit: false,
      isWithdraw: true,
    ),
  );
}
