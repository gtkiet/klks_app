// lib/features/cu_tru/phuong_tien/models/phuong_tien_model.dart

// TODO: gọi lib/features/cu_tru/models/quan_he_cu_tru_model.dart để lấy data địa chỉ đầy đủ thay vì chỉ mã tòa nhà, mã tầng, mã căn hộ

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

// ---------------------------------------------------------------------------
// REQUEST MODELS
// ---------------------------------------------------------------------------

class GetListPhuongTienRequest {
  final int pageNumber;
  final int pageSize;
  final int? toaNhaId;
  final int? tangId;
  final int? canHoId;
  final String? keyword;
  final int? loaiPhuongTienId;
  final String? mauXe;
  final int? trangThaiPhuongTienId;
  final String? sortCol;
  final bool isAsc;

  const GetListPhuongTienRequest({
    required this.pageNumber,
    required this.pageSize,
    this.toaNhaId,
    this.tangId,
    this.canHoId,
    this.keyword,
    this.loaiPhuongTienId,
    this.mauXe,
    this.trangThaiPhuongTienId,
    this.sortCol,
    this.isAsc = false,
  });

  Map<String, dynamic> toJson() => {
    'pageNumber': pageNumber,
    'pageSize': pageSize,
    'isAsc': isAsc,
    if (toaNhaId != null) 'toaNhaId': toaNhaId,
    if (tangId != null) 'tangId': tangId,
    if (canHoId != null) 'canHoId': canHoId,
    if (keyword != null && keyword!.isNotEmpty) 'keyword': keyword,
    if (loaiPhuongTienId != null) 'loaiPhuongTienId': loaiPhuongTienId,
    if (mauXe != null && mauXe!.isNotEmpty) 'mauXe': mauXe,
    if (trangThaiPhuongTienId != null)
      'trangThaiPhuongTienId': trangThaiPhuongTienId,
    if (sortCol != null) 'sortCol': sortCol,
  };
}

class GetListYeuCauPhuongTienRequest {
  final int pageNumber;
  final int pageSize;
  final int? toaNhaId;
  final int? tangId;
  final int? canHoId;
  final int? loaiYeuCauId;
  final int? trangThaiId;
  final String? keyword;
  final String? sortCol;
  final bool isAsc;

  const GetListYeuCauPhuongTienRequest({
    required this.pageNumber,
    required this.pageSize,
    this.toaNhaId,
    this.tangId,
    this.canHoId,
    this.loaiYeuCauId,
    this.trangThaiId,
    this.keyword,
    this.sortCol = 'createdAt',
    this.isAsc = false,
  });

  Map<String, dynamic> toJson() => {
    'pageNumber': pageNumber,
    'pageSize': pageSize,
    'isAsc': isAsc,
    'sortCol': sortCol,
    if (toaNhaId != null) 'toaNhaId': toaNhaId,
    if (tangId != null) 'tangId': tangId,
    if (canHoId != null) 'canHoId': canHoId,
    if (loaiYeuCauId != null) 'loaiYeuCauId': loaiYeuCauId,
    if (trangThaiId != null) 'trangThaiId': trangThaiId,
    if (keyword != null) 'keyword': keyword,
  };
}

class TaoYeuCauPhuongTienRequest {
  final int canHoId;
  final int loaiYeuCauId;
  final bool isSubmit;
  final int? yeuCauPhuongTienId;
  final int? yeuCauLoaiPhuongTienId;
  final String? yeuCauTenPhuongTien;
  final String? yeuCauBienSo;
  final String? yeuCauMauXe;
  final String? noiDung;
  final List<int>? fileIds;

  const TaoYeuCauPhuongTienRequest({
    required this.canHoId,
    required this.loaiYeuCauId,
    required this.isSubmit,
    this.yeuCauPhuongTienId,
    this.yeuCauLoaiPhuongTienId,
    this.yeuCauTenPhuongTien,
    this.yeuCauBienSo,
    this.yeuCauMauXe,
    this.noiDung,
    this.fileIds,
  });

  Map<String, dynamic> toJson() => {
    'canHoId': canHoId,
    'loaiYeuCauId': loaiYeuCauId,
    'isSubmit': isSubmit,
    if (yeuCauPhuongTienId != null) 'yeuCauPhuongTienId': yeuCauPhuongTienId,
    if (yeuCauLoaiPhuongTienId != null)
      'yeuCauLoaiPhuongTienId': yeuCauLoaiPhuongTienId,
    if (yeuCauTenPhuongTien != null) 'yeuCauTenPhuongTien': yeuCauTenPhuongTien,
    if (yeuCauBienSo != null) 'yeuCauBienSo': yeuCauBienSo,
    if (yeuCauMauXe != null) 'yeuCauMauXe': yeuCauMauXe,
    if (noiDung != null) 'noiDung': noiDung,
    if (fileIds != null && fileIds!.isNotEmpty) 'fileIds': fileIds,
  };
}

class CapNhatYeuCauPhuongTienRequest {
  final int id;
  final bool isSubmit;
  final bool isWithdraw;
  final int? loaiPhuongTienId;
  final String? yeuCauTenPhuongTien;
  final String? yeuCauBienSo;
  final String? yeuCauMauXe;
  final String? noiDung;
  final List<int>? fileIds;

  const CapNhatYeuCauPhuongTienRequest({
    required this.id,
    this.isSubmit = false,
    this.isWithdraw = false,
    this.loaiPhuongTienId,
    this.yeuCauTenPhuongTien,
    this.yeuCauBienSo,
    this.yeuCauMauXe,
    this.noiDung,
    this.fileIds,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'isSubmit': isSubmit,
    'isWithdraw': isWithdraw,
    if (loaiPhuongTienId != null) 'loaiPhuongTienId': loaiPhuongTienId,
    if (yeuCauTenPhuongTien != null) 'yeuCauTenPhuongTien': yeuCauTenPhuongTien,
    if (yeuCauBienSo != null) 'yeuCauBienSo': yeuCauBienSo,
    if (yeuCauMauXe != null) 'yeuCauMauXe': yeuCauMauXe,
    if (noiDung != null) 'noiDung': noiDung,
    if (fileIds != null && fileIds!.isNotEmpty) 'fileIds': fileIds,
  };
}

// HinhAnhYeuCau giữ cùng file — chỉ là nested data của YeuCauPhuongTien.

class HinhAnhYeuCau {
  final int id;
  final String fileUrl;
  final String fileName;
  final String contentType;

  const HinhAnhYeuCau({
    required this.id,
    required this.fileUrl,
    required this.fileName,
    required this.contentType,
  });

  bool get isImage => contentType.startsWith('image/');

  factory HinhAnhYeuCau.fromJson(Map<String, dynamic> json) => HinhAnhYeuCau(
    id: json['id'] as int,
    fileUrl: json['fileUrl'] as String,
    fileName: json['fileName'] as String,
    contentType: json['contentType'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'fileUrl': fileUrl,
    'fileName': fileName,
    'contentType': contentType,
  };
}

class YeuCauPhuongTien {
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
  final int? phuongTienId;
  final int loaiYeuCauId;
  final String tenLoaiYeuCau;
  final int trangThaiId;
  final String tenTrangThai;
  final String? noiDung;
  final String? lyDo;
  final String? yeuCauTenPhuongTien;
  final int? yeuCauLoaiPhuongTienId;
  final String? tenYeuCauLoaiPhuongTien;
  final String? yeuCauBienSo;
  final String? yeuCauMauXe;
  final List<HinhAnhYeuCau> yeuCauHinhAnhPhuongTiens;

  const YeuCauPhuongTien({
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
    this.phuongTienId,
    required this.loaiYeuCauId,
    required this.tenLoaiYeuCau,
    required this.trangThaiId,
    required this.tenTrangThai,
    this.noiDung,
    this.lyDo,
    this.yeuCauTenPhuongTien,
    this.yeuCauLoaiPhuongTienId,
    this.tenYeuCauLoaiPhuongTien,
    this.yeuCauBienSo,
    this.yeuCauMauXe,
    this.yeuCauHinhAnhPhuongTiens = const [],
  });

  String get diaChiCanHo => '$tenToaNha - $tenTang - $tenCanHo';

  factory YeuCauPhuongTien.fromJson(Map<String, dynamic> json) =>
      YeuCauPhuongTien(
        id: json['id'] as int,
        createdBy: json['createdBy'] as int,
        tenNguoiGui: json['tenNguoiGui'] as String,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String)
            : null,
        canHoId: json['canHoId'] as int,
        tenCanHo: json['tenCanHo'] as String,
        tenTang: json['tenTang'] as String,
        tenToaNha: json['tenToaNha'] as String,
        nguoiXuLyId: json['nguoiXuLyId'] as int?,
        tenNguoiXuLy: json['tenNguoiXuLy'] as String?,
        ngayXuLy: json['ngayXuLy'] != null
            ? DateTime.tryParse(json['ngayXuLy'] as String)
            : null,
        phuongTienId: json['phuongTienId'] as int?,
        loaiYeuCauId: json['loaiYeuCauId'] as int,
        tenLoaiYeuCau: json['tenLoaiYeuCau'] as String,
        trangThaiId: json['trangThaiId'] as int,
        tenTrangThai: json['tenTrangThai'] as String,
        noiDung: json['noiDung'] as String?,
        lyDo: json['lyDo'] as String?,
        yeuCauTenPhuongTien: json['yeuCauTenPhuongTien'] as String?,
        yeuCauLoaiPhuongTienId: json['yeuCauLoaiPhuongTienId'] as int?,
        tenYeuCauLoaiPhuongTien: json['tenYeuCauLoaiPhuongTien'] as String?,
        yeuCauBienSo: json['yeuCauBienSo'] as String?,
        yeuCauMauXe: json['yeuCauMauXe'] as String?,
        yeuCauHinhAnhPhuongTiens:
            (json['yeuCauHinhAnhPhuongTiens'] as List<dynamic>? ?? [])
                .map((e) => HinhAnhYeuCau.fromJson(e as Map<String, dynamic>))
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
    'phuongTienId': phuongTienId,
    'loaiYeuCauId': loaiYeuCauId,
    'tenLoaiYeuCau': tenLoaiYeuCau,
    'trangThaiId': trangThaiId,
    'tenTrangThai': tenTrangThai,
    'noiDung': noiDung,
    'lyDo': lyDo,
    'yeuCauTenPhuongTien': yeuCauTenPhuongTien,
    'yeuCauLoaiPhuongTienId': yeuCauLoaiPhuongTienId,
    'tenYeuCauLoaiPhuongTien': tenYeuCauLoaiPhuongTien,
    'yeuCauBienSo': yeuCauBienSo,
    'yeuCauMauXe': yeuCauMauXe,
    'yeuCauHinhAnhPhuongTiens': yeuCauHinhAnhPhuongTiens
        .map((e) => e.toJson())
        .toList(),
  };

  YeuCauPhuongTien copyWith({
    int? id,
    int? createdBy,
    String? tenNguoiGui,
    DateTime? createdAt,
    int? canHoId,
    String? tenCanHo,
    String? tenTang,
    String? tenToaNha,
    int? nguoiXuLyId,
    String? tenNguoiXuLy,
    DateTime? ngayXuLy,
    int? phuongTienId,
    int? loaiYeuCauId,
    String? tenLoaiYeuCau,
    int? trangThaiId,
    String? tenTrangThai,
    String? noiDung,
    String? lyDo,
    String? yeuCauTenPhuongTien,
    int? yeuCauLoaiPhuongTienId,
    String? tenYeuCauLoaiPhuongTien,
    String? yeuCauBienSo,
    String? yeuCauMauXe,
    List<HinhAnhYeuCau>? yeuCauHinhAnhPhuongTiens,
  }) => YeuCauPhuongTien(
    id: id ?? this.id,
    createdBy: createdBy ?? this.createdBy,
    tenNguoiGui: tenNguoiGui ?? this.tenNguoiGui,
    createdAt: createdAt ?? this.createdAt,
    canHoId: canHoId ?? this.canHoId,
    tenCanHo: tenCanHo ?? this.tenCanHo,
    tenTang: tenTang ?? this.tenTang,
    tenToaNha: tenToaNha ?? this.tenToaNha,
    nguoiXuLyId: nguoiXuLyId ?? this.nguoiXuLyId,
    tenNguoiXuLy: tenNguoiXuLy ?? this.tenNguoiXuLy,
    ngayXuLy: ngayXuLy ?? this.ngayXuLy,
    phuongTienId: phuongTienId ?? this.phuongTienId,
    loaiYeuCauId: loaiYeuCauId ?? this.loaiYeuCauId,
    tenLoaiYeuCau: tenLoaiYeuCau ?? this.tenLoaiYeuCau,
    trangThaiId: trangThaiId ?? this.trangThaiId,
    tenTrangThai: tenTrangThai ?? this.tenTrangThai,
    noiDung: noiDung ?? this.noiDung,
    lyDo: lyDo ?? this.lyDo,
    yeuCauTenPhuongTien: yeuCauTenPhuongTien ?? this.yeuCauTenPhuongTien,
    yeuCauLoaiPhuongTienId:
        yeuCauLoaiPhuongTienId ?? this.yeuCauLoaiPhuongTienId,
    tenYeuCauLoaiPhuongTien:
        tenYeuCauLoaiPhuongTien ?? this.tenYeuCauLoaiPhuongTien,
    yeuCauBienSo: yeuCauBienSo ?? this.yeuCauBienSo,
    yeuCauMauXe: yeuCauMauXe ?? this.yeuCauMauXe,
    yeuCauHinhAnhPhuongTiens:
        yeuCauHinhAnhPhuongTiens ?? this.yeuCauHinhAnhPhuongTiens,
  );
}
