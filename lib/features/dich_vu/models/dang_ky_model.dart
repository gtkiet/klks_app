// lib/features/dich_vu/models/dang_ky_model.dart

class DichVuDangKyItem {
  final int id;
  final int canHoId;
  final int dichVuId;
  final String maDichVu;
  final String tenDichVu;
  final int loaiDichVuId;
  final String loaiDichVuTen;
  final int soLuong;
  final DateTime? ngayBatDau;
  final DateTime? ngayKetThuc;
  final int trangThaiDangKyId;
  final String trangThaiDangKyTen;

  const DichVuDangKyItem({
    required this.id,
    required this.canHoId,
    required this.dichVuId,
    required this.maDichVu,
    required this.tenDichVu,
    required this.loaiDichVuId,
    required this.loaiDichVuTen,
    required this.soLuong,
    this.ngayBatDau,
    this.ngayKetThuc,
    required this.trangThaiDangKyId,
    required this.trangThaiDangKyTen,
  });

  /// Còn hiệu lực nếu ngayKetThuc chưa qua hoặc chưa set
  bool get isActive {
    if (ngayKetThuc == null) return true;
    return ngayKetThuc!.isAfter(DateTime.now());
  }

  /// Khoảng thời gian dạng "dd/MM/yyyy → dd/MM/yyyy"
  String get thoiGianHienThi {
    String fmt(DateTime? d) => d == null
        ? 'N/A'
        : '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    return '${fmt(ngayBatDau)} → ${fmt(ngayKetThuc)}';
  }

  factory DichVuDangKyItem.fromJson(Map<String, dynamic> json) =>
      DichVuDangKyItem(
        id: json['id'] as int? ?? 0,
        canHoId: json['canHoId'] as int? ?? 0,
        dichVuId: json['dichVuId'] as int? ?? 0,
        maDichVu: json['maDichVu'] as String? ?? '',
        tenDichVu: json['tenDichVu'] as String? ?? '',
        loaiDichVuId: json['loaiDichVuId'] as int? ?? 0,
        loaiDichVuTen: json['loaiDichVuTen'] as String? ?? '',
        soLuong: json['soLuong'] as int? ?? 0,
        ngayBatDau: json['ngayBatDau'] != null
            ? DateTime.tryParse(json['ngayBatDau'] as String)
            : null,
        ngayKetThuc: json['ngayKetThuc'] != null
            ? DateTime.tryParse(json['ngayKetThuc'] as String)
            : null,
        trangThaiDangKyId: json['trangThaiDangKyId'] as int? ?? 0,
        trangThaiDangKyTen: json['trangThaiDangKyTen'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'canHoId': canHoId,
    'dichVuId': dichVuId,
    'maDichVu': maDichVu,
    'tenDichVu': tenDichVu,
    'loaiDichVuId': loaiDichVuId,
    'loaiDichVuTen': loaiDichVuTen,
    'soLuong': soLuong,
    'ngayBatDau': ngayBatDau?.toIso8601String(),
    'ngayKetThuc': ngayKetThuc?.toIso8601String(),
    'trangThaiDangKyId': trangThaiDangKyId,
    'trangThaiDangKyTen': trangThaiDangKyTen,
  };

  DichVuDangKyItem copyWith({
    int? id,
    int? canHoId,
    int? dichVuId,
    String? maDichVu,
    String? tenDichVu,
    int? loaiDichVuId,
    String? loaiDichVuTen,
    int? soLuong,
    DateTime? ngayBatDau,
    DateTime? ngayKetThuc,
    int? trangThaiDangKyId,
    String? trangThaiDangKyTen,
  }) => DichVuDangKyItem(
    id: id ?? this.id,
    canHoId: canHoId ?? this.canHoId,
    dichVuId: dichVuId ?? this.dichVuId,
    maDichVu: maDichVu ?? this.maDichVu,
    tenDichVu: tenDichVu ?? this.tenDichVu,
    loaiDichVuId: loaiDichVuId ?? this.loaiDichVuId,
    loaiDichVuTen: loaiDichVuTen ?? this.loaiDichVuTen,
    soLuong: soLuong ?? this.soLuong,
    ngayBatDau: ngayBatDau ?? this.ngayBatDau,
    ngayKetThuc: ngayKetThuc ?? this.ngayKetThuc,
    trangThaiDangKyId: trangThaiDangKyId ?? this.trangThaiDangKyId,
    trangThaiDangKyTen: trangThaiDangKyTen ?? this.trangThaiDangKyTen,
  );
}

// ─────────────────────────────────────────────

class DichVuDangKyRequest {
  final int? loaiDichVuId;
  final int? dichVuId;
  final int? trangThaiDangKyId;
  final DateTime? tuNgay;
  final DateTime? denNgay;
  final String? keyword;
  final int pageNumber;
  final int pageSize;
  final String sortCol;
  final bool isAsc;

  const DichVuDangKyRequest({
    this.loaiDichVuId,
    this.dichVuId,
    this.trangThaiDangKyId,
    this.tuNgay,
    this.denNgay,
    this.keyword,
    this.pageNumber = 1,
    this.pageSize = 20,
    this.sortCol = 'id',
    this.isAsc = false,
  });

  /// Preset: lấy dịch vụ tiện ích (loaiDichVuId = 3)
  factory DichVuDangKyRequest.tienIch({
    int pageNumber = 1,
    int pageSize = 20,
  }) => DichVuDangKyRequest(
    loaiDichVuId: 3,
    pageNumber: pageNumber,
    pageSize: pageSize,
  );

  Map<String, dynamic> toJson() => {
    if (loaiDichVuId != null) 'loaiDichVuId': loaiDichVuId,
    if (dichVuId != null) 'dichVuId': dichVuId,
    if (trangThaiDangKyId != null) 'trangThaiDangKyId': trangThaiDangKyId,
    if (tuNgay != null) 'tuNgay': tuNgay!.toIso8601String(),
    if (denNgay != null) 'denNgay': denNgay!.toIso8601String(),
    if (keyword != null && keyword!.isNotEmpty) 'keyword': keyword,
    'pageNumber': pageNumber,
    'pageSize': pageSize,
    'sortCol': sortCol,
    'isAsc': isAsc,
  };

  DichVuDangKyRequest copyWith({
    int? loaiDichVuId,
    int? dichVuId,
    int? trangThaiDangKyId,
    DateTime? tuNgay,
    DateTime? denNgay,
    String? keyword,
    int? pageNumber,
    int? pageSize,
    String? sortCol,
    bool? isAsc,
  }) => DichVuDangKyRequest(
    loaiDichVuId: loaiDichVuId ?? this.loaiDichVuId,
    dichVuId: dichVuId ?? this.dichVuId,
    trangThaiDangKyId: trangThaiDangKyId ?? this.trangThaiDangKyId,
    tuNgay: tuNgay ?? this.tuNgay,
    denNgay: denNgay ?? this.denNgay,
    keyword: keyword ?? this.keyword,
    pageNumber: pageNumber ?? this.pageNumber,
    pageSize: pageSize ?? this.pageSize,
    sortCol: sortCol ?? this.sortCol,
    isAsc: isAsc ?? this.isAsc,
  );
}
