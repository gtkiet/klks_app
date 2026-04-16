// lib/features/dich_vu/models/dich_vu_model.dart

import 'khung_gio_model.dart';

class DichVuItem {
  final int id;
  final String maDichVu;
  final String tenDichVu;
  final int loaiDichVuId;
  final String loaiDichVuTen;
  final String donViTinh;
  final String? moTa;
  final bool isBatBuoc;
  final int? soLuongToiDa;
  final int trangThaiDichVuId;
  final String trangThaiDichVuTen;
  final String? iconUrl;

  const DichVuItem({
    required this.id,
    required this.maDichVu,
    required this.tenDichVu,
    required this.loaiDichVuId,
    required this.loaiDichVuTen,
    required this.donViTinh,
    this.moTa,
    required this.isBatBuoc,
    this.soLuongToiDa,
    required this.trangThaiDichVuId,
    required this.trangThaiDichVuTen,
    this.iconUrl,
  });

  // Getter tiện ích
  bool get isHoatDong => trangThaiDichVuId == 1;
  String get displayName => '$maDichVu - $tenDichVu';

  factory DichVuItem.fromJson(Map<String, dynamic> json) {
    return DichVuItem(
      id: json['id'] as int,
      maDichVu: json['maDichVu'] as String? ?? '',
      tenDichVu: json['tenDichVu'] as String? ?? '',
      loaiDichVuId: json['loaiDichVuId'] as int? ?? 0,
      loaiDichVuTen: json['loaiDichVuTen'] as String? ?? '',
      donViTinh: json['donViTinh'] as String? ?? '',
      moTa: json['moTa'] as String?,
      isBatBuoc: json['isBatBuoc'] as bool? ?? false,
      soLuongToiDa: json['soLuongToiDa'] as int?,
      trangThaiDichVuId: json['trangThaiDichVuId'] as int? ?? 0,
      trangThaiDichVuTen: json['trangThaiDichVuTen'] as String? ?? '',
      iconUrl: json['iconUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'maDichVu': maDichVu,
        'tenDichVu': tenDichVu,
        'loaiDichVuId': loaiDichVuId,
        'loaiDichVuTen': loaiDichVuTen,
        'donViTinh': donViTinh,
        'moTa': moTa,
        'isBatBuoc': isBatBuoc,
        'soLuongToiDa': soLuongToiDa,
        'trangThaiDichVuId': trangThaiDichVuId,
        'trangThaiDichVuTen': trangThaiDichVuTen,
        'iconUrl': iconUrl,
      };

  DichVuItem copyWith({
    int? id,
    String? maDichVu,
    String? tenDichVu,
    int? loaiDichVuId,
    String? loaiDichVuTen,
    String? donViTinh,
    String? moTa,
    bool? isBatBuoc,
    int? soLuongToiDa,
    int? trangThaiDichVuId,
    String? trangThaiDichVuTen,
    String? iconUrl,
  }) {
    return DichVuItem(
      id: id ?? this.id,
      maDichVu: maDichVu ?? this.maDichVu,
      tenDichVu: tenDichVu ?? this.tenDichVu,
      loaiDichVuId: loaiDichVuId ?? this.loaiDichVuId,
      loaiDichVuTen: loaiDichVuTen ?? this.loaiDichVuTen,
      donViTinh: donViTinh ?? this.donViTinh,
      moTa: moTa ?? this.moTa,
      isBatBuoc: isBatBuoc ?? this.isBatBuoc,
      soLuongToiDa: soLuongToiDa ?? this.soLuongToiDa,
      trangThaiDichVuId: trangThaiDichVuId ?? this.trangThaiDichVuId,
      trangThaiDichVuTen: trangThaiDichVuTen ?? this.trangThaiDichVuTen,
      iconUrl: iconUrl ?? this.iconUrl,
    );
  }
}

// ─────────────────────────────────────────────
// Detail model (dùng cho get-by-id)
// ─────────────────────────────────────────────

class DichVuDetail extends DichVuItem {
  final List<KhungGioItem> khungGioDichVu;
  final BangGia? bangGia;

  const DichVuDetail({
    required super.id,
    required super.maDichVu,
    required super.tenDichVu,
    required super.loaiDichVuId,
    required super.loaiDichVuTen,
    required super.donViTinh,
    super.moTa,
    required super.isBatBuoc,
    super.soLuongToiDa,
    required super.trangThaiDichVuId,
    required super.trangThaiDichVuTen,
    super.iconUrl,
    required this.khungGioDichVu,
    this.bangGia,
  });

  factory DichVuDetail.fromJson(Map<String, dynamic> json) {
    return DichVuDetail(
      id: json['id'] as int,
      maDichVu: json['maDichVu'] as String? ?? '',
      tenDichVu: json['tenDichVu'] as String? ?? '',
      loaiDichVuId: json['loaiDichVuId'] as int? ?? 0,
      loaiDichVuTen: json['loaiDichVuTen'] as String? ?? '',
      donViTinh: json['donViTinh'] as String? ?? '',
      moTa: json['moTa'] as String?,
      isBatBuoc: json['isBatBuoc'] as bool? ?? false,
      soLuongToiDa: json['soLuongToiDa'] as int?,
      trangThaiDichVuId: json['trangThaiDichVuId'] as int? ?? 0,
      trangThaiDichVuTen: json['trangThaiDichVuTen'] as String? ?? '',
      iconUrl: json['iconUrl'] as String?,
      khungGioDichVu: (json['khungGioDichVu'] as List<dynamic>?)
              ?.map((e) => KhungGioItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      bangGia: json['bangGia'] != null
          ? BangGia.fromJson(json['bangGia'] as Map<String, dynamic>)
          : null,
    );
  }
}

// ─────────────────────────────────────────────
// BangGia model
// ─────────────────────────────────────────────

class BangGia {
  final int id;
  final int dichVuId;
  final String tenBangGia;
  final DateTime? ngayApDung;
  final DateTime? ngayKetThuc;
  final int loaiDinhGiaId;
  final String loaiDinhGiaTen;
  final double donGia;
  final bool isActive;
  final List<GiaLuyTien> giaLuyTiens;
  final List<GiaKhungGio> giaKhungGios;
  final List<GiaLoaiCanHo> giaLoaiCanHos;

  const BangGia({
    required this.id,
    required this.dichVuId,
    required this.tenBangGia,
    this.ngayApDung,
    this.ngayKetThuc,
    required this.loaiDinhGiaId,
    required this.loaiDinhGiaTen,
    required this.donGia,
    required this.isActive,
    required this.giaLuyTiens,
    required this.giaKhungGios,
    required this.giaLoaiCanHos,
  });

  factory BangGia.fromJson(Map<String, dynamic> json) {
    return BangGia(
      id: json['id'] as int,
      dichVuId: json['dichVuId'] as int,
      tenBangGia: json['tenBangGia'] as String? ?? '',
      ngayApDung: json['ngayApDung'] != null
          ? DateTime.tryParse(json['ngayApDung'] as String)
          : null,
      ngayKetThuc: json['ngayKetThuc'] != null
          ? DateTime.tryParse(json['ngayKetThuc'] as String)
          : null,
      loaiDinhGiaId: json['loaiDinhGiaId'] as int? ?? 0,
      loaiDinhGiaTen: json['loaiDinhGiaTen'] as String? ?? '',
      donGia: (json['donGia'] as num?)?.toDouble() ?? 0,
      isActive: json['isActive'] as bool? ?? false,
      giaLuyTiens: (json['giaLuyTiens'] as List<dynamic>?)
              ?.map((e) => GiaLuyTien.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      giaKhungGios: (json['giaKhungGios'] as List<dynamic>?)
              ?.map((e) => GiaKhungGio.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      giaLoaiCanHos: (json['giaLoaiCanHos'] as List<dynamic>?)
              ?.map((e) => GiaLoaiCanHo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class GiaLuyTien {
  final int id;
  final int bangGiaId;
  final double tuMuc;
  final double? denMuc;
  final double donGia;

  const GiaLuyTien({
    required this.id,
    required this.bangGiaId,
    required this.tuMuc,
    this.denMuc,
    required this.donGia,
  });

  factory GiaLuyTien.fromJson(Map<String, dynamic> json) => GiaLuyTien(
        id: json['id'] as int,
        bangGiaId: json['bangGiaId'] as int,
        tuMuc: (json['tuMuc'] as num).toDouble(),
        denMuc: (json['denMuc'] as num?)?.toDouble(),
        donGia: (json['donGia'] as num).toDouble(),
      );
}

class GiaKhungGio {
  final int id;
  final int bangGiaId;
  final int khungGioId;
  final String tenKhungGio;
  final double donGia;

  const GiaKhungGio({
    required this.id,
    required this.bangGiaId,
    required this.khungGioId,
    required this.tenKhungGio,
    required this.donGia,
  });

  factory GiaKhungGio.fromJson(Map<String, dynamic> json) => GiaKhungGio(
        id: json['id'] as int,
        bangGiaId: json['bangGiaId'] as int,
        khungGioId: json['khungGioId'] as int,
        tenKhungGio: json['tenKhungGio'] as String? ?? '',
        donGia: (json['donGia'] as num).toDouble(),
      );
}

class GiaLoaiCanHo {
  final int id;
  final int bangGiaId;
  final int loaiCanHoId;
  final String loaiCanHoTen;
  final double donGia;

  const GiaLoaiCanHo({
    required this.id,
    required this.bangGiaId,
    required this.loaiCanHoId,
    required this.loaiCanHoTen,
    required this.donGia,
  });

  factory GiaLoaiCanHo.fromJson(Map<String, dynamic> json) => GiaLoaiCanHo(
        id: json['id'] as int,
        bangGiaId: json['bangGiaId'] as int,
        loaiCanHoId: json['loaiCanHoId'] as int,
        loaiCanHoTen: json['loaiCanHoTen'] as String? ?? '',
        donGia: (json['donGia'] as num).toDouble(),
      );
}

// ─────────────────────────────────────────────
// PagingInfo
// ─────────────────────────────────────────────

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
        pageSize: json['pageSize'] as int? ?? 10,
        pageNumber: json['pageNumber'] as int? ?? 1,
        totalItems: json['totalItems'] as int? ?? 0,
      );

  bool get hasNextPage => pageNumber * pageSize < totalItems;
}

class PagedResult<T> {
  final List<T> items;
  final PagingInfo pagingInfo;

  const PagedResult({required this.items, required this.pagingInfo});
}