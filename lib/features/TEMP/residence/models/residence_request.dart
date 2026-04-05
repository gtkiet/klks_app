// lib/features/residence/models/residence_request.dart

import 'residence_document.dart'; // import các model DocumentFile, ResidenceDocument nếu tách riêng

// ─── ResidenceRequestItem ────────────────────────────────────────────────────

class ResidenceRequestItem {
  final int id;
  final int createdBy;
  final String tenNguoiGui;
  final DateTime createdAt;
  final int canHoId;
  final String tenCanHo;
  final String tenTang;
  final String tenToaNha;
  final int? nguoiXuLyId;
  final String? tenNguoiXuLy;
  final DateTime? ngayXuLy;
  final int loaiYeuCauId;
  final String tenLoaiYeuCau;
  final int trangThaiId;
  final String tenTrangThai;
  final String? lyDo;
  final String? noiDung;

  const ResidenceRequestItem({
    required this.id,
    required this.createdBy,
    required this.tenNguoiGui,
    required this.createdAt,
    required this.canHoId,
    required this.tenCanHo,
    required this.tenTang,
    required this.tenToaNha,
    this.nguoiXuLyId,
    this.tenNguoiXuLy,
    this.ngayXuLy,
    required this.loaiYeuCauId,
    required this.tenLoaiYeuCau,
    required this.trangThaiId,
    required this.tenTrangThai,
    this.lyDo,
    this.noiDung,
  });

  factory ResidenceRequestItem.fromJson(Map<String, dynamic> json) =>
      ResidenceRequestItem(
        id: json['id'] as int,
        createdBy: json['createdBy'] as int? ?? 0,
        tenNguoiGui: json['tenNguoiGui'] as String? ?? '',
        createdAt: DateTime.parse(json['createdAt'] as String),
        canHoId: json['canHoId'] as int,
        tenCanHo: json['tenCanHo'] as String? ?? '',
        tenTang: json['tenTang'] as String? ?? '',
        tenToaNha: json['tenToaNha'] as String? ?? '',
        nguoiXuLyId: json['nguoiXuLyId'] as int?,
        tenNguoiXuLy: json['tenNguoiXuLy'] as String?,
        ngayXuLy: json['ngayXuLy'] != null
            ? DateTime.tryParse(json['ngayXuLy'] as String)
            : null,
        loaiYeuCauId: json['loaiYeuCauId'] as int,
        tenLoaiYeuCau: json['tenLoaiYeuCau'] as String? ?? '',
        trangThaiId: json['trangThaiId'] as int,
        tenTrangThai: json['tenTrangThai'] as String? ?? '',
        lyDo: json['lyDo'] as String?,
        noiDung: json['noiDung'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdBy': createdBy,
    'tenNguoiGui': tenNguoiGui,
    'createdAt': createdAt.toIso8601String(),
    'canHoId': canHoId,
    'tenCanHo': tenCanHo,
    'tenTang': tenTang,
    'tenToaNha': tenToaNha,
    'nguoiXuLyId': nguoiXuLyId,
    'tenNguoiXuLy': tenNguoiXuLy,
    'ngayXuLy': ngayXuLy?.toIso8601String(),
    'loaiYeuCauId': loaiYeuCauId,
    'tenLoaiYeuCau': tenLoaiYeuCau,
    'trangThaiId': trangThaiId,
    'tenTrangThai': tenTrangThai,
    'lyDo': lyDo,
    'noiDung': noiDung,
  };
}

// ─── ResidenceRequestDetail ──────────────────────────────────────────────────

class ResidenceRequestDetail {
  final int id;
  final int createdBy;
  final String tenNguoiGui;
  final DateTime createdAt;
  final int canHoId;
  final String tenCanHo;
  final String tenTang;
  final String tenToaNha;
  final int? nguoiXuLyId;
  final String? tenNguoiXuLy;
  final DateTime? ngayXuLy;
  final int loaiYeuCauId;
  final String tenLoaiYeuCau;
  final int? targetQuanHeCuTruId;
  final String? yeuCauTen;
  final String? yeuCauHo;
  final DateTime? yeuCauNgaySinh;
  final int? yeuCauGioiTinhId;
  final String? yeuCauGioiTinhTen;
  final String? yeuCauSoDienThoai;
  final String? yeuCauCCCD;
  final String? yeuCauDiaChi;
  final int? yeuCauLoaiQuanHeId;
  final String? yeuCauLoaiQuanHeTen;
  final String? noiDung;
  final String? lyDo;
  final int trangThaiId;
  final String tenTrangThai;
  final List<ResidenceDocument> documents;

  const ResidenceRequestDetail({
    required this.id,
    required this.createdBy,
    required this.tenNguoiGui,
    required this.createdAt,
    required this.canHoId,
    required this.tenCanHo,
    required this.tenTang,
    required this.tenToaNha,
    this.nguoiXuLyId,
    this.tenNguoiXuLy,
    this.ngayXuLy,
    required this.loaiYeuCauId,
    required this.tenLoaiYeuCau,
    this.targetQuanHeCuTruId,
    this.yeuCauTen,
    this.yeuCauHo,
    this.yeuCauNgaySinh,
    this.yeuCauGioiTinhId,
    this.yeuCauGioiTinhTen,
    this.yeuCauSoDienThoai,
    this.yeuCauCCCD,
    this.yeuCauDiaChi,
    this.yeuCauLoaiQuanHeId,
    this.yeuCauLoaiQuanHeTen,
    this.noiDung,
    this.lyDo,
    required this.trangThaiId,
    required this.tenTrangThai,
    required this.documents,
  });

  factory ResidenceRequestDetail.fromJson(Map<String, dynamic> json) =>
      ResidenceRequestDetail(
        id: json['id'] as int,
        createdBy: json['createdBy'] as int? ?? 0,
        tenNguoiGui: json['tenNguoiGui'] as String? ?? '',
        createdAt: DateTime.parse(json['createdAt'] as String),
        canHoId: json['canHoId'] as int,
        tenCanHo: json['tenCanHo'] as String? ?? '',
        tenTang: json['tenTang'] as String? ?? '',
        tenToaNha: json['tenToaNha'] as String? ?? '',
        nguoiXuLyId: json['nguoiXuLyId'] as int?,
        tenNguoiXuLy: json['tenNguoiXuLy'] as String?,
        ngayXuLy: json['ngayXuLy'] != null
            ? DateTime.tryParse(json['ngayXuLy'] as String)
            : null,
        loaiYeuCauId: json['loaiYeuCauId'] as int,
        tenLoaiYeuCau: json['tenLoaiYeuCau'] as String? ?? '',
        targetQuanHeCuTruId: json['targetQuanHeCuTruId'] as int?,
        yeuCauTen: json['yeuCauTen'] as String?,
        yeuCauHo: json['yeuCauHo'] as String?,
        yeuCauNgaySinh: json['yeuCauNgaySinh'] != null
            ? DateTime.tryParse(json['yeuCauNgaySinh'] as String)
            : null,
        yeuCauGioiTinhId: json['yeuCauGioiTinhId'] as int?,
        yeuCauGioiTinhTen: json['yeuCauGioiTinhTen'] as String?,
        yeuCauSoDienThoai: json['yeuCauSoDienThoai'] as String?,
        yeuCauCCCD: json['yeuCauCCCD'] as String?,
        yeuCauDiaChi: json['yeuCauDiaChi'] as String?,
        yeuCauLoaiQuanHeId: json['yeuCauLoaiQuanHeId'] as int?,
        yeuCauLoaiQuanHeTen: json['yeuCauLoaiQuanHeTen'] as String?,
        noiDung: json['noiDung'] as String?,
        lyDo: json['lyDo'] as String?,
        trangThaiId: json['trangThaiId'] as int,
        tenTrangThai: json['tenTrangThai'] as String? ?? '',
        documents:
            (json['documents'] as List<dynamic>?)
                ?.map(
                  (e) => ResidenceDocument.fromJson(e as Map<String, dynamic>),
                )
                .toList() ??
            [],
      );

  ResidenceRequestDetail copyWith({int? trangThaiId, String? tenTrangThai}) =>
      ResidenceRequestDetail(
        id: id,
        createdBy: createdBy,
        tenNguoiGui: tenNguoiGui,
        createdAt: createdAt,
        canHoId: canHoId,
        tenCanHo: tenCanHo,
        tenTang: tenTang,
        tenToaNha: tenToaNha,
        nguoiXuLyId: nguoiXuLyId,
        tenNguoiXuLy: tenNguoiXuLy,
        ngayXuLy: ngayXuLy,
        loaiYeuCauId: loaiYeuCauId,
        tenLoaiYeuCau: tenLoaiYeuCau,
        targetQuanHeCuTruId: targetQuanHeCuTruId,
        yeuCauTen: yeuCauTen,
        yeuCauHo: yeuCauHo,
        yeuCauNgaySinh: yeuCauNgaySinh,
        yeuCauGioiTinhId: yeuCauGioiTinhId,
        yeuCauGioiTinhTen: yeuCauGioiTinhTen,
        yeuCauSoDienThoai: yeuCauSoDienThoai,
        yeuCauCCCD: yeuCauCCCD,
        yeuCauDiaChi: yeuCauDiaChi,
        yeuCauLoaiQuanHeId: yeuCauLoaiQuanHeId,
        yeuCauLoaiQuanHeTen: yeuCauLoaiQuanHeTen,
        noiDung: noiDung,
        lyDo: lyDo,
        trangThaiId: trangThaiId ?? this.trangThaiId,
        tenTrangThai: tenTrangThai ?? this.tenTrangThai,
        documents: documents,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'trangThaiId': trangThaiId,
    'tenTrangThai': tenTrangThai,
  };
}

// ─── PagingInfo ─────────────────────────────────────────────────────────────

class PagingInfo {
  final int pageSize;
  final int pageNumber;
  final int totalItems;

  const PagingInfo({
    required this.pageSize,
    required this.pageNumber,
    required this.totalItems,
  });

  factory PagingInfo.fromJson(Map<String, dynamic> json) => PagingInfo(
    pageSize: json['pageSize'] as int,
    pageNumber: json['pageNumber'] as int,
    totalItems: json['totalItems'] as int,
  );
}

// ─── ResidenceRequestListResult ─────────────────────────────────────────────

class ResidenceRequestListResult {
  final List<ResidenceRequestItem> items;
  final PagingInfo pagingInfo;

  const ResidenceRequestListResult({
    required this.items,
    required this.pagingInfo,
  });

  factory ResidenceRequestListResult.fromJson(
    Map<String, dynamic> json,
  ) => ResidenceRequestListResult(
    items: (json['items'] as List<dynamic>)
        .map((e) => ResidenceRequestItem.fromJson(e as Map<String, dynamic>))
        .toList(),
    pagingInfo: PagingInfo.fromJson(json['pagingInfo'] as Map<String, dynamic>),
  );
}
