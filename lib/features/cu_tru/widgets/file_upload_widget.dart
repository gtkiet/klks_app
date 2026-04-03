// lib/features/cu_tru/widgets/file_upload_widget.dart
//
// Widget nhúng trực tiếp vào form (không phải màn hình riêng).
// Dùng khi TaoYeuCauScreen / ChiTietYeuCauScreen cần upload inline.
//
// Ví dụ dùng:
//
//   FileUploadWidget(
//     label: 'Tài liệu CCCD',
//     targetContainer: 'tai-lieu-cu-tru',
//     allowedTypes: FileTypePreset.imageAndDocument,
//     maxFiles: 3,
//     onFilesChanged: (uploadedFiles) {
//       setState(() => _uploadedFiles = uploadedFiles);
//     },
//   )

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
// import 'package:path/path.dart' as path;

import '../models/yeu_cau_cu_tru_model.dart';
import '../services/cu_tru_service.dart';
import '../screens/upload_media_screen.dart';

class FileUploadWidget extends StatefulWidget {
  /// Nhãn hiển thị trên widget
  final String label;

  /// targetContainer gửi lên API
  final String targetContainer;

  /// Loại file được chấp nhận
  final List<AllowedFileType> allowedTypes;

  /// Số file tối đa (0 = không giới hạn)
  final int maxFiles;

  /// Kích thước tối đa mỗi file (MB). 0 = không kiểm tra.
  final int maxFileSizeMb;

  /// Callback mỗi khi danh sách uploaded thay đổi
  final ValueChanged<List<UploadedFileModel>> onFilesChanged;

  /// Danh sách file đã upload trước đó (nếu đang edit)
  final List<UploadedFileModel> initialFiles;

  const FileUploadWidget({
    super.key,
    required this.label,
    required this.onFilesChanged,
    this.targetContainer = 'tai-lieu-cu-tru',
    this.allowedTypes = FileTypePreset.imageAndDocument,
    this.maxFiles = 5,
    this.maxFileSizeMb = 20,
    this.initialFiles = const [],
  });

  @override
  State<FileUploadWidget> createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  final _service = CuTruService();

  // File đã upload thành công (gồm cả initialFiles)
  late List<UploadedFileModel> _uploaded;

  // File đang chờ / đang upload (chưa có result)
  final List<_InlineFile> _pending = [];

  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _uploaded = List.from(widget.initialFiles);
  }

  List<String> get _allowedExtensions =>
      widget.allowedTypes.expand((t) => t.extensions).toList();

  int get _totalCount => _uploaded.length + _pending.length;
  bool get _canAddMore => widget.maxFiles == 0 || _totalCount < widget.maxFiles;

  Future<void> _pickFiles() async {
    if (!_canAddMore) {
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

    final toAdd = <_InlineFile>[];
    for (final f in result.files) {
      if (!_canAddMore && toAdd.isEmpty) break;
      if (widget.maxFiles > 0 &&
          _totalCount + toAdd.length >= widget.maxFiles) {
        _showSnack('Chỉ có thể thêm tối đa ${widget.maxFiles} file.');
        break;
      }
      // Kiểm tra trùng
      if (_pending.any((e) => e.path == f.path)) continue;
      // Kiểm tra size
      final sizeMb = f.size / (1024 * 1024);
      if (widget.maxFileSizeMb > 0 && sizeMb > widget.maxFileSizeMb) {
        _showSnack('"${f.name}" vượt ${widget.maxFileSizeMb}MB. Bỏ qua.');
        continue;
      }
      if (f.path != null) {
        toAdd.add(_InlineFile(path: f.path!, name: f.name, sizeBytes: f.size));
      }
    }

    if (toAdd.isEmpty) return;
    setState(() => _pending.addAll(toAdd));
    await _uploadPending();
  }

  Future<void> _uploadPending() async {
    final notYetUploaded = _pending
        .where((f) => f.status == _InlineStatus.pending)
        .toList();
    if (notYetUploaded.isEmpty) return;

    setState(() => _isUploading = true);

    for (final pf in notYetUploaded) {
      setState(() => pf.status = _InlineStatus.uploading);
      try {
        final results = await _service.uploadMedia(
          files: [File(pf.path)],
          targetContainer: widget.targetContainer,
        );
        setState(() {
          pf.status = _InlineStatus.done;
          _uploaded.add(results.first);
          _pending.remove(pf);
        });
        widget.onFilesChanged(List.from(_uploaded));
      } catch (e) {
        setState(() {
          pf.status = _InlineStatus.error;
          pf.error = e.toString();
        });
      }
    }

    setState(() => _isUploading = false);
  }

  void _removeUploaded(UploadedFileModel f) {
    setState(() => _uploaded.remove(f));
    widget.onFilesChanged(List.from(_uploaded));
  }

  void _removePending(_InlineFile f) {
    if (f.status == _InlineStatus.uploading) return;
    setState(() => _pending.remove(f));
  }

  void _retryPending(_InlineFile f) {
    setState(() => f.status = _InlineStatus.pending);
    _uploadPending();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ──────────────────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (widget.maxFiles > 0)
              Text(
                '$_totalCount/${widget.maxFiles}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // ── Loại file chấp nhận ──────────────────────────────────────────
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: widget.allowedTypes.map((t) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: t.color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: t.color.withValues(alpha: 0.25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(t.icon, size: 12, color: t.color),
                  const SizedBox(width: 4),
                  Text(t.label, style: TextStyle(fontSize: 11, color: t.color)),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),

        // ── Danh sách file đã upload ─────────────────────────────────────
        ..._uploaded.map(
          (f) => _UploadedChip(file: f, onRemove: () => _removeUploaded(f)),
        ),

        // ── Danh sách file đang pending/uploading/error ──────────────────
        ..._pending.map(
          (f) => _PendingChip(
            file: f,
            onRemove: () => _removePending(f),
            onRetry: () => _retryPending(f),
          ),
        ),

        // ── Nút thêm file ────────────────────────────────────────────────
        const SizedBox(height: 8),
        InkWell(
          onTap: _isUploading || !_canAddMore ? null : _pickFiles,
          borderRadius: BorderRadius.circular(8),
          child: DottedBorder(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isUploading)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Icon(
                      Icons.add_circle_outline,
                      size: 18,
                      color: _canAddMore ? Colors.blue : Colors.grey,
                    ),
                  const SizedBox(width: 8),
                  Text(
                    _isUploading
                        ? 'Đang upload...'
                        : _canAddMore
                        ? 'Nhấn để chọn file'
                        : 'Đã đạt giới hạn',
                    style: TextStyle(
                      fontSize: 13,
                      color: _canAddMore ? Colors.blue : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── DottedBorder (đơn giản, không cần package) ───────────────────────────────

class DottedBorder extends StatelessWidget {
  final Widget child;
  const DottedBorder({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.4),
          width: 1.5,
          style: BorderStyle.solid,
        ),
      ),
      child: child,
    );
  }
}

// ─── Chip: file đã upload thành công ─────────────────────────────────────────

class _UploadedChip extends StatelessWidget {
  final UploadedFileModel file;
  final VoidCallback onRemove;

  const _UploadedChip({required this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              file.fileName,
              style: const TextStyle(fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// ─── Chip: file đang pending / uploading / error ──────────────────────────────

enum _InlineStatus { pending, uploading, done, error }

class _InlineFile {
  final String path;
  final String name;
  final int sizeBytes;
  _InlineStatus status;
  String? error;

  _InlineFile({required this.path, required this.name, required this.sizeBytes})
    : status = _InlineStatus.pending;
}

class _PendingChip extends StatelessWidget {
  final _InlineFile file;
  final VoidCallback onRemove;
  final VoidCallback onRetry;

  const _PendingChip({
    required this.file,
    required this.onRemove,
    required this.onRetry,
  });

  String _formatSize(int bytes) {
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(0)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Widget leading;
    String subtitle;

    switch (file.status) {
      case _InlineStatus.uploading:
        borderColor = Colors.blue;
        leading = const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
        subtitle = 'Đang upload...';
      case _InlineStatus.error:
        borderColor = Colors.red;
        leading = const Icon(Icons.error_outline, color: Colors.red, size: 16);
        subtitle = file.error ?? 'Lỗi không xác định';
      default:
        borderColor = Colors.grey.shade300;
        leading = Icon(
          Icons.insert_drive_file_outlined,
          color: Colors.grey.shade400,
          size: 16,
        );
        subtitle = _formatSize(file.sizeBytes);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: const TextStyle(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: file.status == _InlineStatus.error
                        ? Colors.red
                        : Colors.grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (file.status == _InlineStatus.error)
            IconButton(
              icon: const Icon(Icons.refresh, size: 18, color: Colors.orange),
              onPressed: onRetry,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            )
          else if (file.status != _InlineStatus.uploading)
            GestureDetector(
              onTap: onRemove,
              child: const Icon(Icons.close, size: 16, color: Colors.grey),
            ),
        ],
      ),
    );
  }
}
