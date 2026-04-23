// lib/features/yeu_cau_sua_chua/models/yeu_cau_sua_chua_request.dart

class GetListYeuCauRequest {
  final int pageNumber;
  final int pageSize;
  final String sortCol;
  final bool isAsc;
  final int? canHoId;
  final int? trangThaiYeuCauId;
  final int? trangThaiSuaChuaId;
  final int? loaiSuCoId;
  final DateTime? ngayTaoTu;
  final DateTime? ngayTaoDen;

  const GetListYeuCauRequest({
    this.pageNumber = 1,
    this.pageSize = 10,
    this.sortCol = 'Created',
    this.isAsc = false,
    this.canHoId,
    this.trangThaiYeuCauId,
    this.trangThaiSuaChuaId,
    this.loaiSuCoId,
    this.ngayTaoTu,
    this.ngayTaoDen,
  });

  Map<String, dynamic> toJson() => {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
        'sortCol': sortCol,
        'isAsc': isAsc,
        'canHoId': canHoId,
        'trangThaiYeuCauId': trangThaiYeuCauId,
        'trangThaiSuaChuaId': trangThaiSuaChuaId,
        'loaiSuCoId': loaiSuCoId,
        'ngayTaoTu': ngayTaoTu?.toUtc().toIso8601String(),
        'ngayTaoDen': ngayTaoDen?.toUtc().toIso8601String(),
      };
}

class TaoYeuCauRequest {
  final int canHoId;
  final int phamViId;
  final int loaiSuCoId;
  final String noiDung;
  final String? moTaViTri;
  final List<int> danhSachTepIds;
  final bool isSubmit;

  const TaoYeuCauRequest({
    required this.canHoId,
    required this.phamViId,
    required this.loaiSuCoId,
    required this.noiDung,
    this.moTaViTri,
    this.danhSachTepIds = const [],
    required this.isSubmit,
  });

  Map<String, dynamic> toJson() => {
        'canHoId': canHoId,
        'phamViId': phamViId,
        'loaiSuCoId': loaiSuCoId,
        'noiDung': noiDung,
        'moTaViTri': moTaViTri,
        'danhSachTepIds': danhSachTepIds,
        'isSubmit': isSubmit,
      };
}

class CapNhatYeuCauRequest {
  final int id;
  final int phamViId;
  final int loaiSuCoId;
  final String noiDung;
  final String? moTaViTri;
  final List<int> danhSachTepIds;
  final bool isSubmit;
  final bool isWithdraw;

  const CapNhatYeuCauRequest({
    required this.id,
    required this.phamViId,
    required this.loaiSuCoId,
    required this.noiDung,
    this.moTaViTri,
    this.danhSachTepIds = const [],
    required this.isSubmit,
    this.isWithdraw = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'phamViId': phamViId,
        'loaiSuCoId': loaiSuCoId,
        'noiDung': noiDung,
        'moTaViTri': moTaViTri,
        'danhSachTepIds': danhSachTepIds,
        'isSubmit': isSubmit,
        'isWithdraw': isWithdraw,
      };
}