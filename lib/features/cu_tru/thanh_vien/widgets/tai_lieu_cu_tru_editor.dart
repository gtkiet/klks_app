// lib/features/cu_tru/thanh_vien/widgets/tai_lieu_cu_tru_editor.dart

import 'dart:io';
import 'package:flutter/material.dart';

import '../models/tai_lieu_cu_tru_request.dart';
import '../models/thong_tin_cu_dan_model.dart';

import '../../quan_he/models/selector_item_model.dart';
import '../../quan_he/models/uploaded_file_model.dart';

import '../services/tv_yeu_cau_service.dart';

import '../../quan_he/widgets/shared_widget.dart';

import '../../quan_he/widgets/file_upload_field.dart';
import '../../quan_he/widgets/selector_field.dart';

typedef UploadFn =
    Future<List<UploadedFileModel>> Function({
      required List<File> files,
      required String targetContainer,
    });

// =============================================================================
// PUBLIC WIDGET
// =============================================================================

class TaiLieuCuTruEditor extends StatefulWidget {
  /// Callback mỗi khi danh sách tài liệu thay đổi.
  final void Function(List<TaiLieuCuTruRequest>) onChanged;

  /// Pre-fill tài liệu cũ từ server (dùng khi chỉnh sửa nháp / yêu cầu sửa).
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
  final _yeuCauSvc = YeuCauCuTruService.instance;

  // Future được khởi tạo 1 lần — chia sẻ với tất cả _TaiLieuCard.
  late final Future<List<SelectorItemModel>> _loaiGiayToFuture = _yeuCauSvc
      .getLoaiGiayToSelector();

  final List<_TaiLieuEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    final docs = widget.initialDocuments;
    if (docs != null && docs.isNotEmpty) {
      for (final doc in docs) {
        _entries.add(_TaiLieuEntry.fromServer(doc));
      }
      // Resolve loaiGiayTo cho tất cả entries sau khi catalog sẵn sàng.
      _resolveLoaiGiayTo();
    }
  }

  /// Sau khi catalog load xong, match loaiGiayToId → SelectorItemModel.
  Future<void> _resolveLoaiGiayTo() async {
    try {
      final catalog = await _loaiGiayToFuture;
      if (!mounted) return;
      var changed = false;
      for (final entry in _entries) {
        if (entry._pendingLoaiGiayToId != null && entry.loaiGiayTo == null) {
          final match = catalog
              .where((e) => e.id == entry._pendingLoaiGiayToId)
              .firstOrNull;
          if (match != null) {
            entry.loaiGiayTo = match;
            changed = true;
          }
        }
      }
      if (changed) setState(() {});
    } catch (_) {
      // Catalog lỗi → user tự chọn lại, không crash.
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
    _entries[index].dispose();
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
            // Key cố định theo index — đảm bảo card không bị recreate
            // khi screen cha gọi setState (VD: hiển thị submit error).
            key: ValueKey('tai_lieu_card_${kv.key}'),
            index: kv.key,
            entry: kv.value,
            loaiGiayToFuture: _loaiGiayToFuture,
            uploadFn: _yeuCauSvc.uploadMedia,
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
  final _TaiLieuEntry entry;
  final Future<List<SelectorItemModel>> loaiGiayToFuture;
  final UploadFn uploadFn;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  const _TaiLieuCard({
    super.key,
    required this.index,
    required this.entry,
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
    widget.entry.soGiayToCtrl.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.entry.soGiayToCtrl.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() => widget.onChanged();

  Future<void> _pickNgayPhatHanh() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.entry.ngayPhatHanh ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() => widget.entry.ngayPhatHanh = picked);
      widget.onChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entry = widget.entry;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────────
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

            // ── Loại giấy tờ ──────────────────────────────────────────────
            // FIX: truyền selectedItems từ entry.loaiGiayTo (đã resolve)
            // thay vì luôn để rỗng.
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

            // ── Số giấy tờ ────────────────────────────────────────────────
            Field(
              controller: entry.soGiayToCtrl,
              label: 'Số giấy tờ',
              hint: 'VD: 012345678901',
            ),
            const SizedBox(height: 10),

            // ── Ngày phát hành ────────────────────────────────────────────
            DatePickerField(
              label: 'Ngày phát hành',
              value: entry.ngayPhatHanh,
              onTap: _pickNgayPhatHanh,
            ),
            const SizedBox(height: 10),

            // ── File cũ từ server ─────────────────────────────────────────
            if (entry.existingFiles.any((f) => !f.deleted)) ...[
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

            // ── File mới upload ───────────────────────────────────────────
            // FIX: AppFileUploadField nhận initialFiles = entry.newUploadedFiles.
            // Vì _TaiLieuCard có key cố định (ValueKey), widget này KHÔNG bị
            // recreate khi screen cha setState → State bên trong giữ nguyên
            // danh sách file đã upload. Không cần truyền lại initialFiles mỗi
            // lần rebuild.
            AppFileUploadField(
              label: entry.existingFiles.isEmpty
                  ? 'File đính kèm'
                  : 'Thêm file mới',
              targetContainer: 'tai-lieu-cu-tru',
              uploadFn: widget.uploadFn,
              initialFiles: entry.newUploadedFiles,
              allowMultiple: true,
              onChanged: (files) {
                // Sync lại entry để _notify() có thể đọc fileIds mới nhất.
                entry.newUploadedFiles
                  ..clear()
                  ..addAll(files);
                widget.onChanged();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// FILE CŨ TỪ SERVER
// =============================================================================

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
// DATA MODELS NỘI BỘ
// =============================================================================

class _ExistingFileEntry {
  final TaiLieuFileModel file;
  bool deleted;

  _ExistingFileEntry({required this.file}) : deleted = false;
}

class _TaiLieuEntry {
  /// 0 = tạo mới, != 0 = update tài liệu cũ từ server.
  final int taiLieuCuTruId;

  /// ID cần resolve sang SelectorItemModel sau khi catalog load xong.
  /// Chỉ có giá trị khi khởi tạo từ server (fromServer).
  final int? _pendingLoaiGiayToId;

  SelectorItemModel? loaiGiayTo;
  final TextEditingController soGiayToCtrl;
  DateTime? ngayPhatHanh;

  /// File cũ từ server — hiển thị badge "Đã lưu", có thể xóa.
  final List<_ExistingFileEntry> existingFiles;

  /// File mới người dùng upload trong phiên này.
  /// List này được giữ nguyên khi screen cha rebuild → không mất file.
  final List<UploadedFileModel> newUploadedFiles;

  _TaiLieuEntry({
    this.taiLieuCuTruId = 0,
    int? pendingLoaiGiayToId,
    String soGiayTo = '',
    this.ngayPhatHanh,
    List<_ExistingFileEntry>? existingFiles,
    List<UploadedFileModel>? newUploadedFiles,
  }) : _pendingLoaiGiayToId = pendingLoaiGiayToId,
       loaiGiayTo = null,
       soGiayToCtrl = TextEditingController(text: soGiayTo),
       existingFiles = existingFiles ?? [],
       newUploadedFiles = newUploadedFiles ?? [];

  /// Khởi tạo từ TaiLieuCuTruModel (data server).
  /// loaiGiayTo sẽ được resolve bởi _resolveLoaiGiayTo() sau khi catalog ready.
  factory _TaiLieuEntry.fromServer(TaiLieuCuTruModel doc) => _TaiLieuEntry(
    taiLieuCuTruId: doc.id,
    pendingLoaiGiayToId: doc.loaiGiayToId != 0 ? doc.loaiGiayToId : null,
    soGiayTo: doc.soGiayTo,
    ngayPhatHanh: doc.ngayPhatHanh,
    existingFiles: doc.files.map((f) => _ExistingFileEntry(file: f)).toList(),
  );

  /// fileIds gửi lên server = file cũ còn lại + file mới upload.
  List<int> get activeFileIds => [
    ...existingFiles.where((f) => !f.deleted).map((f) => f.file.id),
    ...newUploadedFiles.map((f) => f.fileId),
  ];

  void dispose() => soGiayToCtrl.dispose();
}
