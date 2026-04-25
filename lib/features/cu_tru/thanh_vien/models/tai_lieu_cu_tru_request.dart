// lib/features/cu_tru/thanh_vien/models/tai_lieu_cu_tru_request.dart
//
// Fix: server validate SoGiayTo là required field →
// toJson() luôn include 'soGiayTo' dù giá trị là empty string

class TaiLieuCuTruRequest {
  /// 0 = tạo mới, khác 0 = cập nhật tài liệu cũ.
  final int taiLieuCuTruId;
  final int? loaiGiayToId;

  /// Server validate required — gửi '' nếu không có.
  final String soGiayTo;
  final DateTime? ngayPhatHanh;

  /// Bắt buộc: danh sách fileId từ /api/upload-media.
  final List<int> fileIds;

  const TaiLieuCuTruRequest({
    this.taiLieuCuTruId = 0,
    this.loaiGiayToId,
    this.soGiayTo = '', // default empty — server accept ''
    this.ngayPhatHanh,
    required this.fileIds,
  });

  Map<String, dynamic> toJson() => {
    // soGiayTo luôn gửi — server bắt buộc field này tồn tại
    'soGiayTo': soGiayTo,
    'fileIds': fileIds,
    if (taiLieuCuTruId != 0) 'taiLieuCuTruId': taiLieuCuTruId,
    if (loaiGiayToId != null && loaiGiayToId != 0) 'loaiGiayToId': loaiGiayToId,
    if (ngayPhatHanh != null) 'ngayPhatHanh': ngayPhatHanh!.toIso8601String(),
  };
}
