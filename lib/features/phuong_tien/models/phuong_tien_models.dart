// lib/features/phuong_tien/models/phuong_tien_models.dart

// ---------------------------------------------------------------------------
// CATALOG
// ---------------------------------------------------------------------------

class SelectorItem {
  final int id;
  final String name;

  const SelectorItem({required this.id, required this.name});

  factory SelectorItem.fromJson(Map<String, dynamic> json) =>
      SelectorItem(id: json['id'] as int, name: json['name'] as String);

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

// ---------------------------------------------------------------------------
// QUAN HE CU TRU
// ---------------------------------------------------------------------------

class QuanHeCuTru {
  final int quanHeCuTruId;
  final int loaiQuanHeCuTruId;
  final String loaiQuanHeTen;
  final DateTime? ngayBatDau;
  final int toaNhaId;
  final String maToaNha;
  final String tenToaNha;
  final int tangId;
  final String maTang;
  final String tenTang;
  final int canHoId;
  final String maCanHo;
  final String tenCanHo;
  final int tongCuDan;

  const QuanHeCuTru({
    required this.quanHeCuTruId,
    required this.loaiQuanHeCuTruId,
    required this.loaiQuanHeTen,
    this.ngayBatDau,
    required this.toaNhaId,
    required this.maToaNha,
    required this.tenToaNha,
    required this.tangId,
    required this.maTang,
    required this.tenTang,
    required this.canHoId,
    required this.maCanHo,
    required this.tenCanHo,
    required this.tongCuDan,
  });

  /// Địa chỉ đầy đủ dạng "Tòa A - Tầng 3 - Căn 301"
  String get diaChiDayDu => '$tenToaNha - $tenTang - $tenCanHo';

  factory QuanHeCuTru.fromJson(Map<String, dynamic> json) => QuanHeCuTru(
    quanHeCuTruId: json['quanHeCuTruId'] as int,
    loaiQuanHeCuTruId: json['loaiQuanHeCuTruId'] as int,
    loaiQuanHeTen: json['loaiQuanHeTen'] as String,
    ngayBatDau: json['ngayBatDau'] != null
        ? DateTime.tryParse(json['ngayBatDau'] as String)
        : null,
    toaNhaId: json['toaNhaId'] as int,
    maToaNha: json['maToaNha'] as String,
    tenToaNha: json['tenToaNha'] as String,
    tangId: json['tangId'] as int,
    maTang: json['maTang'] as String,
    tenTang: json['tenTang'] as String,
    canHoId: json['canHoId'] as int,
    maCanHo: json['maCanHo'] as String,
    tenCanHo: json['tenCanHo'] as String,
    tongCuDan: json['tongCuDan'] as int,
  );

  Map<String, dynamic> toJson() => {
    'quanHeCuTruId': quanHeCuTruId,
    'loaiQuanHeCuTruId': loaiQuanHeCuTruId,
    'loaiQuanHeTen': loaiQuanHeTen,
    'ngayBatDau': ngayBatDau?.toIso8601String(),
    'toaNhaId': toaNhaId,
    'maToaNha': maToaNha,
    'tenToaNha': tenToaNha,
    'tangId': tangId,
    'maTang': maTang,
    'tenTang': tenTang,
    'canHoId': canHoId,
    'maCanHo': maCanHo,
    'tenCanHo': tenCanHo,
    'tongCuDan': tongCuDan,
  };

  QuanHeCuTru copyWith({
    int? quanHeCuTruId,
    int? loaiQuanHeCuTruId,
    String? loaiQuanHeTen,
    DateTime? ngayBatDau,
    int? toaNhaId,
    String? maToaNha,
    String? tenToaNha,
    int? tangId,
    String? maTang,
    String? tenTang,
    int? canHoId,
    String? maCanHo,
    String? tenCanHo,
    int? tongCuDan,
  }) => QuanHeCuTru(
    quanHeCuTruId: quanHeCuTruId ?? this.quanHeCuTruId,
    loaiQuanHeCuTruId: loaiQuanHeCuTruId ?? this.loaiQuanHeCuTruId,
    loaiQuanHeTen: loaiQuanHeTen ?? this.loaiQuanHeTen,
    ngayBatDau: ngayBatDau ?? this.ngayBatDau,
    toaNhaId: toaNhaId ?? this.toaNhaId,
    maToaNha: maToaNha ?? this.maToaNha,
    tenToaNha: tenToaNha ?? this.tenToaNha,
    tangId: tangId ?? this.tangId,
    maTang: maTang ?? this.maTang,
    tenTang: tenTang ?? this.tenTang,
    canHoId: canHoId ?? this.canHoId,
    maCanHo: maCanHo ?? this.maCanHo,
    tenCanHo: tenCanHo ?? this.tenCanHo,
    tongCuDan: tongCuDan ?? this.tongCuDan,
  );
}

// ---------------------------------------------------------------------------
// PHUONG TIEN
// ---------------------------------------------------------------------------

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

  /// Thông tin vị trí ngắn gọn: "A-T3-301"
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
// PAGING
// ---------------------------------------------------------------------------

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

  int get totalPages => pageSize > 0 ? (totalItems / pageSize).ceil() : 0;
  bool get hasNextPage => pageNumber < totalPages;
}

class PagedResult<T> {
  final List<T> items;
  final PagingInfo pagingInfo;

  const PagedResult({required this.items, required this.pagingInfo});
}

// ---------------------------------------------------------------------------
// YEU CAU PHUONG TIEN
// ---------------------------------------------------------------------------

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

  /// Địa chỉ căn hộ đầy đủ
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

// ---------------------------------------------------------------------------
// UPLOAD MEDIA
// ---------------------------------------------------------------------------

class UploadedFile {
  final int fileId;
  final String fileName;
  final String fileUrl;
  final String contentType;

  const UploadedFile({
    required this.fileId,
    required this.fileName,
    required this.fileUrl,
    required this.contentType,
  });

  factory UploadedFile.fromJson(Map<String, dynamic> json) => UploadedFile(
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

// ---------------------------------------------------------------------------
// REQUEST MODELS (body gửi lên)
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
  final bool? isAsc;

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
    this.isAsc,
  });

  Map<String, dynamic> toJson() => {
    'pageNumber': pageNumber,
    'pageSize': pageSize,
    if (toaNhaId != null) 'toaNhaId': toaNhaId,
    if (tangId != null) 'tangId': tangId,
    if (canHoId != null) 'canHoId': canHoId,
    if (keyword != null && keyword!.isNotEmpty) 'keyword': keyword,
    if (loaiPhuongTienId != null) 'loaiPhuongTienId': loaiPhuongTienId,
    if (mauXe != null && mauXe!.isNotEmpty) 'mauXe': mauXe,
    if (trangThaiPhuongTienId != null)
      'trangThaiPhuongTienId': trangThaiPhuongTienId,
    if (sortCol != null) 'sortCol': sortCol,
    if (isAsc != null) 'isAsc': isAsc,
  };
}

class TaoYeuCauRequest {
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

  const TaoYeuCauRequest({
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

class CapNhatYeuCauRequest {
  final int id;
  final bool isSubmit;
  final bool isWithdraw;
  final int? loaiPhuongTienId;
  final String? yeuCauTenPhuongTien;
  final String? yeuCauBienSo;
  final String? yeuCauMauXe;
  final String? noiDung;
  final List<int>? fileIds;

  const CapNhatYeuCauRequest({
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
