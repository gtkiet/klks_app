// lib/features/cu_tru/thanh_vien/services/thanh_vien_service.dart

import '../../../../core/network/api_client.dart';
import '../models/thanh_vien_cu_tru_model.dart';
import '../models/thong_tin_cu_dan_model.dart';

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
}
