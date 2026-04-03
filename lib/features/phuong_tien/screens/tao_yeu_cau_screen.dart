// lib/features/phuong_tien/screens/tao_yeu_cau_screen.dart
//
// pubspec.yaml — thêm dependency:
//   file_picker: ^8.0.0

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/phuong_tien_models.dart';
import '../services/phuong_tien_service.dart';

/// LoaiYeuCauId constants
const int kLoaiYeuCauThem = 1;
const int kLoaiYeuCauSua = 2;
const int kLoaiYeuCauXoa = 3;

// ---------------------------------------------------------------------------
// Cấu hình các loại file được phép chọn
// ---------------------------------------------------------------------------

enum _FileFilter {
  all('Tất cả', null, Icons.attach_file),
  image('Hình ảnh', FileType.image, Icons.image_outlined),
  pdf('PDF', FileType.custom, Icons.picture_as_pdf_outlined),
  doc('Word/Excel', FileType.custom, Icons.description_outlined),
  video('Video', FileType.video, Icons.videocam_outlined);

  final String label;
  final FileType? fileType;
  final IconData icon;

  const _FileFilter(this.label, this.fileType, this.icon);

  /// Danh sách extension khi fileType == custom
  List<String>? get allowedExtensions => switch (this) {
    _FileFilter.pdf => ['pdf'],
    _FileFilter.doc => ['doc', 'docx', 'xls', 'xlsx'],
    _ => null,
  };
}

// ---------------------------------------------------------------------------
// Model nội bộ: gom file + upload result lại
// ---------------------------------------------------------------------------

class _PickedFileEntry {
  final File file;
  final String name;
  UploadedFile? uploadResult;
  bool isUploading;
  String? uploadError;

  _PickedFileEntry({
    required this.file,
    required this.name,
    // this.uploadResult,
    // this.isUploading = false,
    // this.uploadError,
  }) : isUploading = false;

  bool get isImage {
    final ext = name.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'heic'].contains(ext);
  }

  bool get isPdf => name.toLowerCase().endsWith('.pdf');

  bool get isVideo {
    final ext = name.split('.').last.toLowerCase();
    return ['mp4', 'mov', 'avi', 'mkv'].contains(ext);
  }

  String get ext => name.split('.').last.toUpperCase();

  bool get isDone => uploadResult != null;
}

class TaoYeuCauScreen extends StatefulWidget {
  /// Truyền vào khi đang sửa/xóa phương tiện cụ thể
  final int? canHoId;
  final int? phuongTienId;

  const TaoYeuCauScreen({super.key, this.canHoId, this.phuongTienId});

  @override
  State<TaoYeuCauScreen> createState() => _TaoYeuCauScreenState();
}

class _TaoYeuCauScreenState extends State<TaoYeuCauScreen> {
  final _service = PhuongTienService();
  final _formKey = GlobalKey<FormState>();

  // Catalog
  List<QuanHeCuTru> _canHos = [];
  List<SelectorItem> _loaiPhuongTiens = [];
  bool _isCatalogLoading = true;

  // Form values
  QuanHeCuTru? _selectedCanHo;
  int _loaiYeuCau = kLoaiYeuCauThem;
  int? _selectedLoaiPhuongTienId;
  final _tenXeCtrl = TextEditingController();
  final _bienSoCtrl = TextEditingController();
  final _mauXeCtrl = TextEditingController();
  final _noiDungCtrl = TextEditingController();

  // Upload — dùng _PickedFileEntry thay vì List<File> riêng lẻ
  final List<_PickedFileEntry> _entries = [];
  _FileFilter _activeFilter = _FileFilter.all;

  // Submit
  bool _isSubmitting = false;

  bool get _anyUploading => _entries.any((e) => e.isUploading);
  List<int> get _successFileIds => _entries
      .where((e) => e.isDone)
      .map((e) => e.uploadResult!.fileId)
      .toList();

  @override
  void initState() {
    super.initState();
    _loadCatalogs();
  }

  @override
  void dispose() {
    _tenXeCtrl.dispose();
    _bienSoCtrl.dispose();
    _mauXeCtrl.dispose();
    _noiDungCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCatalogs() async {
    try {
      final results = await Future.wait([
        _service.getQuanHeCuTru(),
        _service.getLoaiPhuongTien(),
      ]);

      if (mounted) {
        final canHos = results[0] as List<QuanHeCuTru>;
        setState(() {
          _canHos = canHos;
          _loaiPhuongTiens = results[1] as List<SelectorItem>;
          _isCatalogLoading = false;
          if (widget.canHoId != null) {
            _selectedCanHo = canHos
                .where((c) => c.canHoId == widget.canHoId)
                .firstOrNull;
          }
        });
      }
    } on AppException catch (e) {
      if (mounted) {
        setState(() => _isCatalogLoading = false);
        _showSnackBar(e.message, isError: true);
      }
    }
  }

  // -------------------------------------------------------------------------
  // Pick files theo filter hiện tại
  // -------------------------------------------------------------------------

  Future<void> _pickFiles() async {
    final filter = _activeFilter;

    FilePickerResult? result;
    if (filter == _FileFilter.all) {
      result = await FilePicker.platform.pickFiles(allowMultiple: true);
    } else if (filter.fileType == FileType.custom) {
      result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: filter.allowedExtensions,
      );
    } else {
      result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: filter.fileType!,
      );
    }

    if (result == null || result.files.isEmpty) return;

    final newEntries = result.files
        .where((f) => f.path != null)
        .map((f) => _PickedFileEntry(file: File(f.path!), name: f.name))
        .toList();

    setState(() => _entries.addAll(newEntries));

    // Upload từng file một để track progress riêng
    for (final entry in newEntries) {
      await _uploadSingleEntry(entry);
    }
  }

  Future<void> _uploadSingleEntry(_PickedFileEntry entry) async {
    setState(() => entry.isUploading = true);
    try {
      final results = await _service.uploadMedia(
        files: [entry.file],
        targetContainer: 'tai-lieu-phuong-tien',
      );
      if (mounted && results.isNotEmpty) {
        setState(() {
          entry.uploadResult = results.first;
          entry.isUploading = false;
          entry.uploadError = null;
        });
      }
    } on AppException catch (e) {
      if (mounted) {
        setState(() {
          entry.isUploading = false;
          entry.uploadError = e.message;
        });
        _showSnackBar('Lỗi tải "${entry.name}": ${e.message}', isError: true);
      }
    }
  }

  Future<void> _retryEntry(_PickedFileEntry entry) async {
    setState(() {
      entry.uploadError = null;
    });
    await _uploadSingleEntry(entry);
  }

  void _removeEntry(int index) {
    setState(() => _entries.removeAt(index));
  }

  Future<void> _submit({required bool isSubmit}) async {
    if (_selectedCanHo == null) {
      _showSnackBar('Vui lòng chọn căn hộ', isError: true);
      return;
    }
    if (_loaiYeuCau == kLoaiYeuCauThem) {
      if (!_formKey.currentState!.validate()) return;
      if (_selectedLoaiPhuongTienId == null) {
        _showSnackBar('Vui lòng chọn loại phương tiện', isError: true);
        return;
      }
    }
    if (_anyUploading) {
      _showSnackBar('Vui lòng chờ tất cả file tải lên xong', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final request = TaoYeuCauRequest(
        canHoId: _selectedCanHo!.canHoId,
        loaiYeuCauId: _loaiYeuCau,
        isSubmit: isSubmit,
        yeuCauPhuongTienId: widget.phuongTienId,
        yeuCauLoaiPhuongTienId: _loaiYeuCau == kLoaiYeuCauThem
            ? _selectedLoaiPhuongTienId
            : null,
        yeuCauTenPhuongTien: _tenXeCtrl.text.trim().isEmpty
            ? null
            : _tenXeCtrl.text.trim(),
        yeuCauBienSo: _bienSoCtrl.text.trim().isEmpty
            ? null
            : _bienSoCtrl.text.trim(),
        yeuCauMauXe: _mauXeCtrl.text.trim().isEmpty
            ? null
            : _mauXeCtrl.text.trim(),
        noiDung: _noiDungCtrl.text.trim().isEmpty
            ? null
            : _noiDungCtrl.text.trim(),
        fileIds: _successFileIds,
      );

      await _service.taoYeuCau(request);

      if (mounted) {
        _showSnackBar(
          isSubmit
              ? 'Đã gửi yêu cầu thành công. Chờ BQL phê duyệt!'
              : 'Đã lưu nháp yêu cầu.',
        );
        Navigator.pop(context, true);
      }
    } on AppException catch (e) {
      if (mounted) _showSnackBar(e.message, isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tạo yêu cầu phương tiện')),
      body: _isCatalogLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Loại yêu cầu
                  _buildSectionTitle('Loại yêu cầu'),
                  SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 1, label: Text('Thêm xe')),
                      ButtonSegment(value: 2, label: Text('Sửa xe')),
                      ButtonSegment(value: 3, label: Text('Xóa xe')),
                    ],
                    selected: {_loaiYeuCau},
                    onSelectionChanged: (val) =>
                        setState(() => _loaiYeuCau = val.first),
                  ),
                  const SizedBox(height: 16),

                  // Căn hộ
                  _buildSectionTitle('Căn hộ *'),
                  DropdownButtonFormField<QuanHeCuTru>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Chọn căn hộ',
                    ),
                    initialValue: _selectedCanHo,
                    items: _canHos
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text(c.diaChiDayDu),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => _selectedCanHo = val),
                  ),
                  const SizedBox(height: 16),

                  // Fields cho "Thêm xe"
                  if (_loaiYeuCau == kLoaiYeuCauThem) ...[
                    _buildSectionTitle('Thông tin phương tiện'),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Loại phương tiện *',
                      ),
                      initialValue: _selectedLoaiPhuongTienId,
                      items: _loaiPhuongTiens
                          .map(
                            (e) => DropdownMenuItem(
                              value: e.id,
                              child: Text(e.name),
                            ),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedLoaiPhuongTienId = val),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _tenXeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Tên xe *',
                        border: OutlineInputBorder(),
                      ),
                      // TODO: thêm validator chi tiết hơn
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Nhập tên xe' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _bienSoCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Biển số *',
                        border: OutlineInputBorder(),
                        hintText: 'VD: 51A-12345',
                      ),
                      textCapitalization: TextCapitalization.characters,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Nhập biển số' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _mauXeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Màu xe *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Nhập màu xe' : null,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Ghi chú / nội dung
                  _buildSectionTitle('Ghi chú'),
                  TextFormField(
                    controller: _noiDungCtrl,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Nhập ghi chú (tùy chọn)...',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // Upload files
                  _buildSectionTitle(
                    'Tệp đính kèm'
                    '${_entries.isNotEmpty ? ' (${_entries.length})' : ''}',
                  ),
                  _buildFilePicker(),
                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isSubmitting
                              ? null
                              : () => _submit(isSubmit: false),
                          child: const Text('Lưu nháp'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _isSubmitting
                              ? null
                              : () => _submit(isSubmit: true),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Gửi yêu cầu'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Widget _buildFilePicker() {
    final uploadedCount = _entries.where((e) => e.isDone).length;
    final errorCount = _entries.where((e) => e.uploadError != null).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Filter chips ──────────────────────────────────────────────────
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _FileFilter.values.map((f) {
              final isActive = _activeFilter == f;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  avatar: Icon(f.icon, size: 16),
                  label: Text(f.label),
                  selected: isActive,
                  onSelected: (_) => setState(() => _activeFilter = f),
                  showCheckmark: false,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 10),

        // ── Nút chọn file ─────────────────────────────────────────────────
        OutlinedButton.icon(
          onPressed: _anyUploading ? null : _pickFiles,
          icon: _anyUploading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(_activeFilter.icon),
          label: Text(
            _anyUploading
                ? 'Đang tải lên...'
                : 'Chọn ${_activeFilter.label.toLowerCase()}',
          ),
        ),

        // ── Thống kê ──────────────────────────────────────────────────────
        if (_entries.isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              if (uploadedCount > 0)
                _StatusBadge(
                  icon: Icons.check_circle,
                  color: Colors.green,
                  label: '$uploadedCount thành công',
                ),
              if (_anyUploading) ...[
                const SizedBox(width: 8),
                _StatusBadge(
                  icon: Icons.upload,
                  color: Colors.blue,
                  label: 'Đang tải...',
                ),
              ],
              if (errorCount > 0) ...[
                const SizedBox(width: 8),
                _StatusBadge(
                  icon: Icons.error_outline,
                  color: Colors.red,
                  label: '$errorCount lỗi',
                ),
              ],
            ],
          ),
        ],

        // ── Danh sách file đã chọn ────────────────────────────────────────
        if (_entries.isNotEmpty) ...[
          const SizedBox(height: 10),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _entries.length,
            separatorBuilder: (_, _) => const SizedBox(height: 6),
            itemBuilder: (_, index) => _FileEntryTile(
              entry: _entries[index],
              onRemove: () => _removeEntry(index),
              onRetry: () => _retryEntry(_entries[index]),
            ),
          ),
        ],
      ],
    );
  }
}

// =============================================================================
// Helper widgets
// =============================================================================

/// Tile hiển thị một file đã chọn với preview + trạng thái upload
class _FileEntryTile extends StatelessWidget {
  final _PickedFileEntry entry;
  final VoidCallback onRemove;
  final VoidCallback onRetry;

  const _FileEntryTile({
    required this.entry,
    required this.onRemove,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: entry.uploadError != null
              ? Colors.red.shade200
              : entry.isDone
              ? Colors.green.shade200
              : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // ── Preview ─────────────────────────────────────────────────────
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(7),
              bottomLeft: Radius.circular(7),
            ),
            child: SizedBox(
              width: 56,
              height: 56,
              child: entry.isImage
                  ? Image.file(entry.file, fit: BoxFit.cover)
                  : Container(
                      color: _extColor(entry.ext).withValues(alpha: 0.12),
                      child: Center(
                        child: Text(
                          entry.ext,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _extColor(entry.ext),
                          ),
                        ),
                      ),
                    ),
            ),
          ),

          // ── Info ────────────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  _buildStatusRow(),
                ],
              ),
            ),
          ),

          // ── Actions ─────────────────────────────────────────────────────
          if (entry.uploadError != null)
            IconButton(
              icon: const Icon(Icons.refresh, size: 20, color: Colors.orange),
              tooltip: 'Thử lại',
              onPressed: onRetry,
            ),
          IconButton(
            icon: const Icon(Icons.close, size: 20, color: Colors.grey),
            tooltip: 'Xóa',
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow() {
    if (entry.isUploading) {
      return const Row(
        children: [
          SizedBox(
            width: 10,
            height: 10,
            child: CircularProgressIndicator(strokeWidth: 1.5),
          ),
          SizedBox(width: 6),
          Text(
            'Đang tải lên...',
            style: TextStyle(fontSize: 11, color: Colors.blue),
          ),
        ],
      );
    }
    if (entry.uploadError != null) {
      return Text(
        'Lỗi: ${entry.uploadError}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 11, color: Colors.red),
      );
    }
    if (entry.isDone) {
      return const Row(
        children: [
          Icon(Icons.check_circle, size: 12, color: Colors.green),
          SizedBox(width: 4),
          Text(
            'Đã tải lên',
            style: TextStyle(fontSize: 11, color: Colors.green),
          ),
        ],
      );
    }
    return const Text(
      'Chờ tải lên...',
      style: TextStyle(fontSize: 11, color: Colors.grey),
    );
  }

  Color _extColor(String ext) => switch (ext.toLowerCase()) {
    'pdf' => Colors.red,
    'doc' || 'docx' => Colors.blue,
    'xls' || 'xlsx' => Colors.green,
    'mp4' || 'mov' || 'avi' => Colors.purple,
    _ => Colors.blueGrey,
  };
}

/// Badge nhỏ hiển thị trạng thái tổng
class _StatusBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _StatusBadge({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(fontSize: 12, color: color)),
      ],
    );
  }
}
