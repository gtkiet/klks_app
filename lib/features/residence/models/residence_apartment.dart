// lib/features/residence/models/residence_apartment.dart

class ResidenceApartment {
  final int quanHeCuTruId;
  final int loaiQuanHeCuTruId;
  final String loaiQuanHeTen;
  final DateTime ngayBatDau;
  final int toaNhaId;
  final String maToaNha;
  final String tenToaNha;
  final int tangId;
  final String maTang;
  final String tenTang;
  final int canHoId;
  final String maCanHo;
  final String tenCanHo;
  final int tongCuDan;

  const ResidenceApartment({
    required this.quanHeCuTruId,
    required this.loaiQuanHeCuTruId,
    required this.loaiQuanHeTen,
    required this.ngayBatDau,
    required this.toaNhaId,
    required this.maToaNha,
    required this.tenToaNha,
    required this.tangId,
    required this.maTang,
    required this.tenTang,
    required this.canHoId,
    required this.maCanHo,
    required this.tenCanHo,
    required this.tongCuDan,
  });

  factory ResidenceApartment.fromJson(Map<String, dynamic> json) =>
      ResidenceApartment(
        quanHeCuTruId: json['quanHeCuTruId'] as int,
        loaiQuanHeCuTruId: json['loaiQuanHeCuTruId'] as int,
        loaiQuanHeTen: json['loaiQuanHeTen'] as String? ?? '',
        ngayBatDau: DateTime.parse(json['ngayBatDau'] as String),
        toaNhaId: json['toaNhaId'] as int,
        maToaNha: json['maToaNha'] as String? ?? '',
        tenToaNha: json['tenToaNha'] as String? ?? '',
        tangId: json['tangId'] as int,
        maTang: json['maTang'] as String? ?? '',
        tenTang: json['tenTang'] as String? ?? '',
        canHoId: json['canHoId'] as int,
        maCanHo: json['maCanHo'] as String? ?? '',
        tenCanHo: json['tenCanHo'] as String? ?? '',
        tongCuDan: json['tongCuDan'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'quanHeCuTruId': quanHeCuTruId,
        'loaiQuanHeCuTruId': loaiQuanHeCuTruId,
        'loaiQuanHeTen': loaiQuanHeTen,
        'ngayBatDau': ngayBatDau.toIso8601String(),
        'toaNhaId': toaNhaId,
        'maToaNha': maToaNha,
        'tenToaNha': tenToaNha,
        'tangId': tangId,
        'maTang': maTang,
        'tenTang': tenTang,
        'canHoId': canHoId,
        'maCanHo': maCanHo,
        'tenCanHo': tenCanHo,
        'tongCuDan': tongCuDan,
      };
}