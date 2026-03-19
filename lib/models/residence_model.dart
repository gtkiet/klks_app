class Residence {
  final int id;
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

  Residence({
    required this.id,
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

  factory Residence.fromJson(Map<String, dynamic> json) {
    return Residence(
      id: json['id'],
      loaiQuanHeTen: json['loaiQuanHeTen'] ?? '',
      ngayBatDau: DateTime.parse(json['ngayBatDau']),
      toaNhaId: json['toaNhaId'],
      maToaNha: json['maToaNha'] ?? '',
      tenToaNha: json['tenToaNha'] ?? '',
      tangId: json['tangId'],
      maTang: json['maTang'] ?? '',
      tenTang: json['tenTang'] ?? '',
      canHoId: json['canHoId'],
      maCanHo: json['maCanHo'] ?? '',
      tenCanHo: json['tenCanHo'] ?? '',
      tongCuDan: json['tongCuDan'] ?? 0,
    );
  }
}