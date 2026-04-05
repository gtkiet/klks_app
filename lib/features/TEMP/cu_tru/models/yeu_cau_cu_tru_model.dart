// lib/features/cu_tru/models/yeu_cau_cu_tru_model.dart

import 'thong_tin_cu_dan_model.dart';

// ─── Catalog model (dùng chung cho selector APIs) ────────────────────────────

class SelectorItemModel {
  final int id;
  final String name;

  const SelectorItemModel({required this.id, required this.name});

  factory SelectorItemModel.fromJson(Map<String, dynamic> json) =>
      SelectorItemModel(id: json['id'] ?? 0, name: json['name'] ?? '');

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

// ─── Upload media result ──────────────────────────────────────────────────────

class UploadedFileModel {
  final int fileId;
  final String fileName;
  final String fileUrl;
  final String contentType;

  const UploadedFileModel({
    required this.fileId,
    required this.fileName,
    required this.fileUrl,
    required this.contentType,
  });

  factory UploadedFileModel.fromJson(Map<String, dynamic> json) =>
      UploadedFileModel(
        fileId: json['fileId'] ?? 0,
        fileName: json['fileName'] ?? '',
        fileUrl: json['fileUrl'] ?? '',
        contentType: json['contentType'] ?? '',
      );
}

// ─── Yêu cầu cư trú (list item & detail) ────────────────────────────────────

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
    required this.documents,
  });

  /// Derived: tên đầy đủ từ họ + tên
  String? get hoTenDayDu {
    if (yeuCauHo == null && yeuCauTen == null) return null;
    return '${yeuCauHo ?? ''} ${yeuCauTen ?? ''}'.trim();
  }

  factory YeuCauCuTruModel.fromJson(Map<String, dynamic> json) =>
      YeuCauCuTruModel(
        id: json['id'] ?? 0,
        createdBy: json['createdBy'] ?? 0,
        tenNguoiGui: json['tenNguoiGui'] ?? '',
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'])
            : null,
        canHoId: json['canHoId'] ?? 0,
        tenCanHo: json['tenCanHo'] ?? '',
        tenTang: json['tenTang'] ?? '',
        tenToaNha: json['tenToaNha'] ?? '',
        nguoiXuLyId: json['nguoiXuLyId'],
        tenNguoiXuLy: json['tenNguoiXuLy'],
        ngayXuLy: json['ngayXuLy'] != null
            ? DateTime.tryParse(json['ngayXuLy'])
            : null,
        loaiYeuCauId: json['loaiYeuCauId'] ?? 0,
        tenLoaiYeuCau: json['tenLoaiYeuCau'] ?? '',
        targetQuanHeCuTruId: json['targetQuanHeCuTruId'],
        yeuCauTen: json['yeuCauTen'],
        yeuCauHo: json['yeuCauHo'],
        yeuCauNgaySinh: json['yeuCauNgaySinh'] != null
            ? DateTime.tryParse(json['yeuCauNgaySinh'])
            : null,
        yeuCauGioiTinhId: json['yeuCauGioiTinhId'],
        yeuCauGioiTinhTen: json['yeuCauGioiTinhTen'],
        yeuCauSoDienThoai: json['yeuCauSoDienThoai'],
        yeuCauCCCD: json['yeuCauCCCD'],
        yeuCauDiaChi: json['yeuCauDiaChi'],
        yeuCauLoaiQuanHeId: json['yeuCauLoaiQuanHeId'],
        yeuCauLoaiQuanHeTen: json['yeuCauLoaiQuanHeTen'],
        noiDung: json['noiDung'],
        lyDo: json['lyDo'],
        trangThaiId: json['trangThaiId'] ?? 0,
        tenTrangThai: json['tenTrangThai'] ?? '',
        documents:
            (json['documents'] as List<dynamic>?)
                ?.map((e) => TaiLieuCuTruModel.fromJson(e))
                .toList() ??
            [],
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
    'loaiYeuCauId': loaiYeuCauId,
    'tenLoaiYeuCau': tenLoaiYeuCau,
    'trangThaiId': trangThaiId,
    'tenTrangThai': tenTrangThai,
    'documents': documents.map((e) => e.toJson()).toList(),
  };
}

// ─── Paging info ──────────────────────────────────────────────────────────────

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
    pageSize: json['pageSize'] ?? 0,
    pageNumber: json['pageNumber'] ?? 0,
    totalItems: json['totalItems'] ?? 0,
  );
}

class YeuCauCuTruListResult {
  final List<YeuCauCuTruModel> items;
  final PagingInfo pagingInfo;

  const YeuCauCuTruListResult({required this.items, required this.pagingInfo});

  factory YeuCauCuTruListResult.fromJson(Map<String, dynamic> json) =>
      YeuCauCuTruListResult(
        items:
            (json['items'] as List<dynamic>?)
                ?.map((e) => YeuCauCuTruModel.fromJson(e))
                .toList() ??
            [],
        pagingInfo: PagingInfo.fromJson(json['pagingInfo'] ?? {}),
      );
}
