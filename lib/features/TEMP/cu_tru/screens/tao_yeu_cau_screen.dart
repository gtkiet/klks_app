// lib/features/cu_tru/screens/tao_yeu_cau_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/quan_he_cu_tru_model.dart';
import '../models/thanh_vien_cu_tru_model.dart';
import '../models/thong_tin_cu_dan_model.dart';
import '../models/yeu_cau_cu_tru_model.dart';
import '../services/cu_tru_service.dart';
import 'upload_media_screen.dart';
import '../widgets/file_upload_widget.dart';

class TaoYeuCauScreen extends StatefulWidget {
  final QuanHeCuTruModel canHo;
  final SelectorItemModel loaiYeuCau;
  final ThanhVienCuTruModel? targetThanhVien;
  final bool prefillForm;

  const TaoYeuCauScreen({
    super.key,
    required this.canHo,
    required this.loaiYeuCau,
    this.targetThanhVien,
    this.prefillForm = false,
  });

  @override
  State<TaoYeuCauScreen> createState() => _TaoYeuCauScreenState();
}

class _TaoYeuCauScreenState extends State<TaoYeuCauScreen> {
  final _service = CuTruService();
  final _formKey = GlobalKey<FormState>();
  final _dateFormat = DateFormat('dd/MM/yyyy');

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cccdCtrl = TextEditingController();
  final _diaChiCtrl = TextEditingController();
  final _noiDungCtrl = TextEditingController();

  List<SelectorItemModel> _gioiTinhList = [];
  List<SelectorItemModel> _loaiQuanHeList = [];
  SelectorItemModel? _selectedGioiTinh;
  SelectorItemModel? _selectedLoaiQuanHe;
  DateTime? _selectedDob;

  // FIX: Dung mot Set duy nhat, khong bi overwrite khi callback tu widget
  // Key = fileId de tranh trung lap
  final Map<int, UploadedFileModel> _uploadedFilesMap = {};
  List<UploadedFileModel> get _allUploadedFiles =>
      _uploadedFilesMap.values.toList();

  // Track file tu widget inline (de khong reset khi setState)
  final Set<int> _inlineFileIds = {};

  bool _isLoadingPrefill = false;
  bool _isSubmitting = false;
  String? _loadError;

  String get _tenLower => widget.loaiYeuCau.name.toLowerCase();
  bool get _isThemMoi =>
      !_tenLower.contains('sua') &&
      !_tenLower.contains('xoa') &&
      !_tenLower.contains('s\u1eeda') &&
      !_tenLower.contains('x\u00f3a');
  bool get _isXoa =>
      _tenLower.contains('xoa') || _tenLower.contains('x\u00f3a');
  bool get _showPersonalForm => _isThemMoi || widget.prefillForm;

  @override
  void initState() {
    super.initState();
    _loadCatalogsAndPrefill();
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

  Future<void> _loadCatalogsAndPrefill() async {
    setState(() {
      _isLoadingPrefill = true;
      _loadError = null;
    });
    try {
      final futures = await Future.wait([
        _service.getGioiTinhSelector(),
        _service.getLoaiQuanHeCuTruSelector(),
      ]);
      _gioiTinhList = futures[0];
      _loaiQuanHeList = futures[1];

      if (widget.prefillForm && widget.targetThanhVien != null) {
        final detail = await _service.getThongTinCuDan(
          widget.targetThanhVien!.quanHeCuTruId,
        );
        _prefillFrom(detail);
      }
    } catch (e) {
      setState(() => _loadError = e.toString());
    } finally {
      setState(() => _isLoadingPrefill = false);
    }
  }

  void _prefillFrom(ThongTinCuDanModel d) {
    _firstNameCtrl.text = d.firstName;
    _lastNameCtrl.text = d.lastName;
    _phoneCtrl.text = d.phoneNumber ?? '';
    _cccdCtrl.text = d.idCard ?? '';
    _diaChiCtrl.text = d.diaChi ?? '';
    _selectedDob = d.dob;
    try {
      _selectedGioiTinh = _gioiTinhList.firstWhere((g) => g.id == d.gioiTinhId);
    } catch (_) {}
    try {
      _selectedLoaiQuanHe = _loaiQuanHeList.firstWhere(
        (q) => q.id == d.loaiQuanHeCuTruId,
      );
    } catch (_) {}
  }

  // FIX: Merge file tu inline widget vao map, khong overwrite file tu source khac
  void _onInlineFilesChanged(List<UploadedFileModel> files) {
    setState(() {
      // Xoa cac file truoc do cua inline widget (co the da xoa)
      _uploadedFilesMap.removeWhere((id, _) => _inlineFileIds.contains(id));
      _inlineFileIds.clear();
      // Them file moi
      for (final f in files) {
        _uploadedFilesMap[f.fileId] = f;
        _inlineFileIds.add(f.fileId);
      }
    });
  }

  // FIX: Merge file tu man hinh upload rieng, khong overwrite file tu inline widget
  void _mergeExternalFiles(List<UploadedFileModel> files) {
    setState(() {
      for (final f in files) {
        _uploadedFilesMap[f.fileId] = f;
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

  // FIX: Build TaiLieuCuTruRequest dung cach, chi gui cac field co gia tri
  List<TaiLieuCuTruRequest>? _buildTaiLieuCuTrus() {
    final files = _allUploadedFiles;
    if (files.isEmpty) return null;
    return [
      TaiLieuCuTruRequest(
        fileIds: files.map((f) => f.fileId).toList(),
        // Khong gui loaiGiayToId/soGiayTo/ngayPhatHanh neu khong co
      ),
    ];
  }

  Future<void> _submit({required bool isSubmit}) async {
    if (!_formKey.currentState!.validate()) return;

    if (_showPersonalForm) {
      if (_firstNameCtrl.text.trim().isEmpty ||
          _lastNameCtrl.text.trim().isEmpty) {
        _showSnack('Vui long nhap ho va ten');
        return;
      }
      if (_isThemMoi) {
        if (_selectedDob == null) {
          _showSnack('Vui long chon ngay sinh');
          return;
        }
        if (_selectedGioiTinh == null) {
          _showSnack('Vui long chon gioi tinh');
          return;
        }
        if (_selectedLoaiQuanHe == null) {
          _showSnack('Vui long chon loai quan he cu tru');
          return;
        }
      }
    }

    setState(() => _isSubmitting = true);
    try {
      await _service.createYeuCau(
        canHoId: widget.canHo.canHoId,
        loaiYeuCauId: widget.loaiYeuCau.id,
        targetQuanHeCuTruId: widget.targetThanhVien?.quanHeCuTruId,
        firstName: _showPersonalForm
            ? _firstNameCtrl.text.trim().nullIfEmpty
            : null,
        lastName: _showPersonalForm
            ? _lastNameCtrl.text.trim().nullIfEmpty
            : null,
        gioiTinhId: _selectedGioiTinh?.id,
        dob: _selectedDob,
        cccd: _cccdCtrl.text.trim().nullIfEmpty,
        phoneNumber: _phoneCtrl.text.trim().nullIfEmpty,
        diaChi: _diaChiCtrl.text.trim().nullIfEmpty,
        loaiQuanHeId: _selectedLoaiQuanHe?.id,
        noiDung: _noiDungCtrl.text.trim().nullIfEmpty,
        taiLieuCuTrus: _buildTaiLieuCuTrus(), // FIX
        isSubmit: isSubmit,
      );
      if (mounted) {
        _showSnack(isSubmit ? 'Da gui yeu cau!' : 'Da luu nhap!');
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
    if (_isLoadingPrefill) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_loadError != null) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                _loadError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadCatalogsAndPrefill,
                child: const Text('Thu lai'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: AbsorbPointer(
        absorbing: _isSubmitting,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _InfoBanner(canHo: widget.canHo, loaiYeuCau: widget.loaiYeuCau),
              const SizedBox(height: 16),

              if (widget.targetThanhVien != null) ...[
                _TargetMemberCard(member: widget.targetThanhVien!),
                const SizedBox(height: 16),
              ],

              if (_isXoa) ...[
                _SectionHeader('Noi dung yeu cau xoa'),
                TextFormField(
                  controller: _noiDungCtrl,
                  decoration: _deco(
                    'Ly do xoa thanh vien nay...',
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
                        label: 'Ho *',
                        controller: _lastNameCtrl,
                        hint: 'Nhap ho',
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Bat buoc' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Field(
                        label: 'Ten *',
                        controller: _firstNameCtrl,
                        hint: 'Nhap ten',
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Bat buoc' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _Label('Ngay sinh${_isThemMoi ? ' *' : ''}'),
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
                _Label('Gioi tinh${_isThemMoi ? ' *' : ''}'),
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
                _Label('Loai quan he cu tru${_isThemMoi ? ' *' : ''}'),
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
                if (!_isXoa)
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

              // FIX: FileUploadWidget - dung callback merge, khong overwrite
              FileUploadWidget(
                label: 'Tai lieu dinh kem',
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
                    _mergeExternalFiles(result); // FIX: merge, khong overwrite
                  }
                },
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('Mo man hinh upload day du'),
              ),

              // FIX: Hien tong so file thuc su se gui
              if (_allUploadedFiles.isNotEmpty)
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
                        '${_allUploadedFiles.length} file se duoc gui kem.',
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
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    '"Luu nhap" van co the chinh sua sau.\n"Luu va gui" se khong tu chinh sua duoc nua.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Colors.grey),
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

  AppBar _buildAppBar() => AppBar(
    title: Text(widget.loaiYeuCau.name, style: const TextStyle(fontSize: 16)),
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(28),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          widget.canHo.diaChiDayDu,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ),
    ),
  );

  InputDecoration _deco(String hint, {IconData? icon}) => InputDecoration(
    hintText: hint,
    prefixIcon: icon != null ? Icon(icon, size: 20) : null,
    border: const OutlineInputBorder(),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  );
}

// ─── Widgets ─────────────────────────────────────────────────────────────────

class _InfoBanner extends StatelessWidget {
  final QuanHeCuTruModel canHo;
  final SelectorItemModel loaiYeuCau;
  const _InfoBanner({required this.canHo, required this.loaiYeuCau});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.apartment_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  canHo.tenCanHo,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  canHo.diaChiDayDu,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              loaiYeuCau.name,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TargetMemberCard extends StatelessWidget {
  final ThanhVienCuTruModel member;
  const _TargetMemberCard({required this.member});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage: member.anhDaiDienUrl != null
                ? NetworkImage(member.anhDaiDienUrl!)
                : null,
            child: member.anhDaiDienUrl == null
                ? Text(
                    member.fullName.isNotEmpty
                        ? member.fullName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.fullName,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  member.loaiQuanHeTen,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.orange),
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
  final String? Function(String?)? validator;

  const _Field({
    required this.label,
    required this.controller,
    required this.hint,
    this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
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
          validator: validator,
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
