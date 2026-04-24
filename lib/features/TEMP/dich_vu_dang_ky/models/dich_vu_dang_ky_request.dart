// // lib/features/dich_vu_dang_ky/models/dich_vu_dang_ky_request.dart

// class DichVuDangKyRequest {
//   final int? loaiDichVuId;
//   final int? dichVuId;
//   final int? trangThaiDangKyId;
//   final DateTime? tuNgay;
//   final DateTime? denNgay;
//   final String? keyword;
//   final int pageNumber;
//   final int pageSize;
//   final String sortCol;
//   final bool isAsc;

//   const DichVuDangKyRequest({
//     this.loaiDichVuId,
//     this.dichVuId,
//     this.trangThaiDangKyId,
//     this.tuNgay,
//     this.denNgay,
//     this.keyword,
//     this.pageNumber = 1,
//     this.pageSize = 20,
//     this.sortCol = 'id',
//     this.isAsc = false,
//   });

//   /// Preset: lấy dịch vụ tiện ích (loaiDichVuId = 3)
//   factory DichVuDangKyRequest.tienIch({int pageNumber = 1, int pageSize = 20}) {
//     return DichVuDangKyRequest(
//       loaiDichVuId: 3,
//       pageNumber: pageNumber,
//       pageSize: pageSize,
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         if (loaiDichVuId != null) 'loaiDichVuId': loaiDichVuId,
//         if (dichVuId != null) 'dichVuId': dichVuId,
//         if (trangThaiDangKyId != null) 'trangThaiDangKyId': trangThaiDangKyId,
//         if (tuNgay != null) 'tuNgay': tuNgay!.toIso8601String(),
//         if (denNgay != null) 'denNgay': denNgay!.toIso8601String(),
//         if (keyword != null && keyword!.isNotEmpty) 'keyword': keyword,
//         'pageNumber': pageNumber,
//         'pageSize': pageSize,
//         'sortCol': sortCol,
//         'isAsc': isAsc,
//       };

//   DichVuDangKyRequest copyWith({
//     int? loaiDichVuId,
//     int? dichVuId,
//     int? trangThaiDangKyId,
//     DateTime? tuNgay,
//     DateTime? denNgay,
//     String? keyword,
//     int? pageNumber,
//     int? pageSize,
//     String? sortCol,
//     bool? isAsc,
//   }) {
//     return DichVuDangKyRequest(
//       loaiDichVuId: loaiDichVuId ?? this.loaiDichVuId,
//       dichVuId: dichVuId ?? this.dichVuId,
//       trangThaiDangKyId: trangThaiDangKyId ?? this.trangThaiDangKyId,
//       tuNgay: tuNgay ?? this.tuNgay,
//       denNgay: denNgay ?? this.denNgay,
//       keyword: keyword ?? this.keyword,
//       pageNumber: pageNumber ?? this.pageNumber,
//       pageSize: pageSize ?? this.pageSize,
//       sortCol: sortCol ?? this.sortCol,
//       isAsc: isAsc ?? this.isAsc,
//     );
//   }
// }