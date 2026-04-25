// lib/features/cu_tru/thanh_vien/models/yeu_cau_cu_tru_model.dart

import 'thong_tin_cu_dan_model.dart'; // TaiLieuCuTruModel

// YeuCauCuTruListResult và PagingInfo (local) giữ cùng file này —
// chúng chỉ là wrapper của YeuCauCuTruModel, không dùng ở nơi khác.

class YeuCauCuTruModel {
  final int id;
  final int createdBy;
  final String tenNguoiGui;
  final DateTime? createdAt;
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
  final List<TaiLieuCuTruModel> documents;

  const YeuCauCuTruModel({
    required this.id,
    required this.createdBy,
    required this.tenNguoiGui,
    this.createdAt,
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
    this.documents = const [],
  });

  /// Họ tên đầy đủ từ yêu cầu (nếu có).
  String? get hoTenDayDu {
    if (yeuCauHo == null && yeuCauTen == null) return null;
    return '${yeuCauHo ?? ''} ${yeuCauTen ?? ''}'.trim();
  }

  String get diaChiCanHo => '$tenToaNha - $tenTang - $tenCanHo';

  factory YeuCauCuTruModel.fromJson(Map<String, dynamic> json) =>
      YeuCauCuTruModel(
        id: json['id'] as int? ?? 0,
        createdBy: json['createdBy'] as int? ?? 0,
        tenNguoiGui: json['tenNguoiGui'] as String? ?? '',
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String)
            : null,
        canHoId: json['canHoId'] as int? ?? 0,
        tenCanHo: json['tenCanHo'] as String? ?? '',
        tenTang: json['tenTang'] as String? ?? '',
        tenToaNha: json['tenToaNha'] as String? ?? '',
        nguoiXuLyId: json['nguoiXuLyId'] as int?,
        tenNguoiXuLy: json['tenNguoiXuLy'] as String?,
        ngayXuLy: json['ngayXuLy'] != null
            ? DateTime.tryParse(json['ngayXuLy'] as String)
            : null,
        loaiYeuCauId: json['loaiYeuCauId'] as int? ?? 0,
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
        trangThaiId: json['trangThaiId'] as int? ?? 0,
        tenTrangThai: json['tenTrangThai'] as String? ?? '',
        documents: (json['documents'] as List<dynamic>? ?? [])
            .map((e) => TaiLieuCuTruModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdBy': createdBy,
    'tenNguoiGui': tenNguoiGui,
    'createdAt': createdAt?.toIso8601String(),
    'canHoId': canHoId,
    'tenCanHo': tenCanHo,
    'tenTang': tenTang,
    'tenToaNha': tenToaNha,
    'nguoiXuLyId': nguoiXuLyId,
    'tenNguoiXuLy': tenNguoiXuLy,
    'ngayXuLy': ngayXuLy?.toIso8601String(),
    'loaiYeuCauId': loaiYeuCauId,
    'tenLoaiYeuCau': tenLoaiYeuCau,
    'targetQuanHeCuTruId': targetQuanHeCuTruId,
    'yeuCauTen': yeuCauTen,
    'yeuCauHo': yeuCauHo,
    'yeuCauNgaySinh': yeuCauNgaySinh?.toIso8601String(),
    'yeuCauGioiTinhId': yeuCauGioiTinhId,
    'yeuCauGioiTinhTen': yeuCauGioiTinhTen,
    'yeuCauSoDienThoai': yeuCauSoDienThoai,
    'yeuCauCCCD': yeuCauCCCD,
    'yeuCauDiaChi': yeuCauDiaChi,
    'yeuCauLoaiQuanHeId': yeuCauLoaiQuanHeId,
    'yeuCauLoaiQuanHeTen': yeuCauLoaiQuanHeTen,
    'noiDung': noiDung,
    'lyDo': lyDo,
    'trangThaiId': trangThaiId,
    'tenTrangThai': tenTrangThai,
    'documents': documents.map((e) => e.toJson()).toList(),
  };
}

// ── Paging (local, chỉ dùng cho yêu cầu cư trú) ─────────────────────────────

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
    pageSize: json['pageSize'] as int? ?? 0,
    pageNumber: json['pageNumber'] as int? ?? 0,
    totalItems: json['totalItems'] as int? ?? 0,
  );
}

// ── List result wrapper ───────────────────────────────────────────────────────

class YeuCauCuTruListResult {
  final List<YeuCauCuTruModel> items;
  final PagingInfo pagingInfo;

  const YeuCauCuTruListResult({required this.items, required this.pagingInfo});

  int get totalItems => pagingInfo.totalItems;
  int get pageNumber => pagingInfo.pageNumber;
  int get pageSize => pagingInfo.pageSize;

  factory YeuCauCuTruListResult.fromJson(Map<String, dynamic> json) =>
      YeuCauCuTruListResult(
        items: (json['items'] as List<dynamic>? ?? [])
            .map((e) => YeuCauCuTruModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        pagingInfo: PagingInfo.fromJson(
          json['pagingInfo'] as Map<String, dynamic>? ?? {},
        ),
      );
}
