// lib/features/cu_tru/phuong_tien/models/phuong_tien_model.dart
//
// ThePhuongTien và HinhAnhPhuongTien giữ cùng file —
// cả hai là nested data của PhuongTien, không dùng độc lập.

// ── Nested: thẻ phương tiện ───────────────────────────────────────────────────

class ThePhuongTien {
  final int id;
  final int phuongTienId;
  final String maThe;
  final DateTime? ngayBatDau;
  final DateTime? ngayKetThuc;
  final int trangThaiThePhuongTienId;
  final String tenTrangThaiThePhuongTien;

  const ThePhuongTien({
    required this.id,
    required this.phuongTienId,
    required this.maThe,
    this.ngayBatDau,
    this.ngayKetThuc,
    required this.trangThaiThePhuongTienId,
    required this.tenTrangThaiThePhuongTien,
  });

  factory ThePhuongTien.fromJson(Map<String, dynamic> json) => ThePhuongTien(
    id: json['id'] as int,
    phuongTienId: json['phuongTienId'] as int,
    maThe: json['maThe'] as String,
    ngayBatDau: json['ngayBatDau'] != null
        ? DateTime.tryParse(json['ngayBatDau'] as String)
        : null,
    ngayKetThuc: json['ngayKetThuc'] != null
        ? DateTime.tryParse(json['ngayKetThuc'] as String)
        : null,
    trangThaiThePhuongTienId: json['trangThaiThePhuongTienId'] as int,
    tenTrangThaiThePhuongTien: json['tenTrangThaiThePhuongTien'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'phuongTienId': phuongTienId,
    'maThe': maThe,
    'ngayBatDau': ngayBatDau?.toIso8601String(),
    'ngayKetThuc': ngayKetThuc?.toIso8601String(),
    'trangThaiThePhuongTienId': trangThaiThePhuongTienId,
    'tenTrangThaiThePhuongTien': tenTrangThaiThePhuongTien,
  };

  ThePhuongTien copyWith({
    int? id,
    int? phuongTienId,
    String? maThe,
    DateTime? ngayBatDau,
    DateTime? ngayKetThuc,
    int? trangThaiThePhuongTienId,
    String? tenTrangThaiThePhuongTien,
  }) => ThePhuongTien(
    id: id ?? this.id,
    phuongTienId: phuongTienId ?? this.phuongTienId,
    maThe: maThe ?? this.maThe,
    ngayBatDau: ngayBatDau ?? this.ngayBatDau,
    ngayKetThuc: ngayKetThuc ?? this.ngayKetThuc,
    trangThaiThePhuongTienId:
        trangThaiThePhuongTienId ?? this.trangThaiThePhuongTienId,
    tenTrangThaiThePhuongTien:
        tenTrangThaiThePhuongTien ?? this.tenTrangThaiThePhuongTien,
  );
}

// ── Nested: hình ảnh phương tiện ─────────────────────────────────────────────

class HinhAnhPhuongTien {
  final int fileId;
  final String fileName;
  final String fileUrl;
  final String contentType;

  const HinhAnhPhuongTien({
    required this.fileId,
    required this.fileName,
    required this.fileUrl,
    required this.contentType,
  });

  bool get isImage => contentType.startsWith('image/');

  factory HinhAnhPhuongTien.fromJson(Map<String, dynamic> json) =>
      HinhAnhPhuongTien(
        fileId: json['fileId'] as int,
        fileName: json['fileName'] as String,
        fileUrl: json['fileUrl'] as String,
        contentType: json['contentType'] as String,
      );

  Map<String, dynamic> toJson() => {
    'fileId': fileId,
    'fileName': fileName,
    'fileUrl': fileUrl,
    'contentType': contentType,
  };
}

// ── Root model ────────────────────────────────────────────────────────────────

class PhuongTien {
  final int id;
  final int canHoId;
  final String maToaNha;
  final String maTang;
  final String maCanHo;
  final String tenPhuongTien;
  final int loaiPhuongTienId;
  final String tenLoaiPhuongTien;
  final String bienSo;
  final String mauXe;
  final int trangThaiPhuongTienId;
  final String tenTrangThaiPhuongTien;
  final List<ThePhuongTien> thePhuongTiens;
  final List<HinhAnhPhuongTien> hinhAnhPhuongTiens;

  const PhuongTien({
    required this.id,
    required this.canHoId,
    required this.maToaNha,
    required this.maTang,
    required this.maCanHo,
    required this.tenPhuongTien,
    required this.loaiPhuongTienId,
    required this.tenLoaiPhuongTien,
    required this.bienSo,
    required this.mauXe,
    required this.trangThaiPhuongTienId,
    required this.tenTrangThaiPhuongTien,
    required this.thePhuongTiens,
    required this.hinhAnhPhuongTiens,
  });

  String get viTriNgan => '$maToaNha-$maTang-$maCanHo';

  factory PhuongTien.fromJson(Map<String, dynamic> json) => PhuongTien(
    id: json['id'] as int,
    canHoId: json['canHoId'] as int,
    maToaNha: json['maToaNha'] as String,
    maTang: json['maTang'] as String,
    maCanHo: json['maCanHo'] as String,
    tenPhuongTien: json['tenPhuongTien'] as String,
    loaiPhuongTienId: json['loaiPhuongTienId'] as int,
    tenLoaiPhuongTien: json['tenLoaiPhuongTien'] as String,
    bienSo: json['bienSo'] as String,
    mauXe: json['mauXe'] as String,
    trangThaiPhuongTienId: json['trangThaiPhuongTienId'] as int,
    tenTrangThaiPhuongTien: json['tenTrangThaiPhuongTien'] as String,
    thePhuongTiens: (json['thePhuongTiens'] as List<dynamic>? ?? [])
        .map((e) => ThePhuongTien.fromJson(e as Map<String, dynamic>))
        .toList(),
    hinhAnhPhuongTiens: (json['hinhAnhPhuongTiens'] as List<dynamic>? ?? [])
        .map((e) => HinhAnhPhuongTien.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'canHoId': canHoId,
    'maToaNha': maToaNha,
    'maTang': maTang,
    'maCanHo': maCanHo,
    'tenPhuongTien': tenPhuongTien,
    'loaiPhuongTienId': loaiPhuongTienId,
    'tenLoaiPhuongTien': tenLoaiPhuongTien,
    'bienSo': bienSo,
    'mauXe': mauXe,
    'trangThaiPhuongTienId': trangThaiPhuongTienId,
    'tenTrangThaiPhuongTien': tenTrangThaiPhuongTien,
    'thePhuongTiens': thePhuongTiens.map((e) => e.toJson()).toList(),
    'hinhAnhPhuongTiens': hinhAnhPhuongTiens.map((e) => e.toJson()).toList(),
  };

  PhuongTien copyWith({
    int? id,
    int? canHoId,
    String? maToaNha,
    String? maTang,
    String? maCanHo,
    String? tenPhuongTien,
    int? loaiPhuongTienId,
    String? tenLoaiPhuongTien,
    String? bienSo,
    String? mauXe,
    int? trangThaiPhuongTienId,
    String? tenTrangThaiPhuongTien,
    List<ThePhuongTien>? thePhuongTiens,
    List<HinhAnhPhuongTien>? hinhAnhPhuongTiens,
  }) => PhuongTien(
    id: id ?? this.id,
    canHoId: canHoId ?? this.canHoId,
    maToaNha: maToaNha ?? this.maToaNha,
    maTang: maTang ?? this.maTang,
    maCanHo: maCanHo ?? this.maCanHo,
    tenPhuongTien: tenPhuongTien ?? this.tenPhuongTien,
    loaiPhuongTienId: loaiPhuongTienId ?? this.loaiPhuongTienId,
    tenLoaiPhuongTien: tenLoaiPhuongTien ?? this.tenLoaiPhuongTien,
    bienSo: bienSo ?? this.bienSo,
    mauXe: mauXe ?? this.mauXe,
    trangThaiPhuongTienId: trangThaiPhuongTienId ?? this.trangThaiPhuongTienId,
    tenTrangThaiPhuongTien:
        tenTrangThaiPhuongTien ?? this.tenTrangThaiPhuongTien,
    thePhuongTiens: thePhuongTiens ?? this.thePhuongTiens,
    hinhAnhPhuongTiens: hinhAnhPhuongTiens ?? this.hinhAnhPhuongTiens,
  );
}


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

  int get totalPages => pageSize > 0 ? (totalItems / pageSize).ceil() : 0;
  bool get hasNextPage => pageNumber < totalPages;
  bool get isLastPage => !hasNextPage;
}

// PagedResult giữ cùng file với PagingInfo —
// hai class này không có ý nghĩa khi tách riêng.
class PagedResult<T> {
  final List<T> items;
  final PagingInfo pagingInfo;

  const PagedResult({required this.items, required this.pagingInfo});

  factory PagedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) => PagedResult(
    items: (json['items'] as List<dynamic>? ?? [])
        .map((e) => fromJson(e as Map<String, dynamic>))
        .toList(),
    pagingInfo: PagingInfo.fromJson(
      json['pagingInfo'] as Map<String, dynamic>? ?? {},
    ),
  );
}
