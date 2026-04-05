// lib/features/utils/models/uploaded_file_model.dart

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

  /// Kiểm tra nhanh loại file để hiển thị icon.
  bool get isImage => contentType.startsWith('image/');
  bool get isPdf => contentType == 'application/pdf';
}
