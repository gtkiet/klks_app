// lib/features/residence/models/residence_document.dart

class DocumentFile {
  final int id;
  final String fileUrl;
  final String fileName;
  final String contentType;

  const DocumentFile({
    required this.id,
    required this.fileUrl,
    required this.fileName,
    required this.contentType,
  });

  factory DocumentFile.fromJson(Map<String, dynamic> json) => DocumentFile(
        id: json['id'] as int,
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

class ResidenceDocument {
  final int id;
  final int loaiGiayToId;
  final String tenLoaiGiayTo;
  final String soGiayTo;
  final DateTime? ngayPhatHanh;
  final int? targetTaiLieuCuTruId;
  final List<DocumentFile> files;

  const ResidenceDocument({
    required this.id,
    required this.loaiGiayToId,
    required this.tenLoaiGiayTo,
    required this.soGiayTo,
    this.ngayPhatHanh,
    this.targetTaiLieuCuTruId,
    required this.files,
  });

  factory ResidenceDocument.fromJson(Map<String, dynamic> json) =>
      ResidenceDocument(
        id: json['id'] as int,
        loaiGiayToId: json['loaiGiayToId'] as int? ?? 0,
        tenLoaiGiayTo: json['tenLoaiGiayTo'] as String? ?? '',
        soGiayTo: json['soGiayTo'] as String? ?? '',
        ngayPhatHanh: json['ngayPhatHanh'] != null
            ? DateTime.tryParse(json['ngayPhatHanh'] as String)
            : null,
        targetTaiLieuCuTruId: json['targetTaiLieuCuTruId'] as int?,
        files: (json['files'] as List<dynamic>?)
                ?.map((e) => DocumentFile.fromJson(e as Map<String, dynamic>))
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