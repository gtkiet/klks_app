// lib/features/cu_tru/phuong_tien/services/phuong_tien_service.dart

import '../../../../core/network/api_client.dart';
import '../models/phuong_tien_model.dart';
import '../models/phuong_tien_request_models.dart';

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
}
