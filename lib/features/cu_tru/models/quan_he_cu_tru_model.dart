// lib/features/cu_tru/models/quan_he_cu_tru_model.dart

class QuanHeCuTruModel {
  final int quanHeCuTruId;
  final int loaiQuanHeCuTruId;
  final String loaiQuanHeTen;
  final DateTime? ngayBatDau;
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

  const QuanHeCuTruModel({
    required this.quanHeCuTruId,
    required this.loaiQuanHeCuTruId,
    required this.loaiQuanHeTen,
    this.ngayBatDau,
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

  /// Derived: địa chỉ đầy đủ
  String get diaChiDayDu => '$tenToaNha - $tenTang - $tenCanHo';

  factory QuanHeCuTruModel.fromJson(Map<String, dynamic> json) {
    return QuanHeCuTruModel(
      quanHeCuTruId: json['quanHeCuTruId'] ?? 0,
      loaiQuanHeCuTruId: json['loaiQuanHeCuTruId'] ?? 0,
      loaiQuanHeTen: json['loaiQuanHeTen'] ?? '',
      ngayBatDau: json['ngayBatDau'] != null
          ? DateTime.tryParse(json['ngayBatDau'])
          : null,
      toaNhaId: json['toaNhaId'] ?? 0,
      maToaNha: json['maToaNha'] ?? '',
      tenToaNha: json['tenToaNha'] ?? '',
      tangId: json['tangId'] ?? 0,
      maTang: json['maTang'] ?? '',
      tenTang: json['tenTang'] ?? '',
      canHoId: json['canHoId'] ?? 0,
      maCanHo: json['maCanHo'] ?? '',
      tenCanHo: json['tenCanHo'] ?? '',
      tongCuDan: json['tongCuDan'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'quanHeCuTruId': quanHeCuTruId,
    'loaiQuanHeCuTruId': loaiQuanHeCuTruId,
    'loaiQuanHeTen': loaiQuanHeTen,
    'ngayBatDau': ngayBatDau?.toIso8601String(),
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

  QuanHeCuTruModel copyWith({
    int? quanHeCuTruId,
    int? loaiQuanHeCuTruId,
    String? loaiQuanHeTen,
    DateTime? ngayBatDau,
    int? toaNhaId,
    String? maToaNha,
    String? tenToaNha,
    int? tangId,
    String? maTang,
    String? tenTang,
    int? canHoId,
    String? maCanHo,
    String? tenCanHo,
    int? tongCuDan,
  }) => QuanHeCuTruModel(
    quanHeCuTruId: quanHeCuTruId ?? this.quanHeCuTruId,
    loaiQuanHeCuTruId: loaiQuanHeCuTruId ?? this.loaiQuanHeCuTruId,
    loaiQuanHeTen: loaiQuanHeTen ?? this.loaiQuanHeTen,
    ngayBatDau: ngayBatDau ?? this.ngayBatDau,
    toaNhaId: toaNhaId ?? this.toaNhaId,
    maToaNha: maToaNha ?? this.maToaNha,
    tenToaNha: tenToaNha ?? this.tenToaNha,
    tangId: tangId ?? this.tangId,
    maTang: maTang ?? this.maTang,
    tenTang: tenTang ?? this.tenTang,
    canHoId: canHoId ?? this.canHoId,
    maCanHo: maCanHo ?? this.maCanHo,
    tenCanHo: tenCanHo ?? this.tenCanHo,
    tongCuDan: tongCuDan ?? this.tongCuDan,
  );
}
