// lib/features/tien_ich/thi_cong/screens/thi_cong_form_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../cu_tru/quan_he/models/quan_he_cu_tru_model.dart'
    hide UploadedFileModel;
import '../models/thi_cong_model.dart';
import '../services/thi_cong_service.dart';

class YeuCauThiCongFormScreen extends StatefulWidget {
  final List<QuanHeCuTruModel> dsCanHo;
  final YeuCauThiCongDetailModel? existingDetail;

  const YeuCauThiCongFormScreen({
    super.key,
    required this.dsCanHo,
    this.existingDetail,
  });

  @override
  State<YeuCauThiCongFormScreen> createState() =>
      _YeuCauThiCongFormScreenState();
}

class _YeuCauThiCongFormScreenState extends State<YeuCauThiCongFormScreen> {
  final _service = YeuCauThiCongService.instance;
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  // Controllers
  late final TextEditingController _hangMucCtrl;
  late final TextEditingController _donViCtrl;
  late final TextEditingController _nguoiDaiDienCtrl;
  late final TextEditingController _sdtDaiDienCtrl;
  late final TextEditingController _noiDungCtrl;

  // Form values
  QuanHeCuTruModel? _selectedCanHo;
  DateTime? _duKienBatDau;
  DateTime? _duKienKetThuc;

  // Nhân sự & tệp
  List<NhanSuThiCongModel> _danhSachNhanSu = [];
  final List<UploadedFileModel> _uploadedFiles = [];
  List<int> _existingTepIds = [];

  // Image upload (ảnh hiện trường)
  final List<XFile> _selectedImages = [];
  final List<int> _uploadedImageIds = [];
  bool _isUploading = false;

  // Loading state
  bool _isSubmitting = false;

  bool get _isEditing => widget.existingDetail != null;
  bool get _isReturned => widget.existingDetail?.isReturned ?? false;

  @override
  void initState() {
    super.initState();
    final d = widget.existingDetail;
    _hangMucCtrl = TextEditingController(text: d?.hangMucThiCong ?? '');
    _donViCtrl = TextEditingController(text: d?.tenDonViThiCong ?? '');
    _nguoiDaiDienCtrl = TextEditingController(text: d?.nguoiDaiDien ?? '');
    _sdtDaiDienCtrl = TextEditingController(text: d?.soDienThoaiDaiDien ?? '');
    _noiDungCtrl = TextEditingController(text: d?.noiDung ?? '');

    _initFromEditData();
  }

  void _initFromEditData() {
    final d = widget.existingDetail;

    if (d == null) {
      // Tạo mới: chọn căn hộ đầu tiên mặc định
      if (widget.dsCanHo.isNotEmpty) {
        _selectedCanHo = widget.dsCanHo.first;
      }
      return;
    }

    _duKienBatDau = d.duKienBatDau;
    _duKienKetThuc = d.duKienKetThuc;
    _danhSachNhanSu = List.from(d.nhanSuThiCongs);
    _existingTepIds = d.danhSachTep.map((e) => e.id).toList();

    try {
      _selectedCanHo = widget.dsCanHo.firstWhere((c) => c.canHoId == d.canHoId);
    } catch (_) {
      if (widget.dsCanHo.isNotEmpty) _selectedCanHo = widget.dsCanHo.first;
    }
  }

  @override
  void dispose() {
    _hangMucCtrl.dispose();
    _donViCtrl.dispose();
    _nguoiDaiDienCtrl.dispose();
    _sdtDaiDienCtrl.dispose();
    _noiDungCtrl.dispose();
    super.dispose();
  }

  // ── Image picker & upload ─────────────────────────────────────────────────

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isEmpty) return;
    if (!mounted) return;

    final remaining = 5 - _selectedImages.length;
    if (remaining <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tối đa 5 ảnh')));
      return;
    }

    final toAdd = picked.take(remaining).toList();
    setState(() => _selectedImages.addAll(toAdd));
    await _uploadImages(toAdd);
  }

  Future<void> _uploadImages(List<XFile> images) async {
    setState(() => _isUploading = true);
    try {
      final files = images.map((x) => File(x.path)).toList();
      final uploaded = await _service.uploadFiles(files: files);
      setState(() {
        _uploadedImageIds.addAll(uploaded.map((u) => u.fileId));
      });
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload ảnh lỗi: $e')));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
      if (index < _uploadedImageIds.length) {
        _uploadedImageIds.removeAt(index);
      }
    });
  }

  // ── File upload (hồ sơ) ───────────────────────────────────────────────────

  Future<void> _pickAndUploadFile() async {
    final picked = await _picker.pickMultiImage();
    if (picked.isEmpty) return;

    setState(() => _isUploading = true);
    try {
      final files = picked.map((e) => File(e.path)).toList();
      final uploaded = await _service.uploadFiles(
        files: files,
        targetContainer: 'tai-lieu-nhan-vien',
      );
      setState(
        () => _uploadedFiles.addAll(uploaded as Iterable<UploadedFileModel>),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã upload ${uploaded.length} tệp'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  // ── Date picker ───────────────────────────────────────────────────────────

  Future<void> _pickDate({required bool isBatDau}) async {
    if (_isReturned) return;

    final initial = isBatDau
        ? (_duKienBatDau ?? DateTime.now())
        : (_duKienKetThuc ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked == null) return;

    setState(() {
      if (isBatDau) {
        _duKienBatDau = picked;
      } else {
        _duKienKetThuc = picked;
      }
    });
  }

  // ── Nhân sự ──────────────────────────────────────────────────────────────

  Future<void> _showAddNhanSuDialog() async {
    final result = await showDialog<NhanSuThiCongModel>(
      context: context,
      builder: (_) => const _AddNhanSuDialog(),
    );
    if (result != null) setState(() => _danhSachNhanSu.add(result));
  }

  void _removeNhanSu(int index) {
    setState(() => _danhSachNhanSu.removeAt(index));
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _submit({required bool isSubmit}) async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCanHo == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn căn hộ')));
      return;
    }
    if (_duKienBatDau == null || _duKienKetThuc == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ngày dự kiến bắt đầu và kết thúc'),
        ),
      );
      return;
    }
    if (_isUploading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đang upload, vui lòng chờ...')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final allTepIds = [
        ..._existingTepIds,
        ..._uploadedFiles.map((e) => e.fileId),
        ..._uploadedImageIds,
      ];

      if (_isEditing) {
        await _service.update(
          id: widget.existingDetail!.id,
          hangMucThiCong: _hangMucCtrl.text.trim(),
          duKienBatDau: _duKienBatDau!,
          duKienKetThuc: _duKienKetThuc!,
          noiDung: _noiDungCtrl.text.trim(),
          tenDonViThiCong: _donViCtrl.text.trim(),
          nguoiDaiDien: _nguoiDaiDienCtrl.text.trim(),
          soDienThoaiDaiDien: _sdtDaiDienCtrl.text.trim(),
          danhSachNhanSu: _danhSachNhanSu,
          danhSachTepIds: allTepIds,
          isSubmit: isSubmit,
        );
      } else {
        await _service.create(
          canHoId: _selectedCanHo!.canHoId,
          hangMucThiCong: _hangMucCtrl.text.trim(),
          duKienBatDau: _duKienBatDau!,
          duKienKetThuc: _duKienKetThuc!,
          noiDung: _noiDungCtrl.text.trim(),
          tenDonViThiCong: _donViCtrl.text.trim(),
          nguoiDaiDien: _nguoiDaiDienCtrl.text.trim(),
          soDienThoaiDaiDien: _sdtDaiDienCtrl.text.trim(),
          danhSachNhanSu: _danhSachNhanSu,
          danhSachTepIds: allTepIds,
          isSubmit: isSubmit,
        );
      }

      if (!mounted) return;

      final msg = isSubmit
          ? (_isEditing ? 'Đã gửi lại yêu cầu' : 'Gửi yêu cầu thành công!')
          : 'Đã lưu nháp';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Chỉnh sửa yêu cầu' : 'Tạo yêu cầu thi công'),
      ),
      body: _buildForm(),
    );
  }

  Widget _buildForm() {
    final df = DateFormat('dd/MM/yyyy');

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Banner Returned ──────────────────────────────────────────────
          if (_isReturned)
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                border: Border.all(color: Colors.orange.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.orange.shade700,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Trạng thái Trả lại: chỉ được bổ sung nhân sự, hồ sơ '
                      'và nội dung. Không thể thay đổi hạng mục và ngày thi công.',
                      style: TextStyle(
                        color: Colors.orange.shade900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ── Chọn căn hộ ─────────────────────────────────────────────────
          if (widget.dsCanHo.length == 1)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.apartment, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Căn hộ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            widget.dsCanHo.first.diaChiDayDu,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            DropdownButtonFormField<QuanHeCuTruModel>(
              initialValue: _selectedCanHo,
              decoration: const InputDecoration(
                labelText: 'Căn hộ *',
                border: OutlineInputBorder(),
              ),
              items: widget.dsCanHo
                  .map(
                    (c) =>
                        DropdownMenuItem(value: c, child: Text(c.diaChiDayDu)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedCanHo = v),
              validator: (v) => v == null ? 'Vui lòng chọn căn hộ' : null,
            ),
          const SizedBox(height: 16),

          // ── Hạng mục thi công ────────────────────────────────────────────
          TextFormField(
            controller: _hangMucCtrl,
            enabled: !_isReturned,
            decoration: const InputDecoration(
              labelText: 'Hạng mục thi công *',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Vui lòng nhập hạng mục' : null,
          ),
          const SizedBox(height: 16),

          // ── Ngày dự kiến ─────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _DateField(
                  label: 'Bắt đầu *',
                  value: _duKienBatDau != null
                      ? df.format(_duKienBatDau!)
                      : null,
                  enabled: !_isReturned,
                  onTap: () => _pickDate(isBatDau: true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DateField(
                  label: 'Kết thúc *',
                  value: _duKienKetThuc != null
                      ? df.format(_duKienKetThuc!)
                      : null,
                  enabled: !_isReturned,
                  onTap: () => _pickDate(isBatDau: false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Đơn vị thi công ──────────────────────────────────────────────
          TextFormField(
            controller: _donViCtrl,
            decoration: const InputDecoration(
              labelText: 'Đơn vị thi công *',
              border: OutlineInputBorder(),
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Vui lòng nhập đơn vị' : null,
          ),
          const SizedBox(height: 16),

          // ── Người đại diện ───────────────────────────────────────────────
          TextFormField(
            controller: _nguoiDaiDienCtrl,
            decoration: const InputDecoration(
              labelText: 'Người đại diện *',
              border: OutlineInputBorder(),
            ),
            validator: (v) => v == null || v.trim().isEmpty
                ? 'Vui lòng nhập người đại diện'
                : null,
          ),
          const SizedBox(height: 16),

          // ── SĐT đại diện ─────────────────────────────────────────────────
          TextFormField(
            controller: _sdtDaiDienCtrl,
            decoration: const InputDecoration(
              labelText: 'Số điện thoại đại diện *',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
            validator: (v) => v == null || v.trim().isEmpty
                ? 'Vui lòng nhập số điện thoại'
                : null,
          ),
          const SizedBox(height: 16),

          // ── Nội dung chi tiết ────────────────────────────────────────────
          TextFormField(
            controller: _noiDungCtrl,
            decoration: const InputDecoration(
              labelText: 'Nội dung chi tiết',
              hintText: 'Mô tả chi tiết công việc cần thi công...',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 20),

          // ── Nhân sự thi công ─────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Danh sách nhân sự (${_danhSachNhanSu.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              TextButton.icon(
                onPressed: _showAddNhanSuDialog,
                icon: const Icon(Icons.person_add, size: 18),
                label: const Text('Thêm'),
              ),
            ],
          ),
          ..._danhSachNhanSu.asMap().entries.map(
            (entry) => Card(
              margin: const EdgeInsets.only(bottom: 6),
              child: ListTile(
                dense: true,
                title: Text(entry.value.hoTen),
                subtitle: Text(
                  '${entry.value.vaiTro} • CCCD: ${entry.value.soCCCD}',
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 20,
                  ),
                  onPressed: () => _removeNhanSu(entry.key),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Hồ sơ đính kèm ───────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Hồ sơ đính kèm',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
              TextButton.icon(
                onPressed: _isUploading ? null : _pickAndUploadFile,
                icon: _isUploading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.upload_file, size: 18),
                label: Text(_isUploading ? 'Đang tải...' : 'Tải lên'),
              ),
            ],
          ),
          // Tệp cũ (từ existingDetail)
          if (widget.existingDetail != null)
            ...widget.existingDetail!.danhSachTep.map(
              (tep) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.insert_drive_file,
                  color: Colors.grey,
                ),
                title: Text(
                  tep.fileName.isNotEmpty ? tep.fileName : 'Tệp #${tep.id}',
                  style: const TextStyle(fontSize: 13),
                ),
                subtitle: const Text(
                  '(đã lưu)',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ),
            ),
          // Tệp mới upload
          ..._uploadedFiles.map(
            (f) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: Text(f.fileName, style: const TextStyle(fontSize: 13)),
              subtitle: const Text(
                '(vừa upload)',
                style: TextStyle(fontSize: 11, color: Colors.green),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 18, color: Colors.red),
                onPressed: () => setState(() => _uploadedFiles.remove(f)),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Ảnh hiện trường ──────────────────────────────────────────────
          _buildImageSection(),
          const SizedBox(height: 32),

          // ── Buttons ──────────────────────────────────────────────────────
          if (_isSubmitting)
            const Center(child: CircularProgressIndicator())
          else
            Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _submit(isSubmit: true),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.send),
                  label: Text(
                    _isEditing ? 'Gửi lại yêu cầu' : 'Gửi yêu cầu ngay',
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => _submit(isSubmit: false),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Lưu nháp'),
                ),
              ],
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Ảnh hiện trường (${_selectedImages.length}/5)',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            if (_isUploading) ...[
              const SizedBox(width: 8),
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 4),
              Text(
                'Đang upload...',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Ảnh đã chọn
              ..._selectedImages.asMap().entries.map((entry) {
                final i = entry.key;
                final img = entry.value;
                return Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 100,
                      height: 100,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(File(img.path), fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 10,
                      child: GestureDetector(
                        onTap: () => _removeImage(i),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(2),
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    // Badge upload done
                    if (i < _uploadedImageIds.length)
                      Positioned(
                        bottom: 4,
                        right: 12,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(2),
                          child: const Icon(
                            Icons.check,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                );
              }),

              // Nút thêm ảnh
              if (_selectedImages.length < 5)
                GestureDetector(
                  onTap: _isUploading ? null : _pickImages,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade50,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 32,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Thêm ảnh',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'JPG/PNG, tối đa 5MB/ảnh',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Date field
// ─────────────────────────────────────────────────────────────────────────────

class _DateField extends StatelessWidget {
  final String label;
  final String? value;
  final bool enabled;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.value,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today, size: 18),
        ),
        child: Text(
          value ?? 'Chọn ngày',
          style: TextStyle(
            color: (value == null || !enabled) ? Colors.grey : null,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dialog thêm nhân sự
// ─────────────────────────────────────────────────────────────────────────────

class _AddNhanSuDialog extends StatefulWidget {
  const _AddNhanSuDialog();

  @override
  State<_AddNhanSuDialog> createState() => _AddNhanSuDialogState();
}

class _AddNhanSuDialogState extends State<_AddNhanSuDialog> {
  final _formKey = GlobalKey<FormState>();
  final _hoTenCtrl = TextEditingController();
  final _cccdCtrl = TextEditingController();
  final _sdtCtrl = TextEditingController();
  final _vaiTroCtrl = TextEditingController();
  final _ghiChuCtrl = TextEditingController();

  @override
  void dispose() {
    _hoTenCtrl.dispose();
    _cccdCtrl.dispose();
    _sdtCtrl.dispose();
    _vaiTroCtrl.dispose();
    _ghiChuCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      NhanSuThiCongModel(
        hoTen: _hoTenCtrl.text.trim(),
        soCCCD: _cccdCtrl.text.trim(),
        soDienThoai: _sdtCtrl.text.trim(),
        vaiTro: _vaiTroCtrl.text.trim(),
        ghiChu: _ghiChuCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thêm nhân sự'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _hoTenCtrl,
                decoration: const InputDecoration(
                  labelText: 'Họ tên *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Bắt buộc' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _cccdCtrl,
                decoration: const InputDecoration(
                  labelText: 'Số CCCD *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Bắt buộc' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _sdtCtrl,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _vaiTroCtrl,
                decoration: const InputDecoration(
                  labelText: 'Vai trò (VD: Thợ chính)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _ghiChuCtrl,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Thêm')),
      ],
    );
  }
}
