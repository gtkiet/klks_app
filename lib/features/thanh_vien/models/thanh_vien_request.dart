// lib/features/thanh_vien/models/thanh_vien_request.dart

import 'tai_lieu_cu_tru_request.dart';

// =============================================================================
// REQUEST MODELS
// =============================================================================

class GetListYeuCauCuTruRequest {
  final int pageNumber;
  final int pageSize;
  final int? toaNhaId;
  final int? tangId;
  final int? canHoId;
  final int? loaiYeuCauId;
  final int? trangThaiId;
  final String? sortCol;
  final bool isAsc;

  const GetListYeuCauCuTruRequest({
    required this.pageNumber,
    required this.pageSize,
    this.toaNhaId,
    this.tangId,
    this.canHoId,
    this.loaiYeuCauId,
    this.trangThaiId,
    this.sortCol,
    this.isAsc = true,
  });

  Map<String, dynamic> toJson() => {
    'pageNumber': pageNumber,
    'pageSize': pageSize,
    'isAsc': isAsc,
    if (toaNhaId != null) 'toaNhaId': toaNhaId,
    if (tangId != null) 'tangId': tangId,
    if (canHoId != null) 'canHoId': canHoId,
    if (loaiYeuCauId != null) 'loaiYeuCauId': loaiYeuCauId,
    if (trangThaiId != null) 'trangThaiId': trangThaiId,
    if (sortCol != null) 'sortCol': sortCol,
  };
}

class TaoYeuCauCuTruRequest {
  final int canHoId;
  final int loaiYeuCauId;
  final bool isSubmit;
  final int? targetQuanHeCuTruId;
  final String? firstName;
  final String? lastName;
  final int? gioiTinhId;
  final DateTime? dob;
  final String? cccd;
  final String? phoneNumber;
  final String? diaChi;
  final int? loaiQuanHeId;
  final String? noiDung;
  final List<TaiLieuCuTruRequest>? taiLieuCuTrus;

  const TaoYeuCauCuTruRequest({
    required this.canHoId,
    required this.loaiYeuCauId,
    this.isSubmit = false,
    this.targetQuanHeCuTruId,
    this.firstName,
    this.lastName,
    this.gioiTinhId,
    this.dob,
    this.cccd,
    this.phoneNumber,
    this.diaChi,
    this.loaiQuanHeId,
    this.noiDung,
    this.taiLieuCuTrus,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'canHoId': canHoId,
      'loaiYeuCauId': loaiYeuCauId,
      'isSubmit': isSubmit,
      if (targetQuanHeCuTruId != null)
        'targetQuanHeCuTruId': targetQuanHeCuTruId,
      if (firstName != null && firstName!.isNotEmpty) 'firstName': firstName,
      if (lastName != null && lastName!.isNotEmpty) 'lastName': lastName,
      if (gioiTinhId != null) 'gioiTinhId': gioiTinhId,
      if (dob != null) 'dob': dob!.toIso8601String(),
      if (cccd != null && cccd!.isNotEmpty) 'cccd': cccd,
      if (phoneNumber != null && phoneNumber!.isNotEmpty)
        'phoneNumber': phoneNumber,
      if (diaChi != null && diaChi!.isNotEmpty) 'diaChi': diaChi,
      if (loaiQuanHeId != null) 'loaiQuanHeId': loaiQuanHeId,
      if (noiDung != null && noiDung!.isNotEmpty) 'noiDung': noiDung,
    };
    _attachTaiLieu(map, taiLieuCuTrus);
    return map;
  }
}

class CapNhatYeuCauCuTruRequest {
  final int id;
  final bool isSubmit;
  final bool isWithdraw;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final DateTime? dob;
  final int? gioiTinhId;
  final String? cccd;
  final String? diaChi;
  final int? loaiQuanHeId;
  final String? noiDung;
  final List<TaiLieuCuTruRequest>? taiLieuCuTrus;

  const CapNhatYeuCauCuTruRequest({
    required this.id,
    this.isSubmit = false,
    this.isWithdraw = false,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.dob,
    this.gioiTinhId,
    this.cccd,
    this.diaChi,
    this.loaiQuanHeId,
    this.noiDung,
    this.taiLieuCuTrus,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'isSubmit': isSubmit,
      'isWithdraw': isWithdraw,
      if (firstName != null && firstName!.isNotEmpty) 'firstName': firstName,
      if (lastName != null && lastName!.isNotEmpty) 'lastName': lastName,
      if (phoneNumber != null && phoneNumber!.isNotEmpty)
        'phoneNumber': phoneNumber,
      if (dob != null) 'dob': dob!.toIso8601String(),
      if (gioiTinhId != null) 'gioiTinhId': gioiTinhId,
      if (cccd != null && cccd!.isNotEmpty) 'cccd': cccd,
      if (diaChi != null && diaChi!.isNotEmpty) 'diaChi': diaChi,
      if (loaiQuanHeId != null) 'loaiQuanHeId': loaiQuanHeId,
      if (noiDung != null && noiDung!.isNotEmpty) 'noiDung': noiDung,
    };
    _attachTaiLieu(map, taiLieuCuTrus);
    return map;
  }
}

void _attachTaiLieu(
  Map<String, dynamic> map,
  List<TaiLieuCuTruRequest>? taiLieuCuTrus,
) {
  if (taiLieuCuTrus == null || taiLieuCuTrus.isEmpty) return;
  final valid = taiLieuCuTrus
      .where((t) => t.fileIds.isNotEmpty)
      .map((t) => t.toJson())
      .toList();
  if (valid.isNotEmpty) map['taiLieuCuTrus'] = valid;
}
