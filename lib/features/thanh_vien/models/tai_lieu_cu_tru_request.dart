// lib/features/thanh_vien/models/tai_lieu_cu_tru_request.dart

// Model để build payload taiLieuCuTrus khi tạo/cập nhật yêu cầu cư trú.
// Tách riêng vì đây là INPUT model (gửi lên), khác với TaiLieuCuTruModel
// là OUTPUT model (nhận về từ server).
//
// Dùng:
//   TaiLieuCuTruRequest(fileIds: [1, 2])
//   TaiLieuCuTruRequest(taiLieuCuTruId: 7, loaiGiayToId: 5, soGiayTo: 'ABC', fileIds: [4])

class TaiLieuCuTruRequest {
  /// 0 = tạo mới, khác 0 = cập nhật tài liệu cũ.
  final int taiLieuCuTruId;
  final int? loaiGiayToId;
  final String? soGiayTo;
  final DateTime? ngayPhatHanh;

  /// Bắt buộc: danh sách fileId từ /api/upload-media.
  final List<int> fileIds;

  const TaiLieuCuTruRequest({
    this.taiLieuCuTruId = 0,
    this.loaiGiayToId,
    this.soGiayTo,
    this.ngayPhatHanh,
    required this.fileIds,
  });

  /// Chỉ serialize field có giá trị thực sự — tránh gửi null/0 lên server.
  Map<String, dynamic> toJson() => {
    'fileIds': fileIds,
    if (taiLieuCuTruId != 0) 'taiLieuCuTruId': taiLieuCuTruId,
    if (loaiGiayToId != null && loaiGiayToId != 0) 'loaiGiayToId': loaiGiayToId,
    if (soGiayTo != null && soGiayTo!.isNotEmpty) 'soGiayTo': soGiayTo,
    if (ngayPhatHanh != null) 'ngayPhatHanh': ngayPhatHanh!.toIso8601String(),
  };
}
