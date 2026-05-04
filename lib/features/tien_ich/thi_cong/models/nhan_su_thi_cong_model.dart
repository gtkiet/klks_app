// lib/features/yeu_cau_thi_cong/models/nhan_su_thi_cong_model.dart

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
