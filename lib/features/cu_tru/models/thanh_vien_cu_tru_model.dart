// lib/features/cu_tru/models/thanh_vien_cu_tru_model.dart

class ThanhVienCuTruModel {
  final int quanHeCuTruId;
  final int userId;
  final int loaiQuanHeCuTruId;
  final String loaiQuanHeTen;
  final DateTime? ngayBatDau;
  final String fullName;
  final String? anhDaiDienUrl;

  const ThanhVienCuTruModel({
    required this.quanHeCuTruId,
    required this.userId,
    required this.loaiQuanHeCuTruId,
    required this.loaiQuanHeTen,
    this.ngayBatDau,
    required this.fullName,
    this.anhDaiDienUrl,
  });

  factory ThanhVienCuTruModel.fromJson(Map<String, dynamic> json) {
    return ThanhVienCuTruModel(
      quanHeCuTruId: json['quanHeCuTruId'] ?? 0,
      userId: json['userId'] ?? 0,
      loaiQuanHeCuTruId: json['loaiQuanHeCuTruId'] ?? 0,
      loaiQuanHeTen: json['loaiQuanHeTen'] ?? '',
      ngayBatDau: json['ngayBatDau'] != null
          ? DateTime.tryParse(json['ngayBatDau'])
          : null,
      fullName: json['fullName'] ?? '',
      anhDaiDienUrl: json['anhDaiDienUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
    'quanHeCuTruId': quanHeCuTruId,
    'userId': userId,
    'loaiQuanHeCuTruId': loaiQuanHeCuTruId,
    'loaiQuanHeTen': loaiQuanHeTen,
    'ngayBatDau': ngayBatDau?.toIso8601String(),
    'fullName': fullName,
    'anhDaiDienUrl': anhDaiDienUrl,
  };

  ThanhVienCuTruModel copyWith({
    int? quanHeCuTruId,
    int? userId,
    int? loaiQuanHeCuTruId,
    String? loaiQuanHeTen,
    DateTime? ngayBatDau,
    String? fullName,
    String? anhDaiDienUrl,
  }) => ThanhVienCuTruModel(
    quanHeCuTruId: quanHeCuTruId ?? this.quanHeCuTruId,
    userId: userId ?? this.userId,
    loaiQuanHeCuTruId: loaiQuanHeCuTruId ?? this.loaiQuanHeCuTruId,
    loaiQuanHeTen: loaiQuanHeTen ?? this.loaiQuanHeTen,
    ngayBatDau: ngayBatDau ?? this.ngayBatDau,
    fullName: fullName ?? this.fullName,
    anhDaiDienUrl: anhDaiDienUrl ?? this.anhDaiDienUrl,
  );
}
