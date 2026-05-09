// lib/features/tien_ich/thi_cong/models/trang_thai_thi_cong_model.dart

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
