// lib/features/phuong_tien/models/phuong_tien_request_models.dart

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
