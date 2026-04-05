// lib/features/cu_tru/screens/sua_yeu_cau_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/quan_he_cu_tru_model.dart';
import '../models/yeu_cau_cu_tru_model.dart';
import '../services/cu_tru_service.dart';
import 'upload_media_screen.dart';
import '../widgets/file_upload_widget.dart';

class SuaYeuCauScreen extends StatefulWidget {
  final YeuCauCuTruModel yeuCau;
  final QuanHeCuTruModel canHo;

  const SuaYeuCauScreen({super.key, required this.yeuCau, required this.canHo});

  @override
  State<SuaYeuCauScreen> createState() => _SuaYeuCauScreenState();
}

class _SuaYeuCauScreenState extends State<SuaYeuCauScreen> {
  final _service = CuTruService();
  final _formKey = GlobalKey<FormState>();
  final _dateFormat = DateFormat('dd/MM/yyyy');

  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _cccdCtrl;
  late final TextEditingController _diaChiCtrl;
  late final TextEditingController _noiDungCtrl;

  List<SelectorItemModel> _gioiTinhList = [];
  List<SelectorItemModel> _loaiQuanHeList = [];
  SelectorItemModel? _selectedGioiTinh;
  SelectorItemModel? _selectedLoaiQuanHe;
  DateTime? _selectedDob;

  // FIX: Map de tranh trung lap va de merge tu 2 nguon
  final Map<int, UploadedFileModel> _newFilesMap = {};
  final Set<int> _inlineFileIds = {};
  List<UploadedFileModel> get _allNewFiles => _newFilesMap.values.toList();

  bool _isLoadingCatalogs = true;
  bool _isSubmitting = false;
  String? _catalogError;

  String get _tenLower => widget.yeuCau.tenLoaiYeuCau.toLowerCase();
  bool get _isXoa =>
      _tenLower.contains('xoa') || _tenLower.contains('x\u00f3a');
  bool get _showPersonalForm => !_isXoa;

  @override
  void initState() {
    super.initState();
    final y = widget.yeuCau;
    _firstNameCtrl = TextEditingController(text: y.yeuCauTen ?? '');
    _lastNameCtrl = TextEditingController(text: y.yeuCauHo ?? '');
    _phoneCtrl = TextEditingController(text: y.yeuCauSoDienThoai ?? '');
    _cccdCtrl = TextEditingController(text: y.yeuCauCCCD ?? '');
    _diaChiCtrl = TextEditingController(text: y.yeuCauDiaChi ?? '');
    _noiDungCtrl = TextEditingController(text: y.noiDung ?? '');
    _selectedDob = y.yeuCauNgaySinh;
    _loadCatalogs();
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _cccdCtrl.dispose();
    _diaChiCtrl.dispose();
    _noiDungCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCatalogs() async {
    setState(() {
      _isLoadingCatalogs = true;
      _catalogError = null;
    });
    try {
      final results = await Future.wait([
        _service.getGioiTinhSelector(),
        _service.getLoaiQuanHeCuTruSelector(),
      ]);
      _gioiTinhList = results[0];
      _loaiQuanHeList = results[1];
      if (widget.yeuCau.yeuCauGioiTinhId != null) {
        try {
          _selectedGioiTinh = _gioiTinhList.firstWhere(
            (g) => g.id == widget.yeuCau.yeuCauGioiTinhId,
          );
        } catch (_) {}
      }
      if (widget.yeuCau.yeuCauLoaiQuanHeId != null) {
        try {
          _selectedLoaiQuanHe = _loaiQuanHeList.firstWhere(
            (q) => q.id == widget.yeuCau.yeuCauLoaiQuanHeId,
          );
        } catch (_) {}
      }
    } catch (e) {
      setState(() => _catalogError = e.toString());
    } finally {
      setState(() => _isLoadingCatalogs = false);
    }
  }

  void _onInlineFilesChanged(List<UploadedFileModel> files) {
    setState(() {
      _newFilesMap.removeWhere((id, _) => _inlineFileIds.contains(id));
      _inlineFileIds.clear();
      for (final f in files) {
        _newFilesMap[f.fileId] = f;
        _inlineFileIds.add(f.fileId);
      }
    });
  }

  void _mergeExternalFiles(List<UploadedFileModel> files) {
    setState(() {
      for (final f in files) {
        _newFilesMap[f.fileId] = f;
      }
    });
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDob = picked);
  }

  // FIX: Chi gui file moi, dung TaiLieuCuTruRequest
  List<TaiLieuCuTruRequest>? _buildNewTaiLieu() {
    final files = _allNewFiles;
    if (files.isEmpty) return null;
    return [TaiLieuCuTruRequest(fileIds: files.map((f) => f.fileId).toList())];
  }

  Future<void> _submit({required bool isSubmit}) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      await _service.updateYeuCau(
        id: widget.yeuCau.id,
        firstName: _showPersonalForm
            ? _firstNameCtrl.text.trim().nullIfEmpty
            : null,
        lastName: _showPersonalForm
            ? _lastNameCtrl.text.trim().nullIfEmpty
            : null,
        phoneNumber: _phoneCtrl.text.trim().nullIfEmpty,
        dob: _selectedDob,
        gioiTinhId: _selectedGioiTinh?.id,
        cccd: _cccdCtrl.text.trim().nullIfEmpty,
        diaChi: _diaChiCtrl.text.trim().nullIfEmpty,
        loaiQuanHeId: _selectedLoaiQuanHe?.id,
        noiDung: _noiDungCtrl.text.trim().nullIfEmpty,
        taiLieuCuTrus: _buildNewTaiLieu(), // FIX
        isSubmit: isSubmit,
        isWithdraw: false,
      );
      if (mounted) {
        _showSnack(isSubmit ? 'Da gui yeu cau!' : 'Da luu thay doi!');
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showSnack(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingCatalogs) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_catalogError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sua yeu cau')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_catalogError!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadCatalogs,
                child: const Text('Thu lai'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sua yeu cau'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '${widget.yeuCau.tenLoaiYeuCau} - ${widget.canHo.diaChiDayDu}',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ),
        ),
      ),
      body: AbsorbPointer(
        absorbing: _isSubmitting,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Banner nhan biet dang sua
              _EditBanner(yeuCau: widget.yeuCau),
              const SizedBox(height: 16),

              if (_isXoa) ...[
                _SectionHeader('Noi dung yeu cau xoa'),
                TextFormField(
                  controller: _noiDungCtrl,
                  decoration: _deco(
                    'Ly do xoa thanh vien...',
                    icon: Icons.notes_outlined,
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
              ],

              if (_showPersonalForm) ...[
                _SectionHeader('Thong tin ca nhan'),
                Row(
                  children: [
                    Expanded(
                      child: _Field(
                        label: 'Ho',
                        controller: _lastNameCtrl,
                        hint: 'Nhap ho',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Field(
                        label: 'Ten',
                        controller: _firstNameCtrl,
                        hint: 'Nhap ten',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _Label('Ngay sinh'),
                InkWell(
                  onTap: _pickDob,
                  borderRadius: BorderRadius.circular(8),
                  child: InputDecorator(
                    decoration: _deco(
                      'Chon ngay sinh',
                      icon: Icons.calendar_today_outlined,
                    ),
                    child: Text(
                      _selectedDob != null
                          ? _dateFormat.format(_selectedDob!)
                          : 'Chon ngay',
                      style: TextStyle(
                        color: _selectedDob != null
                            ? null
                            : Colors.grey.shade500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _Label('Gioi tinh'),
                DropdownButtonFormField<SelectorItemModel>(
                  initialValue: _selectedGioiTinh,
                  items: _gioiTinhList
                      .map(
                        (e) => DropdownMenuItem(value: e, child: Text(e.name)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedGioiTinh = v),
                  decoration: _deco('Chon gioi tinh', icon: Icons.wc_outlined),
                ),
                const SizedBox(height: 12),
                _Label('Loai quan he cu tru'),
                DropdownButtonFormField<SelectorItemModel>(
                  initialValue: _selectedLoaiQuanHe,
                  items: _loaiQuanHeList
                      .map(
                        (e) => DropdownMenuItem(value: e, child: Text(e.name)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedLoaiQuanHe = v),
                  decoration: _deco(
                    'Chu ho, Thanh vien...',
                    icon: Icons.people_outline,
                  ),
                ),
                const SizedBox(height: 16),
                _SectionHeader('Thong tin lien he'),
                _Field(
                  label: 'So dien thoai',
                  controller: _phoneCtrl,
                  hint: 'Nhap so dien thoai',
                  keyboardType: TextInputType.phone,
                  icon: Icons.phone_outlined,
                ),
                const SizedBox(height: 12),
                _Field(
                  label: 'CCCD / CMND',
                  controller: _cccdCtrl,
                  hint: 'Nhap so CCCD',
                  keyboardType: TextInputType.number,
                  icon: Icons.badge_outlined,
                ),
                const SizedBox(height: 12),
                _Field(
                  label: 'Dia chi thuong tru',
                  controller: _diaChiCtrl,
                  hint: 'Nhap dia chi',
                  icon: Icons.home_outlined,
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                _Field(
                  label: 'Noi dung / Ghi chu',
                  controller: _noiDungCtrl,
                  hint: 'Ghi chu them cho BQL...',
                  icon: Icons.notes_outlined,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
              ],

              const Divider(),
              const SizedBox(height: 12),

              // File cu (read-only display)
              if (widget.yeuCau.documents.isNotEmpty) ...[
                const _Label('Tai lieu hien co'),
                const SizedBox(height: 4),
                ...widget.yeuCau.documents
                    .expand((doc) => doc.files)
                    .map(
                      (f) => Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.attach_file,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                f.fileName,
                                style: const TextStyle(fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Text(
                              'Da luu',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                const SizedBox(height: 12),
              ],

              // File moi - dung FIX merge
              FileUploadWidget(
                label: 'Them tai lieu moi',
                targetContainer: 'tai-lieu-cu-tru',
                allowedTypes: FileTypePreset.imageAndDocument,
                maxFiles: 5,
                maxFileSizeMb: 20,
                onFilesChanged: _onInlineFilesChanged, // FIX
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push<List<UploadedFileModel>>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UploadMediaScreen(
                        targetContainer: 'tai-lieu-cu-tru',
                        allowedTypes: FileTypePreset.all,
                        maxFiles: 20,
                        maxFileSizeMb: 50,
                      ),
                    ),
                  );
                  if (result != null && result.isNotEmpty && mounted) {
                    _mergeExternalFiles(result); // FIX
                  }
                },
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('Mo man hinh upload day du'),
              ),

              if (_allNewFiles.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 14,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${_allNewFiles.length} file moi se duoc them vao.',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              if (_isSubmitting)
                const Center(child: CircularProgressIndicator())
              else ...[
                FilledButton.icon(
                  onPressed: () => _submit(isSubmit: true),
                  icon: const Icon(Icons.send_outlined),
                  label: const Text('Luu va gui duyet'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => _submit(isSubmit: false),
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Luu nhap'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _deco(String hint, {IconData? icon}) => InputDecoration(
    hintText: hint,
    prefixIcon: icon != null ? Icon(icon, size: 20) : null,
    border: const OutlineInputBorder(),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  );
}

// ─── Reusable widgets ─────────────────────────────────────────────────────────

class _EditBanner extends StatelessWidget {
  final YeuCauCuTruModel yeuCau;
  const _EditBanner({required this.yeuCau});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.edit_note_outlined, color: Colors.amber),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dang sua yeu cau #${yeuCau.id}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  '${yeuCau.tenLoaiYeuCau} - ${yeuCau.tenTrangThai}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Divider(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    ),
  );
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData? icon;
  final TextInputType? keyboardType;
  final int maxLines;
  // final String? Function(String?)? validator;

  const _Field({
    required this.label,
    required this.controller,
    required this.hint,
    this.icon,
    this.keyboardType,
    this.maxLines = 1,
    // this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          // validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon, size: 20) : null,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}

extension _StringExt on String {
  String? get nullIfEmpty => trim().isEmpty ? null : trim();
}
