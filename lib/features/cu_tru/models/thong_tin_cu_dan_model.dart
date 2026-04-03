// lib/features/cu_tru/models/thong_tin_cu_dan_model.dart

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

  factory TaiLieuFileModel.fromJson(Map<String, dynamic> json) =>
      TaiLieuFileModel(
        id: json['id'] ?? 0,
        fileUrl: json['fileUrl'] ?? '',
        fileName: json['fileName'] ?? '',
        contentType: json['contentType'] ?? '',
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'fileUrl': fileUrl,
    'fileName': fileName,
    'contentType': contentType,
  };
}

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
        id: json['id'] ?? 0,
        loaiGiayToId: json['loaiGiayToId'] ?? 0,
        tenLoaiGiayTo: json['tenLoaiGiayTo'] ?? '',
        soGiayTo: json['soGiayTo'] ?? '',
        ngayPhatHanh: json['ngayPhatHanh'] != null
            ? DateTime.tryParse(json['ngayPhatHanh'])
            : null,
        targetTaiLieuCuTruId: json['targetTaiLieuCuTruId'],
        files:
            (json['files'] as List<dynamic>?)
                ?.map((e) => TaiLieuFileModel.fromJson(e))
                .toList() ??
            [],
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
        userId: json['userId'] ?? 0,
        fullName: json['fullName'] ?? '',
        firstName: json['firstName'] ?? '',
        lastName: json['lastName'] ?? '',
        gioiTinhId: json['gioiTinhId'] ?? 0,
        gioiTinhName: json['gioiTinhName'] ?? '',
        dob: json['dob'] != null ? DateTime.tryParse(json['dob']) : null,
        idCard: json['idCard'],
        phoneNumber: json['phoneNumber'],
        diaChi: json['diaChi'],
        anhDaiDienUrl: json['anhDaiDienUrl'],
        quanHeCuTruId: json['quanHeCuTruId'] ?? 0,
        loaiQuanHeCuTruId: json['loaiQuanHeCuTruId'] ?? 0,
        loaiQuanHeTen: json['loaiQuanHeTen'] ?? '',
        ngayBatDau: json['ngayBatDau'] != null
            ? DateTime.tryParse(json['ngayBatDau'])
            : null,
        ngayKetThuc: json['ngayKetThuc'] != null
            ? DateTime.tryParse(json['ngayKetThuc'])
            : null,
        trangThaiCuTruId: json['trangThaiCuTruId'] ?? 0,
        trangThaiCuTruTen: json['trangThaiCuTruTen'] ?? '',
        taiLieuCuTrus:
            (json['taiLieuCuTrus'] as List<dynamic>?)
                ?.map((e) => TaiLieuCuTruModel.fromJson(e))
                .toList() ??
            [],
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
