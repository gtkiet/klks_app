// class UploadFileResponse {
//   final String fileId;
//   final String fileName;
//   final String fileUrl;
//   final String contentType;

//   const UploadFileResponse({required this.fileId, required this.fileName, required this.fileUrl, required this.contentType});
 
//   factory UploadFileResponse.fromJson(Map<String, dynamic> json) =>
//       UploadFileResponse(
//         fileId: json['fileId'] as String,
//         fileName: json['fileName'] as String,
//         fileUrl: json['fileUrl'] as String,
//         contentType: json['contentType'] as String,
//       );
 
//   Map<String, dynamic> toJson() => {'fileId': fileId, 'fileName': fileName, 'fileUrl': fileUrl, 'contentType': contentType};
// }

// lib/features/residence/models/upload_file_response.dart

class UploadFileResponse {
  final String fileId;
  final String fileName;
  final String fileUrl;
  final String contentType;

  const UploadFileResponse({
    required this.fileId,
    required this.fileName,
    required this.fileUrl,
    required this.contentType,
  });

  /// Parse trực tiếp từ response (có handle cả trường hợp bị wrap trong `data`)
  factory UploadFileResponse.fromResponse(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      // Nếu backend wrap trong "data"
      if (responseData.containsKey('data') &&
          responseData['data'] is Map<String, dynamic>) {
        return UploadFileResponse.fromJson(responseData['data']);
      }
      return UploadFileResponse.fromJson(responseData);
    } else {
      throw Exception('Invalid response format');
    }
  }

  /// Parse từ JSON (đã null-safe + type-safe)
  factory UploadFileResponse.fromJson(Map<String, dynamic> json) {
    final fileId = json['fileId']?.toString();
    final fileUrl = json['fileUrl']?.toString();

    // Validate field bắt buộc
    if (fileId == null || fileId.isEmpty) {
      throw Exception('Upload response missing fileId');
    }
    if (fileUrl == null || fileUrl.isEmpty) {
      throw Exception('Upload response missing fileUrl');
    }

    return UploadFileResponse(
      fileId: fileId,
      fileName: json['fileName']?.toString() ?? '',
      fileUrl: fileUrl,
      contentType: json['contentType']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileId': fileId,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'contentType': contentType,
    };
  }

  @override
  String toString() {
    return 'UploadFileResponse(fileId: $fileId, fileName: $fileName, fileUrl: $fileUrl, contentType: $contentType)';
  }
}