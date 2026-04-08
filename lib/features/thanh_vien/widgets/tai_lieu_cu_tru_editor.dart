// lib/features/thanh_vien/widgets/tai_lieu_cu_tru_editor.dart
//
// Widget cho phép user thêm/xóa nhiều tài liệu cư trú.
// Mỗi tài liệu gồm:
//   - loaiGiayToId  (optional — chọn từ catalog)
//   - soGiayTo      (bắt buộc theo server validation — gửi '' nếu bỏ trống)
//   - ngayPhatHanh  (optional)
//   - files         (nhiều file, upload ngay lên server → nhận fileId)
//
// Output: List<TaiLieuCuTruRequest> — truyền thẳng vào TaoYeuCauCuTruRequest

import 'package:flutter/material.dart';

import '../models/tai_lieu_cu_tru_request.dart';
import '../../utils/models/selector_item_model.dart';
import '../../utils/models/uploaded_file_model.dart';
import '../../utils/services/utils_service.dart';
import '../../utils/widgets/app_file_upload_field.dart';
import '../../utils/widgets/app_selector_field.dart';
import '../../cu_tru/widgets/shared_widget.dart';

class TaiLieuCuTruEditor extends StatefulWidget {
  /// Callback mỗi khi danh sách tài liệu thay đổi.
  final void Function(List<TaiLieuCuTruRequest> taiLieus) onChanged;

  const TaiLieuCuTruEditor({super.key, required this.onChanged});

  @override
  State<TaiLieuCuTruEditor> createState() => _TaiLieuCuTruEditorState();
}

class _TaiLieuCuTruEditorState extends State<TaiLieuCuTruEditor> {
  final _utilsService = UtilsService.instance;

  // Cache future — chỉ gọi API 1 lần
  late final Future<List<SelectorItemModel>> _loaiGiayToFuture = _utilsService
      .getLoaiGiayToSelector();

  // Danh sách tài liệu đang edit
  final List<_TaiLieuEntry> _entries = [];

  // ── Thêm tài liệu mới ─────────────────────────────────────────────────
  void _addEntry() {
    setState(() => _entries.add(_TaiLieuEntry()));
    _notify();
  }

  // ── Xóa tài liệu ─────────────────────────────────────────────────────
  void _removeEntry(int index) {
    setState(() => _entries.removeAt(index));
    _notify();
  }

  // ── Notify parent ──────────────────────────────────────────────────────
  void _notify() {
    // Build List<TaiLieuCuTruRequest> từ entries hiện tại
    // Chỉ include entry có ít nhất 1 file
    final result = _entries
        .where((e) => e.files.isNotEmpty)
        .map(
          (e) => TaiLieuCuTruRequest(
            loaiGiayToId: e.loaiGiayTo?.id,
            soGiayTo: e.soGiayToCtrl.text.trim(),
            ngayPhatHanh: e.ngayPhatHanh,
            fileIds: e.files.map((f) => f.fileId).toList(),
          ),
        )
        .toList();
    widget.onChanged(result);
  }

  @override
  void dispose() {
    for (final e in _entries) {
      e.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Danh sách tài liệu
        ..._entries.asMap().entries.map(
          (entry) => _TaiLieuCard(
            index: entry.key,
            entryData: entry.value,
            loaiGiayToFuture: _loaiGiayToFuture,
            uploadFn: _utilsService.uploadMedia,
            onChanged: _notify,
            onRemove: () => _removeEntry(entry.key),
          ),
        ),

        // Nút thêm tài liệu
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
    // Lắng nghe soGiayTo thay đổi → notify parent
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
            // Header: số thứ tự + nút xóa
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

            // Loại giấy tờ (optional)
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

            // Số giấy tờ — bắt buộc theo server (gửi '' nếu bỏ trống)
            Field(
              controller: entry.soGiayToCtrl,
              label: 'Số giấy tờ',
              hint: 'VD: 012345678901',
            ),
            const SizedBox(height: 10),

            // Ngày phát hành (optional)
            DatePickerField(
              label: 'Ngày phát hành',
              value: entry.ngayPhatHanh,
              onTap: _pickNgayPhatHanh,
            ),
            const SizedBox(height: 10),

            // File đính kèm — nhiều file cho 1 tài liệu
            AppFileUploadField(
              label: 'File đính kèm',
              targetContainer: 'tai-lieu-cu-tru',
              uploadFn: widget.uploadFn,
              initialFiles: entry.files,
              allowMultiple: true,
              onChanged: (files) {
                // Xóa file = xóa khỏi list, KHÔNG gọi API xóa server
                setState(() {
                  entry.files
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

// =============================================================================
// DATA MODEL NỘI BỘ
// =============================================================================

class _TaiLieuEntry {
  SelectorItemModel? loaiGiayTo;
  final TextEditingController soGiayToCtrl = TextEditingController();
  DateTime? ngayPhatHanh;
  final List<UploadedFileModel> files = [];

  void dispose() => soGiayToCtrl.dispose();
}
