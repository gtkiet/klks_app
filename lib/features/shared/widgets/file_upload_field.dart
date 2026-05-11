// lib/features/shared/widgets/file_upload_field.dart
//
// Widget upload file đa năng:
//   - Chọn từ thư viện / camera / file manager
//   - Upload lên server NGAY KHI CHỌN → trả về fileId
//   - Tap vào file đã upload → xem preview:
//       • Ảnh  → full-screen PhotoView (pinch zoom, swipe đóng)
//       • PDF / file khác → url_launcher mở external app
//   - Xóa = chỉ xóa khỏi list yêu cầu, KHÔNG gọi API xóa server

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/file_model.dart';

typedef UploadFn =
    Future<List<UploadedFile>> Function({
      required List<File> files,
      required String targetContainer,
    });

class AppFileUploadField extends StatefulWidget {
  final String label;
  final String targetContainer;
  final UploadFn uploadFn;
  final List<UploadedFile> initialFiles;
  final int? maxFiles;
  final bool allowMultiple;
  final void Function(List<UploadedFile> files) onChanged;
  final bool isRequired;
  final bool enabled;

  const AppFileUploadField({
    super.key,
    required this.label,
    required this.targetContainer,
    required this.uploadFn,
    required this.onChanged,
    this.initialFiles = const [],
    this.maxFiles,
    this.allowMultiple = true,
    this.isRequired = false,
    this.enabled = true,
  });

  @override
  State<AppFileUploadField> createState() => _AppFileUploadFieldState();
}

class _AppFileUploadFieldState extends State<AppFileUploadField> {
  final List<UploadedFile> _uploaded = [];
  final Map<String, _PendingItem> _pending = {};

  @override
  void initState() {
    super.initState();
    _uploaded.addAll(widget.initialFiles);
  }

  bool get _canAddMore {
    if (!widget.enabled) return false;
    if (widget.maxFiles == null) return true;
    return (_uploaded.length + _pending.length) < widget.maxFiles!;
  }

  // ── Chọn + upload ngay ────────────────────────────────────────────────
  Future<void> _pickFiles() async {
    final source = await _showSourcePicker();
    if (source == null || !mounted) return;

    List<File> files = [];
    switch (source) {
      case _Source.gallery:
        final images = await ImagePicker().pickMultiImage();
        files = images.map((e) => File(e.path)).toList();
      case _Source.camera:
        final image = await ImagePicker().pickImage(source: ImageSource.camera);
        if (image != null) files = [File(image.path)];
      case _Source.file:
        final result = await FilePicker.pickFiles(
          allowMultiple: widget.allowMultiple,
          type: FileType.any,
        );
        if (result != null) {
          files = result.paths.whereType<String>().map(File.new).toList();
        }
    }

    if (files.isEmpty || !mounted) return;

    if (widget.maxFiles != null) {
      final remaining = widget.maxFiles! - _uploaded.length - _pending.length;
      if (remaining <= 0) return;
      files = files.take(remaining.clamp(0, files.length)).toList();
    }

    await _uploadFiles(files);
  }

  Future<void> _uploadFiles(List<File> files) async {
    final fileNames = files.map((f) => f.path.split('/').last).toList();

    setState(() {
      for (final name in fileNames) {
        _pending[name] = _PendingItem.loading();
      }
    });

    try {
      final results = await widget.uploadFn(
        files: files,
        targetContainer: widget.targetContainer,
      );
      if (!mounted) return;
      setState(() {
        for (final name in fileNames) {
          _pending.remove(name);
        }
        _uploaded.addAll(results);
      });
      widget.onChanged(List.unmodifiable(_uploaded));
    } catch (_) {
      if (!mounted) return;
      setState(() {
        for (final name in fileNames) {
          _pending.remove(name);
        }
      });
    }
  }

  // ── Xem file ──────────────────────────────────────────────────────────
  void _viewFile(UploadedFile file) {
    if (file.isImage) {
      final images = _uploaded.where((f) => f.isImage).toList();
      final initialIndex = images.indexOf(file);
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) => _PhotoGalleryScreen(
            images: images,
            initialIndex: initialIndex < 0 ? 0 : initialIndex,
          ),
        ),
      );
    } else {
      _launchUrl(file.fileUrl);
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Không thể mở file')));
    }
  }

  // ── Xóa — chỉ xóa khỏi list, KHÔNG gọi API ───────────────────────────
  void _removeFile(UploadedFile file) {
    setState(() => _uploaded.remove(file));
    widget.onChanged(List.unmodifiable(_uploaded));
  }

  Future<_Source?> _showSourcePicker() => showModalBottomSheet<_Source>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => const _SourceSheet(),
  );

  // ── Build ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasContent = _uploaded.isNotEmpty || _pending.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: TextSpan(
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            children: [
              TextSpan(text: widget.label),
              if (widget.isRequired)
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              if (widget.maxFiles != null)
                TextSpan(
                  text: '  (tối đa ${widget.maxFiles})',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w400,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        if (hasContent) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._uploaded.map(
                (f) => _FileChip(
                  file: f,
                  onTap: () => _viewFile(f),
                  onDelete: widget.enabled ? () => _removeFile(f) : null,
                ),
              ),
              ..._pending.entries.map(
                (e) => _PendingChip(fileName: e.key, item: e.value),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],

        if (_canAddMore)
          _AddFileButton(
            label: hasContent ? 'Thêm file' : 'Chọn file',
            onTap: _pickFiles,
          ),

        if (!_canAddMore && widget.maxFiles != null)
          Text(
            'Đã đạt giới hạn ${widget.maxFiles} file',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}

// =============================================================================
// PHOTO GALLERY SCREEN
// =============================================================================

class _PhotoGalleryScreen extends StatefulWidget {
  final List<UploadedFile> images;
  final int initialIndex;

  const _PhotoGalleryScreen({required this.images, required this.initialIndex});

  @override
  State<_PhotoGalleryScreen> createState() => _PhotoGalleryScreenState();
}

class _PhotoGalleryScreenState extends State<_PhotoGalleryScreen> {
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.images[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black54,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              current.fileName,
              style: const TextStyle(fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (widget.images.length > 1)
              Text(
                '${_currentIndex + 1} / ${widget.images.length}',
                style: const TextStyle(fontSize: 11, color: Colors.white70),
              ),
          ],
        ),
      ),
      body: PhotoViewGallery.builder(
        pageController: _pageController,
        itemCount: widget.images.length,
        onPageChanged: (i) => setState(() => _currentIndex = i),
        scrollPhysics: const BouncingScrollPhysics(),
        backgroundDecoration: const BoxDecoration(color: Colors.black),
        builder: (_, i) {
          final img = widget.images[i];
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(img.fileUrl),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 3,
            errorBuilder: (_, _, _) => const Center(
              child: Icon(Icons.broken_image, color: Colors.white54, size: 64),
            ),
          );
        },
        loadingBuilder: (_, _) => const Center(
          child: CircularProgressIndicator(color: Colors.white54),
        ),
      ),
    );
  }
}

// =============================================================================
// INTERNAL WIDGETS
// =============================================================================

class _FileChip extends StatelessWidget {
  final UploadedFile file;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _FileChip({required this.file, required this.onTap, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 120),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(8),
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.4,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(7),
              ),
              child: file.isImage
                  ? Image.network(
                      file.fileUrl,
                      height: 80,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _FileIconBox(file: file),
                    )
                  : _FileIconBox(file: file),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      file.fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  if (onDelete != null)
                    GestureDetector(
                      onTap: onDelete,
                      child: Icon(
                        Icons.close,
                        size: 14,
                        color: theme.colorScheme.error,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FileIconBox extends StatelessWidget {
  final UploadedFile file;
  const _FileIconBox({required this.file});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = file.isPdf
        ? Icons.picture_as_pdf_outlined
        : file.contentType.startsWith('video/')
        ? Icons.videocam_outlined
        : Icons.insert_drive_file_outlined;

    return Container(
      height: 80,
      width: double.infinity,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Icon(icon, size: 32, color: theme.colorScheme.onSurfaceVariant),
    );
  }
}

class _PendingChip extends StatelessWidget {
  final String fileName;
  final _PendingItem item;
  const _PendingChip({required this.fileName, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(maxWidth: 120),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(height: 6),
          Text(
            fileName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AddFileButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _AddFileButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: CustomPaint(
        painter: _DottedBorderPainter(color: theme.colorScheme.outline),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SourceSheet extends StatelessWidget {
  const _SourceSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            'Chọn file từ',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Thư viện ảnh'),
            onTap: () => Navigator.pop(context, _Source.gallery),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined),
            title: const Text('Chụp ảnh'),
            onTap: () => Navigator.pop(context, _Source.camera),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.folder_outlined),
            title: const Text('File manager'),
            onTap: () => Navigator.pop(context, _Source.file),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }
}

class _DottedBorderPainter extends CustomPainter {
  final Color color;
  static const _radius = Radius.circular(8);
  const _DottedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          _radius,
        ),
      );
    const dashLen = 6.0;
    const gapLen = 4.0;
    for (final metric in path.computeMetrics()) {
      var dist = 0.0;
      while (dist < metric.length) {
        final end = (dist + dashLen).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(dist, end), paint);
        dist += dashLen + gapLen;
      }
    }
  }

  @override
  bool shouldRepaint(_DottedBorderPainter old) => old.color != color;
}

// Internal models
class _PendingItem {
  final bool isLoading;
  const _PendingItem._({required this.isLoading});
  factory _PendingItem.loading() => const _PendingItem._(isLoading: true);
}

enum _Source { gallery, camera, file }
