// lib/features/cu_tru/screens/upload_media_screen.dart
//
// Screen độc lập: Upload file đa loại, có thể cấu hình loại file chấp nhận.
// Tích hợp vào TaoYeuCauScreen hoặc ChiTietYeuCauScreen.
//
// Cách dùng:
//   final uploaded = await Navigator.push<List<UploadedFileModel>>(
//     context,
//     MaterialPageRoute(
//       builder: (_) => UploadMediaScreen(
//         targetContainer: 'tai-lieu-cu-tru',
//         allowedTypes: FileTypePreset.document,   // hoặc custom
//         maxFiles: 5,
//       ),
//     ),
//   );
//   if (uploaded != null) { /* dùng uploaded */ }

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

import '../models/yeu_cau_cu_tru_model.dart';
import '../services/cu_tru_service.dart';

// ─── Cấu hình loại file ───────────────────────────────────────────────────────

/// Định nghĩa một loại file được phép upload.
class AllowedFileType {
  final String label; // Tên hiển thị, VD: "PDF"
  final List<String> extensions; // Không có dấu chấm, VD: ['pdf']
  final IconData icon;
  final Color color;

  const AllowedFileType({
    required this.label,
    required this.extensions,
    required this.icon,
    required this.color,
  });
}

/// Bộ preset sẵn cho các use case thường gặp trong hệ thống cư trú.
class FileTypePreset {
  FileTypePreset._();

  static const List<AllowedFileType> image = [
    AllowedFileType(
      label: 'Hình ảnh',
      extensions: ['jpg', 'jpeg', 'png', 'webp', 'heic'],
      icon: Icons.image_outlined,
      color: Colors.blue,
    ),
  ];

  static const List<AllowedFileType> document = [
    AllowedFileType(
      label: 'PDF',
      extensions: ['pdf'],
      icon: Icons.picture_as_pdf_outlined,
      color: Colors.red,
    ),
    AllowedFileType(
      label: 'Word',
      extensions: ['doc', 'docx'],
      icon: Icons.description_outlined,
      color: Colors.indigo,
    ),
    AllowedFileType(
      label: 'Excel',
      extensions: ['xls', 'xlsx'],
      icon: Icons.table_chart_outlined,
      color: Colors.green,
    ),
  ];

  static const List<AllowedFileType> imageAndDocument = [
    AllowedFileType(
      label: 'Hình ảnh',
      extensions: ['jpg', 'jpeg', 'png', 'webp', 'heic'],
      icon: Icons.image_outlined,
      color: Colors.blue,
    ),
    AllowedFileType(
      label: 'PDF',
      extensions: ['pdf'],
      icon: Icons.picture_as_pdf_outlined,
      color: Colors.red,
    ),
    AllowedFileType(
      label: 'Word',
      extensions: ['doc', 'docx'],
      icon: Icons.description_outlined,
      color: Colors.indigo,
    ),
  ];

  static const List<AllowedFileType> all = [
    AllowedFileType(
      label: 'Hình ảnh',
      extensions: ['jpg', 'jpeg', 'png', 'webp', 'heic', 'gif'],
      icon: Icons.image_outlined,
      color: Colors.blue,
    ),
    AllowedFileType(
      label: 'PDF',
      extensions: ['pdf'],
      icon: Icons.picture_as_pdf_outlined,
      color: Colors.red,
    ),
    AllowedFileType(
      label: 'Word',
      extensions: ['doc', 'docx'],
      icon: Icons.description_outlined,
      color: Colors.indigo,
    ),
    AllowedFileType(
      label: 'Excel',
      extensions: ['xls', 'xlsx'],
      icon: Icons.table_chart_outlined,
      color: Colors.green,
    ),
    AllowedFileType(
      label: 'Video',
      extensions: ['mp4', 'mov', 'avi'],
      icon: Icons.videocam_outlined,
      color: Colors.purple,
    ),
    AllowedFileType(
      label: 'Zip / Nén',
      extensions: ['zip', 'rar', '7z'],
      icon: Icons.folder_zip_outlined,
      color: Colors.orange,
    ),
  ];
}

// ─── PickedFile: trạng thái từng file trong danh sách ───────────────────────

enum _PickedFileStatus { pending, uploading, done, error }

class _PickedFile {
  final String path;
  final String name;
  final int sizeBytes;
  _PickedFileStatus status;
  String? errorMessage;
  UploadedFileModel? uploaded;

  _PickedFile({
    required this.path,
    required this.name,
    required this.sizeBytes,
    // this.status = _PickedFileStatus.pending,
  }) : status = _PickedFileStatus.pending;

  bool get isDone => status == _PickedFileStatus.done;
  bool get isError => status == _PickedFileStatus.error;
  bool get isUploading => status == _PickedFileStatus.uploading;
}

// ─── UploadMediaScreen ────────────────────────────────────────────────────────

class UploadMediaScreen extends StatefulWidget {
  /// targetContainer gửi lên API (mặc định: 'tai-lieu-cu-tru')
  final String targetContainer;

  /// Danh sách loại file được chấp nhận. Dùng [FileTypePreset.*] hoặc custom.
  final List<AllowedFileType> allowedTypes;

  /// Số file tối đa được chọn cùng lúc (0 = không giới hạn)
  final int maxFiles;

  /// Kích thước tối đa mỗi file (MB). 0 = không kiểm tra.
  final int maxFileSizeMb;

  const UploadMediaScreen({
    super.key,
    this.targetContainer = 'tai-lieu-cu-tru',
    this.allowedTypes = FileTypePreset.imageAndDocument,
    this.maxFiles = 10,
    this.maxFileSizeMb = 20,
  });

  @override
  State<UploadMediaScreen> createState() => _UploadMediaScreenState();
}

class _UploadMediaScreenState extends State<UploadMediaScreen> {
  final _service = CuTruService();

  final List<_PickedFile> _files = [];
  bool _isUploadingAll = false;

  // Tất cả extensions được chấp nhận (flatten)
  List<String> get _allowedExtensions =>
      widget.allowedTypes.expand((t) => t.extensions).toList();

  bool get _hasAllDone => _files.isNotEmpty && _files.every((f) => f.isDone);

  bool get _hasPending =>
      _files.any((f) => f.status == _PickedFileStatus.pending);

  List<UploadedFileModel> get _successfulUploads =>
      _files.where((f) => f.isDone).map((f) => f.uploaded!).toList();

  // ── Chọn file ───────────────────────────────────────────────────────────────

  Future<void> _pickFiles() async {
    final remaining = widget.maxFiles > 0
        ? widget.maxFiles - _files.length
        : null;

    if (remaining != null && remaining <= 0) {
      _showSnack('Đã đạt giới hạn ${widget.maxFiles} file.');
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: _allowedExtensions,
      withData: false,
    );

    if (result == null || result.files.isEmpty) return;

    final newFiles = <_PickedFile>[];

    for (final f in result.files) {
      // Kiểm tra số lượng
      if (widget.maxFiles > 0 &&
          (_files.length + newFiles.length) >= widget.maxFiles) {
        _showSnack('Chỉ có thể thêm tối đa ${widget.maxFiles} file.');
        break;
      }

      // Kiểm tra trùng
      if (_files.any((existing) => existing.path == f.path)) continue;

      // Kiểm tra size
      final sizeMb = (f.size) / (1024 * 1024);
      if (widget.maxFileSizeMb > 0 && sizeMb > widget.maxFileSizeMb) {
        _showSnack('"${f.name}" vượt quá ${widget.maxFileSizeMb}MB. Bỏ qua.');
        continue;
      }

      if (f.path != null) {
        newFiles.add(
          _PickedFile(path: f.path!, name: f.name, sizeBytes: f.size),
        );
      }
    }

    if (newFiles.isNotEmpty) {
      setState(() => _files.addAll(newFiles));
    }
  }

  // ── Upload từng file ─────────────────────────────────────────────────────────

  Future<void> _uploadSingle(_PickedFile pf) async {
    setState(() {
      pf.status = _PickedFileStatus.uploading;
      pf.errorMessage = null;
    });

    try {
      final results = await _service.uploadMedia(
        files: [File(pf.path)],
        targetContainer: widget.targetContainer,
      );

      setState(() {
        pf.status = _PickedFileStatus.done;
        pf.uploaded = results.first;
      });
    } catch (e) {
      setState(() {
        pf.status = _PickedFileStatus.error;
        pf.errorMessage = e.toString();
      });
    }
  }

  // ── Upload tất cả pending ────────────────────────────────────────────────────

  Future<void> _uploadAll() async {
    final pending = _files
        .where((f) => f.status == _PickedFileStatus.pending)
        .toList();
    if (pending.isEmpty) return;

    setState(() => _isUploadingAll = true);

    // Upload tuần tự để tránh quá tải
    for (final f in pending) {
      await _uploadSingle(f);
    }

    setState(() => _isUploadingAll = false);

    final failCount = _files
        .where((f) => f.status == _PickedFileStatus.error)
        .length;
    if (failCount > 0) {
      _showSnack('⚠️ $failCount file upload thất bại. Nhấn retry.');
    } else {
      _showSnack('✅ Upload hoàn tất!');
    }
  }

  void _removeFile(_PickedFile pf) {
    if (pf.isUploading) return; // không xóa khi đang upload
    setState(() => _files.remove(pf));
  }

  void _retryFile(_PickedFile pf) => _uploadSingle(pf);

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _done() {
    Navigator.pop(context, _successfulUploads);
  }

  // ── UI ───────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload tài liệu'),
        actions: [
          if (_successfulUploads.isNotEmpty)
            TextButton(
              onPressed: _done,
              child: Text('Xong (${_successfulUploads.length})'),
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Loại file chấp nhận ──────────────────────────────────────────
          _AllowedTypesBar(types: widget.allowedTypes),

          // ── Danh sách file đã chọn ───────────────────────────────────────
          Expanded(
            child: _files.isEmpty
                ? _EmptyState(onPick: _pickFiles)
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    itemCount: _files.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _FileCard(
                      file: _files[i],
                      onRemove: () => _removeFile(_files[i]),
                      onRetry: () => _retryFile(_files[i]),
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomBar(
        files: _files,
        maxFiles: widget.maxFiles,
        isUploadingAll: _isUploadingAll,
        hasPending: _hasPending,
        hasAllDone: _hasAllDone,
        doneCount: _successfulUploads.length,
        onPick: _pickFiles,
        onUploadAll: _uploadAll,
        onDone: _done,
      ),
    );
  }
}

// ─── AllowedTypesBar ──────────────────────────────────────────────────────────

class _AllowedTypesBar extends StatelessWidget {
  final List<AllowedFileType> types;
  const _AllowedTypesBar({required this.types});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Text(
            'Chấp nhận: ',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: types.map((t) {
                return Chip(
                  avatar: Icon(t.icon, size: 14, color: t.color),
                  label: Text(
                    '${t.label} (.${t.extensions.join(', .')})',
                    style: const TextStyle(fontSize: 11),
                  ),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  backgroundColor: t.color.withValues(alpha: 0.08),
                  side: BorderSide(color: t.color.withValues(alpha: 0.3)),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── EmptyState ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onPick;
  const _EmptyState({required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_upload_outlined,
            size: 72,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có file nào được chọn',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Nhấn nút bên dưới để chọn file',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onPick,
            icon: const Icon(Icons.add),
            label: const Text('Chọn file'),
          ),
        ],
      ),
    );
  }
}

// ─── FileCard ─────────────────────────────────────────────────────────────────

class _FileCard extends StatelessWidget {
  final _PickedFile file;
  final VoidCallback onRemove;
  final VoidCallback onRetry;

  const _FileCard({
    required this.file,
    required this.onRemove,
    required this.onRetry,
  });

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  IconData _iconForExtension(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'doc':
      case 'docx':
        return Icons.description_outlined;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart_outlined;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'webp':
      case 'heic':
      case 'gif':
        return Icons.image_outlined;
      case 'mp4':
      case 'mov':
      case 'avi':
        return Icons.videocam_outlined;
      case 'zip':
      case 'rar':
      case '7z':
        return Icons.folder_zip_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  Color _colorForExtension(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.indigo;
      case 'xls':
      case 'xlsx':
        return Colors.green;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'webp':
      case 'heic':
      case 'gif':
        return Colors.blue;
      case 'mp4':
      case 'mov':
      case 'avi':
        return Colors.purple;
      case 'zip':
      case 'rar':
      case '7z':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = path.extension(file.name).replaceFirst('.', '');
    final color = _colorForExtension(ext);
    final icon = _iconForExtension(ext);

    Widget trailingWidget;
    switch (file.status) {
      case _PickedFileStatus.uploading:
        trailingWidget = const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case _PickedFileStatus.done:
        trailingWidget = const Icon(Icons.check_circle, color: Colors.green);
      case _PickedFileStatus.error:
        trailingWidget = IconButton(
          icon: const Icon(Icons.refresh, color: Colors.orange),
          onPressed: onRetry,
          tooltip: 'Thử lại',
        );
      case _PickedFileStatus.pending:
        trailingWidget = IconButton(
          icon: const Icon(Icons.close, color: Colors.grey),
          onPressed: onRemove,
          tooltip: 'Xóa',
        );
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Icon loại file
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),

            // Tên + thông tin
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        _formatSize(file.sizeBytes),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                      if (file.isError && file.errorMessage != null) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            file.errorMessage!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.red,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      if (file.isDone && file.uploaded != null) ...[
                        const SizedBox(width: 8),
                        const Text(
                          'Đã upload',
                          style: TextStyle(fontSize: 11, color: Colors.green),
                        ),
                      ],
                    ],
                  ),
                  // Progress bar khi uploading
                  if (file.isUploading) ...[
                    const SizedBox(height: 6),
                    const LinearProgressIndicator(),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 8),
            trailingWidget,
          ],
        ),
      ),
    );
  }
}

// ─── BottomBar ────────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final List<_PickedFile> files;
  final int maxFiles;
  final bool isUploadingAll;
  final bool hasPending;
  final bool hasAllDone;
  final int doneCount;
  final VoidCallback onPick;
  final VoidCallback onUploadAll;
  final VoidCallback onDone;

  const _BottomBar({
    required this.files,
    required this.maxFiles,
    required this.isUploadingAll,
    required this.hasPending,
    required this.hasAllDone,
    required this.doneCount,
    required this.onPick,
    required this.onUploadAll,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final total = files.length;
    final remaining = maxFiles > 0 ? maxFiles - total : null;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor, width: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Thông tin số lượng
            if (maxFiles > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Text(
                      'Đã chọn: $total / $maxFiles file',
                      style: TextStyle(
                        fontSize: 12,
                        color: remaining == 0 ? Colors.orange : Colors.grey,
                      ),
                    ),
                    const Spacer(),
                    if (doneCount > 0)
                      Text(
                        'Upload thành công: $doneCount',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                        ),
                      ),
                  ],
                ),
              ),

            // Buttons
            Row(
              children: [
                // Thêm file
                if (remaining == null || remaining > 0)
                  OutlinedButton.icon(
                    onPressed: isUploadingAll ? null : onPick,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Thêm file'),
                  ),
                const SizedBox(width: 8),

                // Upload / Xong
                Expanded(
                  child: hasAllDone
                      ? FilledButton.icon(
                          onPressed: onDone,
                          icon: const Icon(Icons.check),
                          label: Text('Xong ($doneCount file)'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        )
                      : FilledButton.icon(
                          onPressed: (hasPending && !isUploadingAll)
                              ? onUploadAll
                              : null,
                          icon: isUploadingAll
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.cloud_upload_outlined),
                          label: Text(
                            isUploadingAll ? 'Đang upload...' : 'Upload tất cả',
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
