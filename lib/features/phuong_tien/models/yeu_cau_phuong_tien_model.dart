// lib/features/phuong_tien/models/yeu_cau_phuong_tien_model.dart

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
