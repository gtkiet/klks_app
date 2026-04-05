// lib/features/cu_tru/widgets/file_list_tile.dart
//
// Widget hiển thị một file trong danh sách + tap để mở.
// Dùng ở mọi nơi có list tài liệu: ThongTinCuDanScreen, ChiTietYeuCauScreen, v.v.
//
// Ví dụ dùng đơn:
//   FileListTile(file: OpenableFile.fromTaiLieu(f))
//
// Ví dụ dùng trong nhóm (để gallery swipe ảnh):
//   ...doc.files.map((f) => FileListTile(
//         file: OpenableFile.fromTaiLieu(f),
//         siblings: doc.files.map(OpenableFile.fromTaiLieu).toList(),
//       ))

import 'package:flutter/material.dart';

import '../utils/file_opener.dart';

class FileListTile extends StatelessWidget {
  final OpenableFile file;

  /// Tất cả file trong cùng nhóm tài liệu — cho phép swipe gallery khi xem ảnh.
  final List<OpenableFile> siblings;

  /// Nếu true: hiển thị dạng Card; false: ListTile thường.
  final bool asCard;

  const FileListTile({
    super.key,
    required this.file,
    this.siblings = const [],
    this.asCard = false,
  });

  @override
  Widget build(BuildContext context) {
    final tile = ListTile(
      onTap: () => FileOpener.open(context, file: file, siblings: siblings),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      leading: _FileIcon(file: file),
      title: Text(
        file.fileName,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        file.typeLabel,
        style: const TextStyle(fontSize: 11, color: Colors.grey),
      ),
      trailing: Icon(
        file.isImage
            ? Icons.fullscreen
            : file.isPdf
            ? Icons.picture_as_pdf_outlined
            : Icons.open_in_new,
        size: 18,
        color: Colors.grey,
      ),
    );

    if (asCard) {
      return Card(margin: const EdgeInsets.only(bottom: 6), child: tile);
    }
    return tile;
  }
}

// ─── FileIcon ────────────────────────────────────────────────────────────────

class _FileIcon extends StatelessWidget {
  final OpenableFile file;
  const _FileIcon({required this.file});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: file.iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: file.iconColor.withValues(alpha: 0.3)),
      ),
      child: Icon(file.icon, color: file.iconColor, size: 20),
    );
  }
}

// ─── FileGrid ─────────────────────────────────────────────────────────────────
//
// Hiển thị danh sách file dạng lưới thumbnail (chỉ ảnh mới có thumbnail).
// Các file không phải ảnh hiển thị icon placeholder.

class FileGrid extends StatelessWidget {
  final List<OpenableFile> files;
  final int crossAxisCount;

  const FileGrid({super.key, required this.files, this.crossAxisCount = 3});

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Không có file', style: TextStyle(color: Colors.grey)),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemCount: files.length,
      itemBuilder: (_, i) => _GridCell(
        file: files[i],
        onTap: () => FileOpener.open(context, file: files[i], siblings: files),
      ),
    );
  }
}

class _GridCell extends StatelessWidget {
  final OpenableFile file;
  final VoidCallback onTap;

  const _GridCell({required this.file, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: file.isImage
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    file.fileUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _Placeholder(file: file),
                  ),
                  // Overlay khi hover / press
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onTap,
                      child: const SizedBox.expand(),
                    ),
                  ),
                ],
              )
            : _Placeholder(file: file),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final OpenableFile file;
  const _Placeholder({required this.file});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: file.iconColor.withValues(alpha: 0.08),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(file.icon, color: file.iconColor, size: 28),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              file.typeLabel,
              style: TextStyle(fontSize: 10, color: file.iconColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
