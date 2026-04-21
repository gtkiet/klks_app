// // lib/features/dich_vu_dang_ky/models/dich_vu_dang_ky_model.dart

// // PagingInfo đã có trong dich_vu_model.dart → import từ đó, không định nghĩa lại
// // import '../../dich_vu/models/dich_vu_model.dart' show PagingInfo, PagedResult;

// export '../../dich_vu/models/dich_vu_model.dart' show PagingInfo, PagedResult;

// class DichVuDangKyItem {
//   final int id;
//   final int canHoId;
//   final int dichVuId;
//   final String maDichVu;
//   final String tenDichVu;
//   final int loaiDichVuId;
//   final String loaiDichVuTen;
//   final int soLuong;
//   final DateTime? ngayBatDau;
//   final DateTime? ngayKetThuc;
//   final int trangThaiDangKyId;
//   final String trangThaiDangKyTen;

//   const DichVuDangKyItem({
//     required this.id,
//     required this.canHoId,
//     required this.dichVuId,
//     required this.maDichVu,
//     required this.tenDichVu,
//     required this.loaiDichVuId,
//     required this.loaiDichVuTen,
//     required this.soLuong,
//     this.ngayBatDau,
//     this.ngayKetThuc,
//     required this.trangThaiDangKyId,
//     required this.trangThaiDangKyTen,
//   });

//   // ── Getters ────────────────────────────────────────────────────────────────

//   /// Còn hiệu lực nếu ngayKetThuc chưa qua hoặc chưa set
//   bool get isActive {
//     if (ngayKetThuc == null) return true;
//     return ngayKetThuc!.isAfter(DateTime.now());
//   }

//   /// Khoảng thời gian dạng "dd/MM/yyyy → dd/MM/yyyy"
//   String get thoiGianHienThi {
//     String fmt(DateTime? d) => d == null
//         ? 'N/A'
//         : '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
//     return '${fmt(ngayBatDau)} → ${fmt(ngayKetThuc)}';
//   }

//   factory DichVuDangKyItem.fromJson(Map<String, dynamic> json) {
//     return DichVuDangKyItem(
//       id: json['id'] as int? ?? 0,
//       canHoId: json['canHoId'] as int? ?? 0,
//       dichVuId: json['dichVuId'] as int? ?? 0,
//       maDichVu: json['maDichVu'] as String? ?? '',
//       tenDichVu: json['tenDichVu'] as String? ?? '',
//       loaiDichVuId: json['loaiDichVuId'] as int? ?? 0,
//       loaiDichVuTen: json['loaiDichVuTen'] as String? ?? '',
//       soLuong: json['soLuong'] as int? ?? 0,
//       ngayBatDau: json['ngayBatDau'] != null
//           ? DateTime.tryParse(json['ngayBatDau'] as String)
//           : null,
//       ngayKetThuc: json['ngayKetThuc'] != null
//           ? DateTime.tryParse(json['ngayKetThuc'] as String)
//           : null,
//       trangThaiDangKyId: json['trangThaiDangKyId'] as int? ?? 0,
//       trangThaiDangKyTen: json['trangThaiDangKyTen'] as String? ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         'id': id,
//         'canHoId': canHoId,
//         'dichVuId': dichVuId,
//         'maDichVu': maDichVu,
//         'tenDichVu': tenDichVu,
//         'loaiDichVuId': loaiDichVuId,
//         'loaiDichVuTen': loaiDichVuTen,
//         'soLuong': soLuong,
//         'ngayBatDau': ngayBatDau?.toIso8601String(),
//         'ngayKetThuc': ngayKetThuc?.toIso8601String(),
//         'trangThaiDangKyId': trangThaiDangKyId,
//         'trangThaiDangKyTen': trangThaiDangKyTen,
//       };

//   DichVuDangKyItem copyWith({
//     int? id,
//     int? canHoId,
//     int? dichVuId,
//     String? maDichVu,
//     String? tenDichVu,
//     int? loaiDichVuId,
//     String? loaiDichVuTen,
//     int? soLuong,
//     DateTime? ngayBatDau,
//     DateTime? ngayKetThuc,
//     int? trangThaiDangKyId,
//     String? trangThaiDangKyTen,
//   }) {
//     return DichVuDangKyItem(
//       id: id ?? this.id,
//       canHoId: canHoId ?? this.canHoId,
//       dichVuId: dichVuId ?? this.dichVuId,
//       maDichVu: maDichVu ?? this.maDichVu,
//       tenDichVu: tenDichVu ?? this.tenDichVu,
//       loaiDichVuId: loaiDichVuId ?? this.loaiDichVuId,
//       loaiDichVuTen: loaiDichVuTen ?? this.loaiDichVuTen,
//       soLuong: soLuong ?? this.soLuong,
//       ngayBatDau: ngayBatDau ?? this.ngayBatDau,
//       ngayKetThuc: ngayKetThuc ?? this.ngayKetThuc,
//       trangThaiDangKyId: trangThaiDangKyId ?? this.trangThaiDangKyId,
//       trangThaiDangKyTen: trangThaiDangKyTen ?? this.trangThaiDangKyTen,
//     );
//   }
// }