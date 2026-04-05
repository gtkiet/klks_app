// lib/features/cu_tru/utils/file_opener.dart
//
// Utility trung tâm để mở file từ URL server.
//
// Logic routing tự động:
//   Ảnh (jpg/png/webp/gif/heic) → ImageGalleryScreen  (trong app, có swipe)
//   PDF                          → PdfViewerScreen      (trong app)
//   Mọi loại khác               → download temp → mở app ngoài (open_filex)
//
// ─── Cách dùng đơn giản ────────────────────────────────────────────────────
//
//   // Mở 1 file, tự detect loại:
//   FileOpener.open(context, file: OpenableFile.fromTaiLieu(myFile));
//
//   // Mở gallery ảnh từ một nhóm file (swipe qua lại):
//   FileOpener.open(
//     context,
//     file: OpenableFile.fromTaiLieu(tappedFile),
//     siblings: allFiles.map(OpenableFile.fromTaiLieu).toList(),
//   );

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../models/thong_tin_cu_dan_model.dart';
import '../models/yeu_cau_cu_tru_model.dart';
import '../screens/image_gallery_screen.dart';
import '../screens/pdf_viewer_screen.dart';

// ─── OpenableFile ─────────────────────────────────────────────────────────────

/// Model thống nhất cho bất kỳ file nào có thể mở trong app.
class OpenableFile {
  final String fileUrl;
  final String fileName;
  final String contentType;

  const OpenableFile({
    required this.fileUrl,
    required this.fileName,
    required this.contentType,
  });

  factory OpenableFile.fromTaiLieu(TaiLieuFileModel f) => OpenableFile(
    fileUrl: f.fileUrl,
    fileName: f.fileName,
    contentType: f.contentType,
  );

  factory OpenableFile.fromUploaded(UploadedFileModel f) => OpenableFile(
    fileUrl: f.fileUrl,
    fileName: f.fileName,
    contentType: f.contentType,
  );

  String get _ext => path.extension(fileName).toLowerCase();

  bool get isImage {
    const imgExts = {'.jpg', '.jpeg', '.png', '.gif', '.webp', '.heic', '.bmp'};
    return contentType.toLowerCase().startsWith('image/') ||
        imgExts.contains(_ext);
  }

  bool get isPdf => contentType.toLowerCase().contains('pdf') || _ext == '.pdf';

  /// Icon đại diện theo loại file — dùng trong danh sách.
  IconData get icon {
    if (isImage) return Icons.image_outlined;
    if (isPdf) return Icons.picture_as_pdf_outlined;
    switch (_ext) {
      case '.doc':
      case '.docx':
        return Icons.description_outlined;
      case '.xls':
      case '.xlsx':
        return Icons.table_chart_outlined;
      case '.mp4':
      case '.mov':
      case '.avi':
        return Icons.videocam_outlined;
      case '.zip':
      case '.rar':
      case '.7z':
        return Icons.folder_zip_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  /// Màu icon theo loại file.
  Color get iconColor {
    if (isImage) return Colors.blue;
    if (isPdf) return Colors.red;
    switch (_ext) {
      case '.doc':
      case '.docx':
        return Colors.indigo;
      case '.xls':
      case '.xlsx':
        return Colors.green;
      case '.mp4':
      case '.mov':
      case '.avi':
        return Colors.purple;
      case '.zip':
      case '.rar':
      case '.7z':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  /// Label loại file ngắn gọn.
  String get typeLabel {
    if (isImage) return 'Hình ảnh';
    if (isPdf) return 'PDF';
    switch (_ext) {
      case '.doc':
      case '.docx':
        return 'Word';
      case '.xls':
      case '.xlsx':
        return 'Excel';
      case '.mp4':
      case '.mov':
      case '.avi':
        return 'Video';
      case '.zip':
      case '.rar':
      case '.7z':
        return 'Nén';
      default:
        return _ext.isNotEmpty ? _ext.substring(1).toUpperCase() : 'File';
    }
  }
}

// ─── FileOpener ───────────────────────────────────────────────────────────────

class FileOpener {
  FileOpener._();

  /// Mở file — tự động routing.
  ///
  /// [siblings]: Truyền toàn bộ danh sách file trong cùng nhóm tài liệu để
  /// gallery có thể swipe. Chỉ áp dụng khi [file] là ảnh.
  static Future<void> open(
    BuildContext context, {
    required OpenableFile file,
    List<OpenableFile> siblings = const [],
  }) async {
    if (file.isImage) {
      // Lọc ra tất cả ảnh trong siblings (bỏ qua PDF, doc...)
      final images = siblings.isEmpty
          ? [file]
          : siblings.where((f) => f.isImage).toList();

      final idx = images.indexWhere((f) => f.fileUrl == file.fileUrl);

      if (!context.mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => ImageGalleryScreen(
            files: images,
            initialIndex: idx < 0 ? 0 : idx,
          ),
        ),
      );
    } else if (file.isPdf) {
      if (!context.mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => PdfViewerScreen(file: file),
        ),
      );
    } else {
      await _downloadThenOpen(context, file: file);
    }
  }

  /// Download file về thư mục tạm rồi mở bằng app ngoài.
  static Future<void> _downloadThenOpen(
    BuildContext context, {
    required OpenableFile file,
  }) async {
    final progressNotifier = ValueNotifier<double>(0);
    bool cancelled = false;

    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _DownloadDialog(
        fileName: file.fileName,
        progress: progressNotifier,
        onCancel: () => cancelled = true,
      ),
    );

    try {
      final dir = await getTemporaryDirectory();
      // Đảm bảo tên file không trùng
      final savePath = path.join(
        dir.path,
        '${DateTime.now().millisecondsSinceEpoch}_${file.fileName}',
      );

      await Dio().download(
        file.fileUrl,
        savePath,
        onReceiveProgress: (recv, total) {
          if (total > 0) progressNotifier.value = recv / total;
        },
      );

      if (cancelled) return;
      if (!context.mounted) return;
      Navigator.pop(context); // đóng dialog

      final result = await OpenFilex.open(savePath);
      if (result.type != ResultType.done && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể mở: ${result.message}'),
            action: SnackBarAction(label: 'OK', onPressed: () {}),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      // Đóng dialog nếu còn mở
      if (Navigator.canPop(context)) Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi tải file: $e')));
    } finally {
      progressNotifier.dispose();
    }
  }
}

// ─── Download dialog ──────────────────────────────────────────────────────────

class _DownloadDialog extends StatelessWidget {
  final String fileName;
  final ValueNotifier<double> progress;
  final VoidCallback onCancel;

  const _DownloadDialog({
    required this.fileName,
    required this.progress,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          const SizedBox(width: 12),
          const Text('Đang tải...', style: TextStyle(fontSize: 16)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            fileName,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<double>(
            valueListenable: progress,
            builder: (_, val, _) => Column(
              children: [
                LinearProgressIndicator(
                  value: val > 0 ? val : null,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    val > 0
                        ? '${(val * 100).toStringAsFixed(0)}%'
                        : 'Đang kết nối...',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            onCancel();
            Navigator.pop(context);
          },
          child: const Text('Huỷ'),
        ),
      ],
    );
  }
}
