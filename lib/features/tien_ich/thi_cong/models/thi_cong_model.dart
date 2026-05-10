// lib/features/tien_ich/thi_cong/models/thi_cong_model.dart

// TODO: gọi lib/features/cu_tru/models/quan_he_cu_tru_model.dart để lấy data địa chỉ đầy đủ thay vì chỉ mã tòa nhà, mã tầng, mã căn hộ

abstract class TrangThaiYeuCauConst {
  static const int dangChoDuyet = 1;
  static const int daDuyet = 2;
  static const int tuChoi = 3;
  static const int daLuu = 4;
  static const int daThuHoi = 5;
  static const int hetHieuLuc = 6;
  static const int hoanTat = 7;
  static const int daHuy = 8;
  static const int yeuCauBoSung = 9; // "Trả lại" / Returned

  /// Cư dân có thể chỉnh sửa khi ở các trạng thái này
  static const Set<int> coTheChinhSua = {daLuu, yeuCauBoSung};

  /// Cư dân có thể thu hồi khi ở các trạng thái này
  static const Set<int> coTheThuHoi = {daLuu, dangChoDuyet};
}

abstract class TrangThaiThiCongConst {
  static const int chuaThiCong = 1; // Chưa thi công
  static const int choThuTienCoc = 2; // Chờ thu tiền cọc
  static const int daCapPhep = 3; // Đã cấp phép
  static const int daHoanTat = 4; // Đã hoàn tất
}

class TrangThaiThiCongModel {
  final int id;
  final String code;
  final String name;

  const TrangThaiThiCongModel({
    required this.id,
    required this.code,
    required this.name,
  });

  factory TrangThaiThiCongModel.fromJson(Map<String, dynamic> json) =>
      TrangThaiThiCongModel(
        id: json['id'] as int? ?? 0,
        code: json['code'] as String? ?? '',
        name: json['name'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {'id': id, 'code': code, 'name': name};

  TrangThaiThiCongModel copyWith({int? id, String? code, String? name}) =>
      TrangThaiThiCongModel(
        id: id ?? this.id,
        code: code ?? this.code,
        name: name ?? this.name,
      );
}

class YeuCauThiCongListItemModel {
  final int id;
  final int canHoId;
  final String tenCanHo;
  final String hangMucThiCong;
  final DateTime? duKienBatDau;
  final DateTime? duKienKetThuc;
  final String tenDonViThiCong;
  final int trangThaiYeuCauId;
  final String trangThaiYeuCauTen;
  final int trangThaiThiCongId;
  final String trangThaiThiCongTen;
  final DateTime? createdAt;
  final int createdBy;
  final String tenNguoiGui;

  const YeuCauThiCongListItemModel({
    required this.id,
    required this.canHoId,
    required this.tenCanHo,
    required this.hangMucThiCong,
    this.duKienBatDau,
    this.duKienKetThuc,
    required this.tenDonViThiCong,
    required this.trangThaiYeuCauId,
    required this.trangThaiYeuCauTen,
    required this.trangThaiThiCongId,
    required this.trangThaiThiCongTen,
    this.createdAt,
    required this.createdBy,
    required this.tenNguoiGui,
  });

  bool get isReturned => trangThaiYeuCauId == TrangThaiYeuCauConst.yeuCauBoSung;

  bool get coTheChinhSua =>
      TrangThaiYeuCauConst.coTheChinhSua.contains(trangThaiYeuCauId);

  bool get coTheThuHoi =>
      TrangThaiYeuCauConst.coTheThuHoi.contains(trangThaiYeuCauId);

  factory YeuCauThiCongListItemModel.fromJson(Map<String, dynamic> json) =>
      YeuCauThiCongListItemModel(
        id: json['id'] as int? ?? 0,
        canHoId: json['canHoId'] as int? ?? 0,
        tenCanHo: json['tenCanHo'] as String? ?? '',
        hangMucThiCong: json['hangMucThiCong'] as String? ?? '',
        duKienBatDau: json['duKienBatDau'] != null
            ? DateTime.tryParse(json['duKienBatDau'] as String)
            : null,
        duKienKetThuc: json['duKienKetThuc'] != null
            ? DateTime.tryParse(json['duKienKetThuc'] as String)
            : null,
        tenDonViThiCong: json['tenDonViThiCong'] as String? ?? '',
        trangThaiYeuCauId: json['trangThaiYeuCauId'] as int? ?? 0,
        trangThaiYeuCauTen: json['trangThaiYeuCauTen'] as String? ?? '',
        trangThaiThiCongId: json['trangThaiThiCongId'] as int? ?? 0,
        trangThaiThiCongTen: json['trangThaiThiCongTen'] as String? ?? '',
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String)
            : null,
        createdBy: json['createdBy'] as int? ?? 0,
        tenNguoiGui: json['tenNguoiGui'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'canHoId': canHoId,
    'tenCanHo': tenCanHo,
    'hangMucThiCong': hangMucThiCong,
    'duKienBatDau': duKienBatDau?.toIso8601String(),
    'duKienKetThuc': duKienKetThuc?.toIso8601String(),
    'tenDonViThiCong': tenDonViThiCong,
    'trangThaiYeuCauId': trangThaiYeuCauId,
    'trangThaiYeuCauTen': trangThaiYeuCauTen,
    'trangThaiThiCongId': trangThaiThiCongId,
    'trangThaiThiCongTen': trangThaiThiCongTen,
    'createdAt': createdAt?.toIso8601String(),
    'createdBy': createdBy,
    'tenNguoiGui': tenNguoiGui,
  };

  YeuCauThiCongListItemModel copyWith({
    int? id,
    int? canHoId,
    String? tenCanHo,
    String? hangMucThiCong,
    DateTime? duKienBatDau,
    DateTime? duKienKetThuc,
    String? tenDonViThiCong,
    int? trangThaiYeuCauId,
    String? trangThaiYeuCauTen,
    int? trangThaiThiCongId,
    String? trangThaiThiCongTen,
    DateTime? createdAt,
    int? createdBy,
    String? tenNguoiGui,
  }) => YeuCauThiCongListItemModel(
    id: id ?? this.id,
    canHoId: canHoId ?? this.canHoId,
    tenCanHo: tenCanHo ?? this.tenCanHo,
    hangMucThiCong: hangMucThiCong ?? this.hangMucThiCong,
    duKienBatDau: duKienBatDau ?? this.duKienBatDau,
    duKienKetThuc: duKienKetThuc ?? this.duKienKetThuc,
    tenDonViThiCong: tenDonViThiCong ?? this.tenDonViThiCong,
    trangThaiYeuCauId: trangThaiYeuCauId ?? this.trangThaiYeuCauId,
    trangThaiYeuCauTen: trangThaiYeuCauTen ?? this.trangThaiYeuCauTen,
    trangThaiThiCongId: trangThaiThiCongId ?? this.trangThaiThiCongId,
    trangThaiThiCongTen: trangThaiThiCongTen ?? this.trangThaiThiCongTen,
    createdAt: createdAt ?? this.createdAt,
    createdBy: createdBy ?? this.createdBy,
    tenNguoiGui: tenNguoiGui ?? this.tenNguoiGui,
  );
}


class TepDinhKemModel {
  final int id;
  final String fileUrl;
  final String fileName;
  final String contentType;

  const TepDinhKemModel({
    required this.id,
    required this.fileUrl,
    required this.fileName,
    required this.contentType,
  });

  factory TepDinhKemModel.fromJson(Map<String, dynamic> json) =>
      TepDinhKemModel(
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

  TepDinhKemModel copyWith({
    int? id,
    String? fileUrl,
    String? fileName,
    String? contentType,
  }) => TepDinhKemModel(
    id: id ?? this.id,
    fileUrl: fileUrl ?? this.fileUrl,
    fileName: fileName ?? this.fileName,
    contentType: contentType ?? this.contentType,
  );
}


class NhanSuThiCongModel {
  final int? id;
  final int? nhanVienId;
  final String hoTen;
  final String soCCCD;
  final String soDienThoai;
  final String vaiTro;
  final String ghiChu;
  final String lyDoXoa;

  const NhanSuThiCongModel({
    this.id,
    this.nhanVienId,
    required this.hoTen,
    required this.soCCCD,
    required this.soDienThoai,
    required this.vaiTro,
    this.ghiChu = '',
    this.lyDoXoa = '',
  });

  factory NhanSuThiCongModel.fromJson(Map<String, dynamic> json) =>
      NhanSuThiCongModel(
        id: json['id'] as int?,
        nhanVienId: json['nhanVienId'] as int?,
        hoTen: json['hoTen'] as String? ?? '',
        soCCCD: json['soCCCD'] as String? ?? '',
        soDienThoai: json['soDienThoai'] as String? ?? '',
        vaiTro: json['vaiTro'] as String? ?? '',
        ghiChu: json['ghiChu'] as String? ?? '',
        lyDoXoa: json['lyDoXoa'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'hoTen': hoTen,
    'soCCCD': soCCCD,
    'soDienThoai': soDienThoai,
    'vaiTro': vaiTro,
    'ghiChu': ghiChu,
  };

  NhanSuThiCongModel copyWith({
    int? id,
    int? nhanVienId,
    String? hoTen,
    String? soCCCD,
    String? soDienThoai,
    String? vaiTro,
    String? ghiChu,
    String? lyDoXoa,
  }) => NhanSuThiCongModel(
    id: id ?? this.id,
    nhanVienId: nhanVienId ?? this.nhanVienId,
    hoTen: hoTen ?? this.hoTen,
    soCCCD: soCCCD ?? this.soCCCD,
    soDienThoai: soDienThoai ?? this.soDienThoai,
    vaiTro: vaiTro ?? this.vaiTro,
    ghiChu: ghiChu ?? this.ghiChu,
    lyDoXoa: lyDoXoa ?? this.lyDoXoa,
  );
}


class YeuCauThiCongDetailModel {
  final int id;
  final int canHoId;
  final String tenCanHo;
  final String hangMucThiCong;
  final DateTime? duKienBatDau;
  final DateTime? duKienKetThuc;
  final String tenDonViThiCong;
  final int trangThaiYeuCauId;
  final String trangThaiYeuCauTen;
  final int trangThaiThiCongId;
  final String trangThaiThiCongTen;
  final DateTime? createdAt;
  final int createdBy;
  final String tenNguoiGui;
  final String noiDung;
  final String nguoiDaiDien;
  final String soDienThoaiDaiDien;
  final double tienDatCoc;
  final bool isDaThuCoc;
  final String ghiChuThuCoc;
  final double tienKhauTru;
  final String lyDoKhauTru;
  final bool isDaHoanCoc;
  final int? nguoiXuLyId;
  final String tenNguoiXuLy;
  final DateTime? ngayXuLy;
  final String lyDo;
  final List<NhanSuThiCongModel> nhanSuThiCongs;
  final List<TepDinhKemModel> danhSachTep;

  const YeuCauThiCongDetailModel({
    required this.id,
    required this.canHoId,
    required this.tenCanHo,
    required this.hangMucThiCong,
    this.duKienBatDau,
    this.duKienKetThuc,
    required this.tenDonViThiCong,
    required this.trangThaiYeuCauId,
    required this.trangThaiYeuCauTen,
    required this.trangThaiThiCongId,
    required this.trangThaiThiCongTen,
    this.createdAt,
    required this.createdBy,
    required this.tenNguoiGui,
    required this.noiDung,
    required this.nguoiDaiDien,
    required this.soDienThoaiDaiDien,
    required this.tienDatCoc,
    required this.isDaThuCoc,
    required this.ghiChuThuCoc,
    required this.tienKhauTru,
    required this.lyDoKhauTru,
    required this.isDaHoanCoc,
    this.nguoiXuLyId,
    required this.tenNguoiXuLy,
    this.ngayXuLy,
    required this.lyDo,
    required this.nhanSuThiCongs,
    required this.danhSachTep,
  });

  /// Có thể chỉnh sửa: Saved hoặc Returned
  bool get coTheChinhSua =>
      trangThaiYeuCauTen.toLowerCase() == 'saved' ||
      trangThaiYeuCauTen.toLowerCase() == 'returned' ||
      trangThaiYeuCauTen.toLowerCase() == 'trả lại';

  /// Khi Returned, không được đổi hangMuc / ngày
  bool get isReturned =>
      trangThaiYeuCauTen.toLowerCase() == 'returned' ||
      trangThaiYeuCauTen.toLowerCase() == 'trả lại';

  bool get coTheThuHoi => coTheChinhSua;

  String get tienDatCocFormatted =>
      '${tienDatCoc.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} đ';

  factory YeuCauThiCongDetailModel.fromJson(Map<String, dynamic> json) =>
      YeuCauThiCongDetailModel(
        id: json['id'] as int? ?? 0,
        canHoId: json['canHoId'] as int? ?? 0,
        tenCanHo: json['tenCanHo'] as String? ?? '',
        hangMucThiCong: json['hangMucThiCong'] as String? ?? '',
        duKienBatDau: json['duKienBatDau'] != null
            ? DateTime.tryParse(json['duKienBatDau'] as String)
            : null,
        duKienKetThuc: json['duKienKetThuc'] != null
            ? DateTime.tryParse(json['duKienKetThuc'] as String)
            : null,
        tenDonViThiCong: json['tenDonViThiCong'] as String? ?? '',
        trangThaiYeuCauId: json['trangThaiYeuCauId'] as int? ?? 0,
        trangThaiYeuCauTen: json['trangThaiYeuCauTen'] as String? ?? '',
        trangThaiThiCongId: json['trangThaiThiCongId'] as int? ?? 0,
        trangThaiThiCongTen: json['trangThaiThiCongTen'] as String? ?? '',
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String)
            : null,
        createdBy: json['createdBy'] as int? ?? 0,
        tenNguoiGui: json['tenNguoiGui'] as String? ?? '',
        noiDung: json['noiDung'] as String? ?? '',
        nguoiDaiDien: json['nguoiDaiDien'] as String? ?? '',
        soDienThoaiDaiDien: json['soDienThoaiDaiDien'] as String? ?? '',
        tienDatCoc: (json['tienDatCoc'] as num?)?.toDouble() ?? 0,
        isDaThuCoc: json['isDaThuCoc'] as bool? ?? false,
        ghiChuThuCoc: json['ghiChuThuCoc'] as String? ?? '',
        tienKhauTru: (json['tienKhauTru'] as num?)?.toDouble() ?? 0,
        lyDoKhauTru: json['lyDoKhauTru'] as String? ?? '',
        isDaHoanCoc: json['isDaHoanCoc'] as bool? ?? false,
        nguoiXuLyId: json['nguoiXuLyId'] as int?,
        tenNguoiXuLy: json['tenNguoiXuLy'] as String? ?? '',
        ngayXuLy: json['ngayXuLy'] != null
            ? DateTime.tryParse(json['ngayXuLy'] as String)
            : null,
        lyDo: json['lyDo'] as String? ?? '',
        nhanSuThiCongs: (json['nhanSuThiCongs'] as List<dynamic>? ?? [])
            .map((e) => NhanSuThiCongModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        danhSachTep: (json['danhSachTep'] as List<dynamic>? ?? [])
            .map((e) => TepDinhKemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'canHoId': canHoId,
    'tenCanHo': tenCanHo,
    'hangMucThiCong': hangMucThiCong,
    'duKienBatDau': duKienBatDau?.toIso8601String(),
    'duKienKetThuc': duKienKetThuc?.toIso8601String(),
    'tenDonViThiCong': tenDonViThiCong,
    'trangThaiYeuCauId': trangThaiYeuCauId,
    'trangThaiYeuCauTen': trangThaiYeuCauTen,
    'trangThaiThiCongId': trangThaiThiCongId,
    'trangThaiThiCongTen': trangThaiThiCongTen,
    'createdAt': createdAt?.toIso8601String(),
    'createdBy': createdBy,
    'tenNguoiGui': tenNguoiGui,
    'noiDung': noiDung,
    'nguoiDaiDien': nguoiDaiDien,
    'soDienThoaiDaiDien': soDienThoaiDaiDien,
    'tienDatCoc': tienDatCoc,
    'isDaThuCoc': isDaThuCoc,
    'ghiChuThuCoc': ghiChuThuCoc,
    'tienKhauTru': tienKhauTru,
    'lyDoKhauTru': lyDoKhauTru,
    'isDaHoanCoc': isDaHoanCoc,
    'nguoiXuLyId': nguoiXuLyId,
    'tenNguoiXuLy': tenNguoiXuLy,
    'ngayXuLy': ngayXuLy?.toIso8601String(),
    'lyDo': lyDo,
    'nhanSuThiCongs': nhanSuThiCongs.map((e) => e.toJson()).toList(),
    'danhSachTep': danhSachTep.map((e) => e.toJson()).toList(),
  };

  YeuCauThiCongDetailModel copyWith({
    int? id,
    int? canHoId,
    String? tenCanHo,
    String? hangMucThiCong,
    DateTime? duKienBatDau,
    DateTime? duKienKetThuc,
    String? tenDonViThiCong,
    int? trangThaiYeuCauId,
    String? trangThaiYeuCauTen,
    int? trangThaiThiCongId,
    String? trangThaiThiCongTen,
    DateTime? createdAt,
    int? createdBy,
    String? tenNguoiGui,
    String? noiDung,
    String? nguoiDaiDien,
    String? soDienThoaiDaiDien,
    double? tienDatCoc,
    bool? isDaThuCoc,
    String? ghiChuThuCoc,
    double? tienKhauTru,
    String? lyDoKhauTru,
    bool? isDaHoanCoc,
    int? nguoiXuLyId,
    String? tenNguoiXuLy,
    DateTime? ngayXuLy,
    String? lyDo,
    List<NhanSuThiCongModel>? nhanSuThiCongs,
    List<TepDinhKemModel>? danhSachTep,
  }) => YeuCauThiCongDetailModel(
    id: id ?? this.id,
    canHoId: canHoId ?? this.canHoId,
    tenCanHo: tenCanHo ?? this.tenCanHo,
    hangMucThiCong: hangMucThiCong ?? this.hangMucThiCong,
    duKienBatDau: duKienBatDau ?? this.duKienBatDau,
    duKienKetThuc: duKienKetThuc ?? this.duKienKetThuc,
    tenDonViThiCong: tenDonViThiCong ?? this.tenDonViThiCong,
    trangThaiYeuCauId: trangThaiYeuCauId ?? this.trangThaiYeuCauId,
    trangThaiYeuCauTen: trangThaiYeuCauTen ?? this.trangThaiYeuCauTen,
    trangThaiThiCongId: trangThaiThiCongId ?? this.trangThaiThiCongId,
    trangThaiThiCongTen: trangThaiThiCongTen ?? this.trangThaiThiCongTen,
    createdAt: createdAt ?? this.createdAt,
    createdBy: createdBy ?? this.createdBy,
    tenNguoiGui: tenNguoiGui ?? this.tenNguoiGui,
    noiDung: noiDung ?? this.noiDung,
    nguoiDaiDien: nguoiDaiDien ?? this.nguoiDaiDien,
    soDienThoaiDaiDien: soDienThoaiDaiDien ?? this.soDienThoaiDaiDien,
    tienDatCoc: tienDatCoc ?? this.tienDatCoc,
    isDaThuCoc: isDaThuCoc ?? this.isDaThuCoc,
    ghiChuThuCoc: ghiChuThuCoc ?? this.ghiChuThuCoc,
    tienKhauTru: tienKhauTru ?? this.tienKhauTru,
    lyDoKhauTru: lyDoKhauTru ?? this.lyDoKhauTru,
    isDaHoanCoc: isDaHoanCoc ?? this.isDaHoanCoc,
    nguoiXuLyId: nguoiXuLyId ?? this.nguoiXuLyId,
    tenNguoiXuLy: tenNguoiXuLy ?? this.tenNguoiXuLy,
    ngayXuLy: ngayXuLy ?? this.ngayXuLy,
    lyDo: lyDo ?? this.lyDo,
    nhanSuThiCongs: nhanSuThiCongs ?? this.nhanSuThiCongs,
    danhSachTep: danhSachTep ?? this.danhSachTep,
  );
}

class UploadedFileModel {
  final int fileId;
  final String fileName;
  final String fileUrl;
  final String contentType;

  const UploadedFileModel({
    required this.fileId,
    required this.fileName,
    required this.fileUrl,
    required this.contentType,
  });

  factory UploadedFileModel.fromJson(Map<String, dynamic> json) =>
      UploadedFileModel(
        fileId: json['fileId'] as int? ?? 0,
        fileName: json['fileName'] as String? ?? '',
        fileUrl: json['fileUrl'] as String? ?? '',
        contentType: json['contentType'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
    'fileId': fileId,
    'fileName': fileName,
    'fileUrl': fileUrl,
    'contentType': contentType,
  };

  UploadedFileModel copyWith({
    int? fileId,
    String? fileName,
    String? fileUrl,
    String? contentType,
  }) => UploadedFileModel(
    fileId: fileId ?? this.fileId,
    fileName: fileName ?? this.fileName,
    fileUrl: fileUrl ?? this.fileUrl,
    contentType: contentType ?? this.contentType,
  );
}
