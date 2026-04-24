// lib/features/yeu_cau_thi_cong/models/tep_dinh_kem_model.dart

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
