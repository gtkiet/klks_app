
// lib/features/thanh_vien/widgets/tai_lieu_cu_tru_editor.dart
//
// Thêm hỗ trợ initialDocuments để pre-fill tài liệu cũ từ server.

import 'dart:io';

import 'package:flutter/material.dart';

import '../models/tai_lieu_cu_tru_request.dart';
import '../models/thong_tin_cu_dan_model.dart'; // TaiLieuCuTruModel, TaiLieuFileModel
import '../../utils/models/selector_item_model.dart';
import '../../utils/models/uploaded_file_model.dart';
import '../../utils/services/utils_service.dart';
import '../../utils/widgets/app_file_upload_field.dart';
import '../../utils/widgets/app_selector_field.dart';
import '../../cu_tru/widgets/shared_widget.dart';

typedef UploadFn =
    Future<List<UploadedFileModel>> Function({
      required List<File> files,
      required String targetContainer,
    });

class TaiLieuCuTruEditor extends StatefulWidget {
  /// Callback mỗi khi danh sách tài liệu thay đổi.
  final void Function(List<TaiLieuCuTruRequest> taiLieus) onChanged;

  /// Pre-fill tài liệu cũ từ server (dùng khi chỉnh sửa nháp).
  /// Null / rỗng = tạo mới từ đầu.
  final List<TaiLieuCuTruModel>? initialDocuments;

  const TaiLieuCuTruEditor({
    super.key,
    required this.onChanged,
    this.initialDocuments,
  });

  @override
  State<TaiLieuCuTruEditor> createState() => _TaiLieuCuTruEditorState();
}

class _TaiLieuCuTruEditorState extends State<TaiLieuCuTruEditor> {
  final _utilsService = UtilsService.instance;

  late final Future<List<SelectorItemModel>> _loaiGiayToFuture = _utilsService
      .getLoaiGiayToSelector();

  final List<_TaiLieuEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    // Pre-fill từ server nếu có
    final docs = widget.initialDocuments;
    if (docs != null && docs.isNotEmpty) {
      for (final doc in docs) {
        _entries.add(_TaiLieuEntry.fromServer(doc));
      }
    }
  }

  @override
  void dispose() {
    for (final e in _entries) {
      e.dispose();
    }
    super.dispose();
  }

  void _addEntry() {
    setState(() => _entries.add(_TaiLieuEntry()));
    _notify();
  }

  void _removeEntry(int index) {
    setState(() => _entries.removeAt(index));
    _notify();
  }

  void _notify() {
    final result = _entries
        .where((e) => e.activeFileIds.isNotEmpty)
        .map(
          (e) => TaiLieuCuTruRequest(
            taiLieuCuTruId: e.taiLieuCuTruId,
            loaiGiayToId: e.loaiGiayTo?.id,
            soGiayTo: e.soGiayToCtrl.text.trim(),
            ngayPhatHanh: e.ngayPhatHanh,
            fileIds: e.activeFileIds,
          ),
        )
        .toList();
    widget.onChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._entries.asMap().entries.map(
          (kv) => _TaiLieuCard(
            index: kv.key,
            entryData: kv.value,
            loaiGiayToFuture: _loaiGiayToFuture,
            uploadFn: _utilsService.uploadMedia,
            onChanged: _notify,
            onRemove: () => _removeEntry(kv.key),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _addEntry,
          icon: const Icon(Icons.add, size: 18),
          label: Text(
            _entries.isEmpty ? 'Thêm tài liệu' : 'Thêm tài liệu khác',
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 44),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// CARD MỘT TÀI LIỆU
// =============================================================================

class _TaiLieuCard extends StatefulWidget {
  final int index;
  final _TaiLieuEntry entryData;
  final Future<List<SelectorItemModel>> loaiGiayToFuture;
  final UploadFn uploadFn;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  const _TaiLieuCard({
    required this.index,
    required this.entryData,
    required this.loaiGiayToFuture,
    required this.uploadFn,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  State<_TaiLieuCard> createState() => _TaiLieuCardState();
}

class _TaiLieuCardState extends State<_TaiLieuCard> {
  @override
  void initState() {
    super.initState();
    widget.entryData.soGiayToCtrl.addListener(widget.onChanged);
  }

  @override
  void dispose() {
    widget.entryData.soGiayToCtrl.removeListener(widget.onChanged);
    super.dispose();
  }

  Future<void> _pickNgayPhatHanh() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.entryData.ngayPhatHanh ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => widget.entryData.ngayPhatHanh = picked);
      widget.onChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entry = widget.entryData;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  'Tài liệu ${widget.index + 1}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 18,
                    color: theme.colorScheme.error,
                  ),
                  onPressed: widget.onRemove,
                  tooltip: 'Xóa tài liệu này',
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const Divider(height: 16),

            // Loại giấy tờ
            AppSelectorField.future(
              label: 'Loại giấy tờ',
              future: widget.loaiGiayToFuture,
              selectedItems: entry.loaiGiayTo != null
                  ? [entry.loaiGiayTo!]
                  : [],
              onChangedSingle: (v) {
                setState(() => entry.loaiGiayTo = v);
                widget.onChanged();
              },
            ),
            const SizedBox(height: 10),

            // Số giấy tờ
            Field(
              controller: entry.soGiayToCtrl,
              label: 'Số giấy tờ',
              hint: 'VD: 012345678901',
            ),
            const SizedBox(height: 10),

            // Ngày phát hành
            DatePickerField(
              label: 'Ngày phát hành',
              value: entry.ngayPhatHanh,
              onTap: _pickNgayPhatHanh,
            ),
            const SizedBox(height: 10),

            // Files đã lưu từ server (badge "Đã lưu" + nút xóa)
            if (entry.existingFiles.isNotEmpty) ...[
              Text(
                'File đã lưu',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 4),
              ...entry.existingFiles.map((ef) {
                if (ef.deleted) return const SizedBox.shrink();
                return _ExistingFileRow(
                  file: ef.file,
                  onDelete: () {
                    setState(() => ef.deleted = true);
                    widget.onChanged();
                  },
                );
              }),
              const SizedBox(height: 8),
            ],

            // File mới upload
            AppFileUploadField(
              label: entry.existingFiles.isEmpty
                  ? 'File đính kèm'
                  : 'Thêm file mới',
              targetContainer: 'tai-lieu-cu-tru',
              uploadFn: widget.uploadFn,
              initialFiles: entry.newUploadedFiles,
              allowMultiple: true,
              onChanged: (files) {
                setState(() {
                  entry.newUploadedFiles
                    ..clear()
                    ..addAll(files);
                });
                widget.onChanged();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── File đã lưu từ server ────────────────────────────────────────────────────

class _ExistingFileRow extends StatelessWidget {
  final TaiLieuFileModel file;
  final VoidCallback onDelete;

  const _ExistingFileRow({required this.file, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isImage = file.contentType.startsWith('image/');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            isImage ? Icons.image_outlined : Icons.picture_as_pdf_outlined,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              file.fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Đã lưu',
              style: TextStyle(
                fontSize: 10,
                color: Colors.green.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: onDelete,
            borderRadius: BorderRadius.circular(12),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close, size: 16, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// DATA MODEL NỘI BỘ
// =============================================================================

// class _ExistingFileEntry {
//   final TaiLieuFileModel file;
//   bool deleted;
//   _ExistingFileEntry({required this.file, this.deleted = false});
// }
class _ExistingFileEntry {
  final TaiLieuFileModel file;
  bool deleted;
  _ExistingFileEntry({required this.file}) // ← FIXED: bỏ param `deleted`
    : deleted = false;
}

// class _TaiLieuEntry {
//   /// 0 = tạo mới, != 0 = update tài liệu cũ từ server
//   final int taiLieuCuTruId;

//   SelectorItemModel? loaiGiayTo;
//   final TextEditingController soGiayToCtrl;
//   DateTime? ngayPhatHanh;

//   /// File cũ từ server
//   final List<_ExistingFileEntry> existingFiles;

//   /// File mới người dùng upload trong phiên này
//   final List<UploadedFileModel> newUploadedFiles;

//   _TaiLieuEntry({
//     this.taiLieuCuTruId = 0,
//     SelectorItemModel? loaiGiayTo,
//     String soGiayTo = '',
//     DateTime? ngayPhatHanh,
//     List<_ExistingFileEntry>? existingFiles,
//     List<UploadedFileModel>? newUploadedFiles,
//   })  : loaiGiayTo = loaiGiayTo,
//         soGiayToCtrl = TextEditingController(text: soGiayTo),
//         ngayPhatHanh = ngayPhatHanh,
//         existingFiles = existingFiles ?? [],
//         newUploadedFiles = newUploadedFiles ?? [];

//   /// Constructor từ TaiLieuCuTruModel (server data)
//   factory _TaiLieuEntry.fromServer(TaiLieuCuTruModel doc) => _TaiLieuEntry(
//         taiLieuCuTruId: doc.id,
//         soGiayTo: doc.soGiayTo,
//         ngayPhatHanh: doc.ngayPhatHanh,
//         existingFiles:
//             doc.files.map((f) => _ExistingFileEntry(file: f)).toList(),
//       );
//   // loaiGiayTo pre-select sẽ được resolve sau khi catalog load xong
//   // (AppSelectorField.future tự resolve — chỉ cần truyền selectedItems
//   //  khi catalog đã sẵn sàng; hiện tại để null, user chọn lại nếu cần)

//   /// fileIds gửi lên server = file cũ còn lại + file mới
//   List<int> get activeFileIds => [
//         ...existingFiles.where((f) => !f.deleted).map((f) => f.file.id),
//         ...newUploadedFiles.map((f) => f.fileId),
//       ];

//   void dispose() => soGiayToCtrl.dispose();
// }
class _TaiLieuEntry {
  final int taiLieuCuTruId;

  SelectorItemModel? loaiGiayTo;
  final TextEditingController soGiayToCtrl;
  DateTime? ngayPhatHanh;
  final List<_ExistingFileEntry> existingFiles;
  final List<UploadedFileModel> newUploadedFiles;

  _TaiLieuEntry({
    this.taiLieuCuTruId = 0,
    String soGiayTo = '',
    this.ngayPhatHanh,
    List<_ExistingFileEntry>? existingFiles,
    List<UploadedFileModel>? newUploadedFiles,
  }) : loaiGiayTo = null, // ← FIXED: gán null trực tiếp
       soGiayToCtrl = TextEditingController(text: soGiayTo),
       existingFiles = existingFiles ?? [],
       newUploadedFiles = newUploadedFiles ?? [];

  factory _TaiLieuEntry.fromServer(TaiLieuCuTruModel doc) => _TaiLieuEntry(
    taiLieuCuTruId: doc.id,
    soGiayTo: doc.soGiayTo,
    ngayPhatHanh: doc.ngayPhatHanh,
    existingFiles: doc.files.map((f) => _ExistingFileEntry(file: f)).toList(),
    // loaiGiayTo vẫn null — user chọn lại hoặc resolve từ catalog
  );

  List<int> get activeFileIds => [
    ...existingFiles.where((f) => !f.deleted).map((f) => f.file.id),
    ...newUploadedFiles.map((f) => f.fileId),
  ];

  void dispose() => soGiayToCtrl.dispose();
}

