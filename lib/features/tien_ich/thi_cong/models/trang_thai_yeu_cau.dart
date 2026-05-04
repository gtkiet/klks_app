// lib/features/yeu_cau_thi_cong/models/trang_thai_yeu_cau.dart

/// ID trạng thái yêu cầu — đồng bộ với API
/// POST /api/catalog/trang-thai-yeu-cau-for-selector
abstract class TrangThaiYeuCauConst {
  static const int dangChoDuyet = 1;
  static const int daDuyet = 2;
  static const int tuChoi = 3;
  static const int daLuu = 4;
  static const int daThuHoi = 5;
  static const int hetHieuLuc = 6;
  static const int hoanTat = 7;
  static const int daHuy = 8;
  static const int yeuCauBoSung = 9; // "Trả lại" / Returned

  /// Cư dân có thể chỉnh sửa khi ở các trạng thái này
  static const Set<int> coTheChinhSua = {daLuu, yeuCauBoSung};

  /// Cư dân có thể thu hồi khi ở các trạng thái này
  static const Set<int> coTheThuHoi = {daLuu, dangChoDuyet};
}