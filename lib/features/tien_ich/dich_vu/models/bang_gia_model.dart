// lib/features/dich_vu/models/bang_gia_model.dart

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

  factory BangGia.fromJson(Map<String, dynamic> json) => BangGia(
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
    giaLuyTiens:
        (json['giaLuyTiens'] as List<dynamic>?)
            ?.map((e) => GiaLuyTien.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    giaKhungGios:
        (json['giaKhungGios'] as List<dynamic>?)
            ?.map((e) => GiaKhungGio.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    giaLoaiCanHos:
        (json['giaLoaiCanHos'] as List<dynamic>?)
            ?.map((e) => GiaLoaiCanHo.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
  );
}

// ─────────────────────────────────────────────

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

// ─────────────────────────────────────────────

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

// ─────────────────────────────────────────────

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
