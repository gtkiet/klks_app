// lib/features/tien_ich/dich_vu/models/dich_vu_model.dart

import 'bang_gia_model.dart';
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

  bool get isHoatDong => trangThaiDichVuId == 1;
  String get displayName => '$maDichVu - $tenDichVu';

  factory DichVuItem.fromJson(Map<String, dynamic> json) => DichVuItem(
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
  }) => DichVuItem(
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

// ─────────────────────────────────────────────
// Detail model — dùng cho get-by-id
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

  factory DichVuDetail.fromJson(Map<String, dynamic> json) => DichVuDetail(
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
    khungGioDichVu:
        (json['khungGioDichVu'] as List<dynamic>?)
            ?.map((e) => KhungGioItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    bangGia: json['bangGia'] != null
        ? BangGia.fromJson(json['bangGia'] as Map<String, dynamic>)
        : null,
  );
}
