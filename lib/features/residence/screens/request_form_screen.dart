// lib/features/residence/screens/residence_form_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../models/member.dart';
import '../models/residence_apartment.dart';
import '../models/residence_document.dart';
// import '../models/residence_models.dart';
import '../models/residence_request.dart';
import '../models/selector_item.dart';
import '../models/upload_file_response.dart';
import '../services/residence_service.dart';
import '../../../core/errors/app_exception.dart';

// LoaiYeuCauId: 1=Thêm, 2=Sửa, 3=Xóa
//
// Modes:
//   editDraftId == null  →  CREATE mode  (POST /api/quan-he-cu-tru/yeu-cau)
//   editDraftId != null  →  EDIT DRAFT mode  (PUT /api/quan-he-cu-tru/yeu-cau)
class RequestFormScreen extends StatefulWidget {
  final ResidenceApartment apartment;
  final SelectorItem loaiYeuCau;

  // ── Create mode ──
  final Member? targetMember;
  final MemberDetail? prefillDetail;

  // ── Edit draft mode ──
  final int? editDraftId;
  final ResidenceRequestDetail? draftDetail;

  const RequestFormScreen({
    super.key,
    required this.apartment,
    required this.loaiYeuCau,
    // create
    this.targetMember,
    this.prefillDetail,
    // edit draft
    this.editDraftId,
    this.draftDetail,
  });

  bool get isEditDraft => editDraftId != null;

  @override
  State<RequestFormScreen> createState() => _RequestFormScreenState();
}

class _RequestFormScreenState extends State<RequestFormScreen> {
  final _service = ResidenceService.instance;
  final _formKey = GlobalKey<FormState>();

  // ── Text controllers ────────────────────────────────────────────────────────
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _cccdCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _diaChiCtrl;
  late final TextEditingController _noiDungCtrl;

  // ── Selectors ───────────────────────────────────────────────────────────────
  List<SelectorItem> _gioiTinhList = [];
  List<SelectorItem> _loaiQuanHeList = [];
  SelectorItem? _selectedGioiTinh;
  SelectorItem? _selectedLoaiQuanHe;
  DateTime? _dob;

  // ── Files ───────────────────────────────────────────────────────────────────
  // Existing files already saved in the draft (display-only, locked)
  List<DocumentFile> _existingFiles = [];
  // New files uploaded this session
  final List<File> _newPickedFiles = [];
  final List<UploadFileResponse> _newUploadedFiles = [];
  bool _uploading = false;

  bool _submitting = false;
  bool _loadingCatalogs = true;

  bool get _isAdd => widget.loaiYeuCau.id == 1;
  bool get _isEdit => widget.loaiYeuCau.id == 2;
  bool get _isDelete => widget.loaiYeuCau.id == 3;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _loadCatalogs();
  }

  void _initControllers() {
    if (widget.isEditDraft && widget.draftDetail != null) {
      // Edit draft: prefill from ResidenceRequestDetail
      final d = widget.draftDetail!;
      _firstNameCtrl = TextEditingController(text: d.yeuCauTen ?? '');
      _lastNameCtrl = TextEditingController(text: d.yeuCauHo ?? '');
      _cccdCtrl = TextEditingController(text: d.yeuCauCCCD ?? '');
      _phoneCtrl = TextEditingController(text: d.yeuCauSoDienThoai ?? '');
      _diaChiCtrl = TextEditingController(text: d.yeuCauDiaChi ?? '');
      _noiDungCtrl = TextEditingController(text: d.noiDung ?? '');
      _dob = d.yeuCauNgaySinh;
      _existingFiles = d.documents.expand((doc) => doc.files).toList();
    } else {
      // Create mode: prefill from MemberDetail (Sửa/Xóa) or blank (Thêm)
      final d = widget.prefillDetail;
      _firstNameCtrl = TextEditingController(text: d?.firstName ?? '');
      _lastNameCtrl = TextEditingController(text: d?.lastName ?? '');
      _cccdCtrl = TextEditingController(text: d?.idCard ?? '');
      _phoneCtrl = TextEditingController(text: d?.phoneNumber ?? '');
      _diaChiCtrl = TextEditingController(text: d?.diaChi ?? '');
      _noiDungCtrl = TextEditingController();
      _dob = d?.dob;
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _cccdCtrl.dispose();
    _phoneCtrl.dispose();
    _diaChiCtrl.dispose();
    _noiDungCtrl.dispose();
    super.dispose();
  }

  // ── Catalogs ────────────────────────────────────────────────────────────────

  Future<void> _loadCatalogs() async {
    try {
      final results = await Future.wait([
        _service.getGioiTinh(),
        _service.getLoaiQuanHe(),
      ]);
      setState(() {
        _gioiTinhList = results[0];
        _loaiQuanHeList = results[1];

        if (widget.isEditDraft && widget.draftDetail != null) {
          final d = widget.draftDetail!;
          _selectedGioiTinh = _gioiTinhList
              .where((e) => e.id == d.yeuCauGioiTinhId)
              .firstOrNull;
          _selectedLoaiQuanHe = _loaiQuanHeList
              .where((e) => e.id == d.yeuCauLoaiQuanHeId)
              .firstOrNull;
        } else if (widget.prefillDetail != null) {
          final d = widget.prefillDetail!;
          _selectedGioiTinh = _gioiTinhList
              .where((e) => e.id == d.gioiTinhId)
              .firstOrNull;
          _selectedLoaiQuanHe = _loaiQuanHeList
              .where((e) => e.id == d.loaiQuanHeCuTruId)
              .firstOrNull;
        }
      });
    } on AppException catch (e) {
      _showSnack(e.message);
    } finally {
      setState(() => _loadingCatalogs = false);
    }
  }

  // ── Upload ──────────────────────────────────────────────────────────────────

  Future<void> _pickAndUploadFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any, // hoặc FileType.custom nếu muốn giới hạn
      // allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
    );

    if (result == null || result.files.isEmpty) return;

    final pickedFile = result.files.first;

    if (pickedFile.path == null) {
      _showSnack('Không thể đọc file');
      return;
    }

    final file = File(pickedFile.path!);

    setState(() {
      _uploading = true;
      _newPickedFiles.add(file);
    });

    try {
      final uploaded = await _service.uploadFile(file: file);

      setState(() {
        _newUploadedFiles.add(uploaded);
      });

      _showSnack('Upload thành công: ${uploaded.fileName}');
    } on AppException catch (e) {
      _showSnack(e.message);
      setState(() => _newPickedFiles.removeLast());
    } finally {
      setState(() => _uploading = false);
    }
  }

  // Future<void> _pickAndUploadFile() async {
  //   final picker = ImagePicker();
  //   final picked = await picker.pickImage(source: ImageSource.gallery);
  //   if (picked == null) return;

  //   final file = File(picked.path);
  //   setState(() {
  //     _uploading = true;
  //     _newPickedFiles.add(file);
  //   });

  //   try {
  //     final uploaded = await _service.uploadFile(file: file);
  //     setState(() => _newUploadedFiles.add(uploaded));
  //     _showSnack('Upload thành công: ${uploaded.fileName}');
  //   } on AppException catch (e) {
  //     _showSnack(e.message);
  //     setState(() => _newPickedFiles.removeLast());
  //   } finally {
  //     setState(() => _uploading = false);
  //   }
  // }

  void _removeNewFile(int index) {
    setState(() {
      _newPickedFiles.removeAt(index);
      _newUploadedFiles.removeAt(index);
    });
  }

  // ── Submit ──────────────────────────────────────────────────────────────────

  Future<void> _submit({required bool isSubmit}) async {
    if (!_isDelete && !(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _submitting = true);
    try {
      final newFileIds = _newUploadedFiles
          .map((f) => int.tryParse(f.fileId) ?? 0)
          .where((id) => id != 0)
          .toList();

      final taiLieuCuTrus = newFileIds.isNotEmpty
          ? [
              {
                'taiLieuCuTruId': 0,
                'loaiGiayToId': 1,
                'soGiayTo': _cccdCtrl.text.trim(),
                'ngayPhatHanh': DateTime.now().toIso8601String(),
                'fileIds': newFileIds,
              },
            ]
          : null;

      if (widget.isEditDraft) {
        // PUT: update existing draft
        await _service.updateRequest(
          id: widget.editDraftId!,
          firstName: (_isAdd || _isEdit) ? _firstNameCtrl.text.trim() : null,
          lastName: (_isAdd || _isEdit) ? _lastNameCtrl.text.trim() : null,
          gioiTinhId: (_isAdd || _isEdit) ? _selectedGioiTinh?.id : null,
          dob: (_isAdd || _isEdit) ? _dob : null,
          cccd: (_isAdd || _isEdit) ? _cccdCtrl.text.trim() : null,
          phoneNumber: (_isAdd || _isEdit) ? _phoneCtrl.text.trim() : null,
          diaChi: (_isAdd || _isEdit) ? _diaChiCtrl.text.trim() : null,
          loaiQuanHeId: _isAdd ? _selectedLoaiQuanHe?.id : null,
          noiDung: _noiDungCtrl.text.trim().isNotEmpty
              ? _noiDungCtrl.text.trim()
              : null,
          taiLieuCuTrus: taiLieuCuTrus,
          isSubmit: isSubmit,
          isWithdraw: false,
        );
      } else {
        // POST: create new request
        await _service.createRequest(
          canHoId: widget.apartment.canHoId,
          loaiYeuCauId: widget.loaiYeuCau.id,
          targetQuanHeCuTruId: widget.targetMember?.quanHeCuTruId,
          noiDung: _noiDungCtrl.text.trim().isNotEmpty
              ? _noiDungCtrl.text.trim()
              : null,
          firstName: (_isAdd || _isEdit) ? _firstNameCtrl.text.trim() : null,
          lastName: (_isAdd || _isEdit) ? _lastNameCtrl.text.trim() : null,
          gioiTinhId: (_isAdd || _isEdit) ? _selectedGioiTinh?.id : null,
          dob: (_isAdd || _isEdit) ? _dob : null,
          cccd: (_isAdd || _isEdit) ? _cccdCtrl.text.trim() : null,
          phoneNumber: (_isAdd || _isEdit) ? _phoneCtrl.text.trim() : null,
          diaChi: (_isAdd || _isEdit) ? _diaChiCtrl.text.trim() : null,
          loaiQuanHeId: _isAdd ? _selectedLoaiQuanHe?.id : null,
          taiLieuCuTrus: taiLieuCuTrus,
          isSubmit: isSubmit,
        );
      }

      if (mounted) {
        _showSnack(
          isSubmit ? 'Đã gửi yêu cầu thành công!' : 'Đã lưu nháp thành công!',
        );
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) Navigator.pop(context, true);
      }
    } on AppException catch (e) {
      _showSnack(e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  // ── UI ──────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final title = widget.isEditDraft
        ? 'Chỉnh sửa yêu cầu #${widget.editDraftId}'
        : '${widget.loaiYeuCau.name} thành viên';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        // subtitle: Text(widget.apartment.tenCanHo),
      ),
      body: _loadingCatalogs
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Target member chip (create Sửa/Xóa)
                  if (!widget.isEditDraft && widget.targetMember != null) ...[
                    _SectionHeader('Thành viên được chọn'),
                    _TargetMemberCard(member: widget.targetMember!),
                    const SizedBox(height: 20),
                  ],

                  if (!_isDelete) ...[
                    _SectionHeader('Thông tin cá nhân'),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _lastNameCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Họ *',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Nhập họ'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _firstNameCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Tên *',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Nhập tên'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    InkWell(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Ngày sinh *',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _dob != null
                              ? '${_dob!.day}/${_dob!.month}/${_dob!.year}'
                              : 'Chọn ngày sinh',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<SelectorItem>(
                      value: _selectedGioiTinh,
                      decoration: const InputDecoration(
                        labelText: 'Giới tính *',
                        border: OutlineInputBorder(),
                      ),
                      items: _gioiTinhList
                          .map(
                            (e) =>
                                DropdownMenuItem(value: e, child: Text(e.name)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedGioiTinh = v),
                      validator: (v) => v == null ? 'Chọn giới tính' : null,
                    ),
                    const SizedBox(height: 12),

                    if (_isAdd) ...[
                      DropdownButtonFormField<SelectorItem>(
                        value: _selectedLoaiQuanHe,
                        decoration: const InputDecoration(
                          labelText: 'Quan hệ cư trú *',
                          border: OutlineInputBorder(),
                        ),
                        items: _loaiQuanHeList
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.name),
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedLoaiQuanHe = v),
                        validator: (v) =>
                            v == null ? 'Chọn quan hệ cư trú' : null,
                      ),
                      const SizedBox(height: 12),
                    ],

                    TextFormField(
                      controller: _cccdCtrl,
                      decoration: const InputDecoration(
                        labelText: 'CCCD',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Số điện thoại',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _diaChiCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Địa chỉ thường trú',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── File upload section ─────────────────────────────────────
                    _SectionHeader('Tài liệu đính kèm'),
                    const SizedBox(height: 8),

                    // Existing files from draft (locked, cannot remove)
                    if (_existingFiles.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Text(
                          'Đã đính kèm trước đó:',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                      ..._existingFiles.map(
                        (f) => ListTile(
                          dense: true,
                          leading: const Icon(
                            Icons.insert_drive_file,
                            color: Colors.blueGrey,
                          ),
                          title: Text(
                            f.fileName,
                            style: const TextStyle(fontSize: 13),
                          ),
                          trailing: const Tooltip(
                            message: 'Không thể xóa tệp đã lưu',
                            child: Icon(
                              Icons.lock_outline,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    // New files added this session (removable)
                    if (_newUploadedFiles.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Text(
                          'Tệp mới:',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                      ...List.generate(_newUploadedFiles.length, (i) {
                        return ListTile(
                          dense: true,
                          leading: const Icon(
                            Icons.insert_drive_file,
                            color: Colors.blue,
                          ),
                          title: Text(
                            _newUploadedFiles[i].fileName,
                            style: const TextStyle(fontSize: 13),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.close,
                              size: 18,
                              color: Colors.red,
                            ),
                            tooltip: 'Bỏ tệp này',
                            onPressed: () => _removeNewFile(i),
                          ),
                        );
                      }),
                      const SizedBox(height: 4),
                    ],

                    OutlinedButton.icon(
                      onPressed: _uploading ? null : _pickAndUploadFile,
                      icon: _uploading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.upload_file),
                      label: Text(
                        _uploading ? 'Đang upload...' : 'Thêm tài liệu',
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Ghi chú / Lý do ────────────────────────────────────────────
                  _SectionHeader(_isDelete ? 'Lý do xóa *' : 'Ghi chú'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _noiDungCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: _isDelete
                          ? 'Nhập lý do xóa thành viên'
                          : 'Ghi chú (không bắt buộc)',
                      border: const OutlineInputBorder(),
                    ),
                    validator: _isDelete
                        ? (v) => (v == null || v.trim().isEmpty)
                              ? 'Nhập lý do xóa'
                              : null
                        : null,
                  ),
                  const SizedBox(height: 32),

                  // ── Buttons ─────────────────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _submitting
                              ? null
                              : () => _submit(isSubmit: false),
                          child: const Text('Lưu nháp'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _submitting
                              ? null
                              : () => _submit(isSubmit: true),
                          child: _submitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Lưu & Gửi'),
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
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: Theme.of(context).textTheme.titleSmall?.copyWith(
      color: Theme.of(context).colorScheme.primary,
    ),
  );
}

class _TargetMemberCard extends StatelessWidget {
  final Member member;
  const _TargetMemberCard({required this.member});

  @override
  Widget build(BuildContext context) => Card(
    color: Theme.of(context).colorScheme.secondaryContainer,
    child: ListTile(
      leading: CircleAvatar(
        backgroundImage: member.anhDaiDienUrl != null
            ? NetworkImage(member.anhDaiDienUrl!)
            : null,
        child: member.anhDaiDienUrl == null
            ? Text(member.fullName.isNotEmpty ? member.fullName[0] : '?')
            : null,
      ),
      title: Text(member.fullName),
      subtitle: Text(member.loaiQuanHeTen),
    ),
  );
}
