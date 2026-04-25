// lib/features/cu_tru/thanh_vien/models/thong_tin_cu_dan_model.dart
//
// TaiLieuFileModel và TaiLieuCuTruModel giữ cùng file này —
// cả hai chỉ được dùng như nested data của ThongTinCuDanModel,
// không có ý nghĩa độc lập.

// ── Nested: file đính kèm trong một tài liệu ─────────────────────────────────

class TaiLieuFileModel {
  final int id;
  final String fileUrl;
  final String fileName;
  final String contentType;

  const TaiLieuFileModel({
    required this.id,
    required this.fileUrl,
    required this.fileName,
    required this.contentType,
  });

  bool get isImage => contentType.startsWith('image/');
  bool get isPdf => contentType == 'application/pdf';

  factory TaiLieuFileModel.fromJson(Map<String, dynamic> json) =>
      TaiLieuFileModel(
        id: json['id'] as int? ?? 0,
        fileUrl: json['fileUrl'] as String? ?? '',
        fileName: json['fileName'] as String? ?? '',
        contentType: json['contentType'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'fileUrl': fileUrl,
    'fileName': fileName,
    'contentType': contentType,
  };
}

// ── Nested: một tài liệu cư trú (CMND, hộ khẩu…) ────────────────────────────

class TaiLieuCuTruModel {
  final int id;
  final int loaiGiayToId;
  final String tenLoaiGiayTo;
  final String soGiayTo;
  final DateTime? ngayPhatHanh;
  final int? targetTaiLieuCuTruId;
  final List<TaiLieuFileModel> files;

  const TaiLieuCuTruModel({
    required this.id,
    required this.loaiGiayToId,
    required this.tenLoaiGiayTo,
    required this.soGiayTo,
    this.ngayPhatHanh,
    this.targetTaiLieuCuTruId,
    required this.files,
  });

  factory TaiLieuCuTruModel.fromJson(Map<String, dynamic> json) =>
      TaiLieuCuTruModel(
        id: json['id'] as int? ?? 0,
        loaiGiayToId: json['loaiGiayToId'] as int? ?? 0,
        tenLoaiGiayTo: json['tenLoaiGiayTo'] as String? ?? '',
        soGiayTo: json['soGiayTo'] as String? ?? '',
        ngayPhatHanh: json['ngayPhatHanh'] != null
            ? DateTime.tryParse(json['ngayPhatHanh'] as String)
            : null,
        targetTaiLieuCuTruId: json['targetTaiLieuCuTruId'] as int?,
        files: (json['files'] as List<dynamic>? ?? [])
            .map((e) => TaiLieuFileModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'loaiGiayToId': loaiGiayToId,
    'tenLoaiGiayTo': tenLoaiGiayTo,
    'soGiayTo': soGiayTo,
    'ngayPhatHanh': ngayPhatHanh?.toIso8601String(),
    'targetTaiLieuCuTruId': targetTaiLieuCuTruId,
    'files': files.map((e) => e.toJson()).toList(),
  };
}

// ── Root model ────────────────────────────────────────────────────────────────

class ThongTinCuDanModel {
  final int userId;
  final String fullName;
  final String firstName;
  final String lastName;
  final int gioiTinhId;
  final String gioiTinhName;
  final DateTime? dob;
  final String? idCard;
  final String? phoneNumber;
  final String? diaChi;
  final String? anhDaiDienUrl;
  final int quanHeCuTruId;
  final int loaiQuanHeCuTruId;
  final String loaiQuanHeTen;
  final DateTime? ngayBatDau;
  final DateTime? ngayKetThuc;
  final int trangThaiCuTruId;
  final String trangThaiCuTruTen;
  final List<TaiLieuCuTruModel> taiLieuCuTrus;

  const ThongTinCuDanModel({
    required this.userId,
    required this.fullName,
    required this.firstName,
    required this.lastName,
    required this.gioiTinhId,
    required this.gioiTinhName,
    this.dob,
    this.idCard,
    this.phoneNumber,
    this.diaChi,
    this.anhDaiDienUrl,
    required this.quanHeCuTruId,
    required this.loaiQuanHeCuTruId,
    required this.loaiQuanHeTen,
    this.ngayBatDau,
    this.ngayKetThuc,
    required this.trangThaiCuTruId,
    required this.trangThaiCuTruTen,
    required this.taiLieuCuTrus,
  });

  factory ThongTinCuDanModel.fromJson(Map<String, dynamic> json) =>
      ThongTinCuDanModel(
        userId: json['userId'] as int? ?? 0,
        fullName: json['fullName'] as String? ?? '',
        firstName: json['firstName'] as String? ?? '',
        lastName: json['lastName'] as String? ?? '',
        gioiTinhId: json['gioiTinhId'] as int? ?? 0,
        gioiTinhName: json['gioiTinhName'] as String? ?? '',
        dob: json['dob'] != null
            ? DateTime.tryParse(json['dob'] as String)
            : null,
        idCard: json['idCard'] as String?,
        phoneNumber: json['phoneNumber'] as String?,
        diaChi: json['diaChi'] as String?,
        anhDaiDienUrl: json['anhDaiDienUrl'] as String?,
        quanHeCuTruId: json['quanHeCuTruId'] as int? ?? 0,
        loaiQuanHeCuTruId: json['loaiQuanHeCuTruId'] as int? ?? 0,
        loaiQuanHeTen: json['loaiQuanHeTen'] as String? ?? '',
        ngayBatDau: json['ngayBatDau'] != null
            ? DateTime.tryParse(json['ngayBatDau'] as String)
            : null,
        ngayKetThuc: json['ngayKetThuc'] != null
            ? DateTime.tryParse(json['ngayKetThuc'] as String)
            : null,
        trangThaiCuTruId: json['trangThaiCuTruId'] as int? ?? 0,
        trangThaiCuTruTen: json['trangThaiCuTruTen'] as String? ?? '',
        taiLieuCuTrus: (json['taiLieuCuTrus'] as List<dynamic>? ?? [])
            .map((e) => TaiLieuCuTruModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'fullName': fullName,
    'firstName': firstName,
    'lastName': lastName,
    'gioiTinhId': gioiTinhId,
    'gioiTinhName': gioiTinhName,
    'dob': dob?.toIso8601String(),
    'idCard': idCard,
    'phoneNumber': phoneNumber,
    'diaChi': diaChi,
    'anhDaiDienUrl': anhDaiDienUrl,
    'quanHeCuTruId': quanHeCuTruId,
    'loaiQuanHeCuTruId': loaiQuanHeCuTruId,
    'loaiQuanHeTen': loaiQuanHeTen,
    'ngayBatDau': ngayBatDau?.toIso8601String(),
    'ngayKetThuc': ngayKetThuc?.toIso8601String(),
    'trangThaiCuTruId': trangThaiCuTruId,
    'trangThaiCuTruTen': trangThaiCuTruTen,
    'taiLieuCuTrus': taiLieuCuTrus.map((e) => e.toJson()).toList(),
  };

  ThongTinCuDanModel copyWith({
    int? userId,
    String? fullName,
    String? firstName,
    String? lastName,
    int? gioiTinhId,
    String? gioiTinhName,
    DateTime? dob,
    String? idCard,
    String? phoneNumber,
    String? diaChi,
    String? anhDaiDienUrl,
    int? quanHeCuTruId,
    int? loaiQuanHeCuTruId,
    String? loaiQuanHeTen,
    DateTime? ngayBatDau,
    DateTime? ngayKetThuc,
    int? trangThaiCuTruId,
    String? trangThaiCuTruTen,
    List<TaiLieuCuTruModel>? taiLieuCuTrus,
  }) => ThongTinCuDanModel(
    userId: userId ?? this.userId,
    fullName: fullName ?? this.fullName,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    gioiTinhId: gioiTinhId ?? this.gioiTinhId,
    gioiTinhName: gioiTinhName ?? this.gioiTinhName,
    dob: dob ?? this.dob,
    idCard: idCard ?? this.idCard,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    diaChi: diaChi ?? this.diaChi,
    anhDaiDienUrl: anhDaiDienUrl ?? this.anhDaiDienUrl,
    quanHeCuTruId: quanHeCuTruId ?? this.quanHeCuTruId,
    loaiQuanHeCuTruId: loaiQuanHeCuTruId ?? this.loaiQuanHeCuTruId,
    loaiQuanHeTen: loaiQuanHeTen ?? this.loaiQuanHeTen,
    ngayBatDau: ngayBatDau ?? this.ngayBatDau,
    ngayKetThuc: ngayKetThuc ?? this.ngayKetThuc,
    trangThaiCuTruId: trangThaiCuTruId ?? this.trangThaiCuTruId,
    trangThaiCuTruTen: trangThaiCuTruTen ?? this.trangThaiCuTruTen,
    taiLieuCuTrus: taiLieuCuTrus ?? this.taiLieuCuTrus,
  );
}
