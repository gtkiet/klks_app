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

  String get diaChiDayDu => '$tenToaNha - $tenTang - $tenCanHo';

  factory QuanHeCuTruModel.fromJson(Map<String, dynamic> json) =>
      QuanHeCuTruModel(
        quanHeCuTruId: json['quanHeCuTruId'] as int? ?? 0,
        loaiQuanHeCuTruId: json['loaiQuanHeCuTruId'] as int? ?? 0,
        loaiQuanHeTen: json['loaiQuanHeTen'] as String? ?? '',
        ngayBatDau: json['ngayBatDau'] != null
            ? DateTime.tryParse(json['ngayBatDau'] as String)
            : null,
        toaNhaId: json['toaNhaId'] as int? ?? 0,
        maToaNha: json['maToaNha'] as String? ?? '',
        tenToaNha: json['tenToaNha'] as String? ?? '',
        tangId: json['tangId'] as int? ?? 0,
        maTang: json['maTang'] as String? ?? '',
        tenTang: json['tenTang'] as String? ?? '',
        canHoId: json['canHoId'] as int? ?? 0,
        maCanHo: json['maCanHo'] as String? ?? '',
        tenCanHo: json['tenCanHo'] as String? ?? '',
        tongCuDan: json['tongCuDan'] as int? ?? 0,
      );

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


class SelectorItemModel {
  final int id;
  final String name;

  const SelectorItemModel({required this.id, required this.name});

  factory SelectorItemModel.fromJson(Map<String, dynamic> json) =>
      SelectorItemModel(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  @override
  bool operator ==(Object other) =>
      other is SelectorItemModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
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

  factory UploadedFileModel.fromJson(Map<String, dynamic> json) {
    // Server có thể trả 'fileId' hoặc 'id' — đọc cả hai, ưu tiên 'fileId'
    final fileId = (json['fileId'] as int?) ?? (json['id'] as int?) ?? 0;

    return UploadedFileModel(
      fileId: fileId,
      fileName: json['fileName'] as String? ?? '',
      fileUrl: json['fileUrl'] as String? ?? '',
      contentType: json['contentType'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'fileId': fileId,
    'fileName': fileName,
    'fileUrl': fileUrl,
    'contentType': contentType,
  };

  bool get isImage => contentType.startsWith('image/');
  bool get isPdf => contentType == 'application/pdf';
}
