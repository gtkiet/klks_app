// lib/features/cu_tru/phuong_tien/screens/tao_yeu_cau_phuong_tien_screen.dart
//
// Screen dùng chung cho 3 loại yêu cầu phương tiện:
//   loaiYeuCauId = 1 (Thêm) : form nhập xe mới
//   loaiYeuCauId = 2 (Sửa)  : pre-fill từ phuongTien, user chỉnh sửa
//   loaiYeuCauId = 3 (Xóa)  : hiển thị thông tin xe readonly + lý do + confirm
//
// Báo mất thẻ: bottom sheet chọn thẻ từ phuongTien.thePhuongTiens,
//              gọi PhuongTienService.baoMatThe(theIds).
//
// Luồng vào:
//   - Từ danh sách  : truyền canHoInfo + loaiYeuCauId + phuongTien (snapshot)
//   - Từ chi tiết   : truyền canHoInfo + loaiYeuCauId + phuongTien (đầy đủ)
//   - Thêm mới      : chỉ cần canHoInfo + loaiYeuCauId = 1

import 'package:flutter/material.dart';

import '../../quan_he/widgets/shared_widget.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../models/phuong_tien_model.dart';
import '../services/phuong_tien_service.dart';

import 'package:klks_app/design/design.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Loại yêu cầu
// ─────────────────────────────────────────────────────────────────────────────

enum _LoaiYeuCau {
  them(1, 'Đăng ký xe mới'),
  sua(2, 'Sửa thông tin xe'),
  xoa(3, 'Huỷ đăng ký xe');

  const _LoaiYeuCau(this.id, this.label);
  final int id;
  final String label;

  static _LoaiYeuCau fromId(int id) =>
      _LoaiYeuCau.values.firstWhere((e) => e.id == id, orElse: () => them);
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class TaoYeuCauPhuongTienScreen extends StatefulWidget {
  final QuanHeCuTruModel canHoInfo;
  final int loaiYeuCauId;

  /// Bắt buộc với loaiYeuCauId = 2 (Sửa) và 3 (Xóa).
  /// Optional với loaiYeuCauId = 1 (Thêm).
  final PhuongTien? phuongTien;

  const TaoYeuCauPhuongTienScreen({
    super.key,
    required this.canHoInfo,
    this.loaiYeuCauId = 1,
    this.phuongTien,
  }) : assert(
         loaiYeuCauId == 1 || phuongTien != null,
         'phuongTien bắt buộc khi loaiYeuCauId = 2 hoặc 3',
       );

  @override
  State<TaoYeuCauPhuongTienScreen> createState() =>
      _TaoYeuCauPhuongTienScreenState();
}

class _TaoYeuCauPhuongTienScreenState
    extends State<TaoYeuCauPhuongTienScreen> {
  final _ptService = PhuongTienService.instance;
  final _formKey = GlobalKey<FormState>();

  late final _LoaiYeuCau _loai;

  // ── Text controllers ───────────────────────────────────────────────────
  late final TextEditingController _tenXeCtrl;
  late final TextEditingController _bienSoCtrl;
  late final TextEditingController _mauXeCtrl;
  late final TextEditingController _noiDungCtrl;

  // ── Selector state ─────────────────────────────────────────────────────
  SelectorItem? _loaiPhuongTien;

  // ── Upload state ───────────────────────────────────────────────────────
  final List<UploadedFile> _uploadedFiles = [];

  // ── Submit state ───────────────────────────────────────────────────────
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loai = _LoaiYeuCau.fromId(widget.loaiYeuCauId);

    final pt = widget.phuongTien;

    // Pre-fill từ snapshot khi Sửa hoặc Xóa.
    _tenXeCtrl = TextEditingController(text: pt?.tenPhuongTien ?? '');
    _bienSoCtrl = TextEditingController(text: pt?.bienSo ?? '');
    _mauXeCtrl = TextEditingController(text: pt?.mauXe ?? '');
    _noiDungCtrl = TextEditingController();

    // Pre-select loại phương tiện khi Sửa.
    if (pt != null && pt.loaiPhuongTienId != 0) {
      _loaiPhuongTien = SelectorItem(
        id: pt.loaiPhuongTienId,
        name: pt.tenLoaiPhuongTien,
      );
    }
  }

  @override
  void dispose() {
    _tenXeCtrl.dispose();
    _bienSoCtrl.dispose();
    _mauXeCtrl.dispose();
    _noiDungCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  bool get _isXoa => _loai == _LoaiYeuCau.xoa;
  bool get _isThem => _loai == _LoaiYeuCau.them;

  // ── Submit ─────────────────────────────────────────────────────────────

  Future<void> _submit(bool isSubmit) async {
    if (!_formKey.currentState!.validate()) return;

    // Xóa không cần validate loại phương tiện.
    if (!_isXoa && _loaiPhuongTien == null) {
      _showSnack('Vui lòng chọn loại phương tiện');
      return;
    }

    // Xóa cần confirm thêm.
    if (_isXoa) {
      final ok = await AppConfirmDialog.show(
        context,
        title: 'Xác nhận huỷ đăng ký',
        message:
            'Bạn có chắc muốn gửi yêu cầu huỷ đăng ký xe '
            '"${widget.phuongTien!.bienSo}" không?',
        confirmLabel: 'Gửi yêu cầu',
        isDangerous: true,
      );
      if (ok != true || !mounted) return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _ptService.taoYeuCau(
        TaoYeuCauPhuongTienRequest(
          canHoId: widget.canHoInfo.canHoId,
          loaiYeuCauId: widget.loaiYeuCauId,
          isSubmit: isSubmit,
          yeuCauPhuongTienId: widget.phuongTien?.id,
          yeuCauLoaiPhuongTienId: _loaiPhuongTien?.id,
          yeuCauTenPhuongTien: _tenXeCtrl.text.trim().nullIfEmpty,
          yeuCauBienSo: _bienSoCtrl.text.trim().nullIfEmpty,
          yeuCauMauXe: _mauXeCtrl.text.trim().nullIfEmpty,
          noiDung: _noiDungCtrl.text.trim().nullIfEmpty,
          fileIds: _uploadedFiles.isNotEmpty
              ? _uploadedFiles.map((f) => f.fileId).toList()
              : null,
        ),
      );

      if (!mounted) return;
      _showSnack(isSubmit ? 'Đã nộp yêu cầu thành công' : 'Đã lưu nháp');
      Navigator.pop(context, true);
    } on Exception catch (e) {
      if (!mounted) return;
      _showSnack(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  // ── Báo mất thẻ ────────────────────────────────────────────────────────

  Future<void> _baoMatThe() async {
    final pt = widget.phuongTien;
    if (pt == null || pt.thePhuongTiens.isEmpty) {
      _showSnack('Xe này chưa có thẻ nào');
      return;
    }

    final selectedIds = await showModalBottomSheet<List<int>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.modal),
      builder: (_) => _BaoMatTheSheet(theList: pt.thePhuongTiens),
    );

    if (selectedIds == null || selectedIds.isEmpty || !mounted) return;

    final ok = await AppConfirmDialog.show(
      context,
      title: 'Xác nhận báo mất thẻ',
      message: 'Báo mất ${selectedIds.length} thẻ đã chọn? '
          'Thẻ sẽ bị khoá và không thể hoàn tác.',
      confirmLabel: 'Báo mất',
      isDangerous: true,
    );
    if (ok != true || !mounted) return;

    setState(() => _isSubmitting = true);
    try {
      await _ptService.baoMatThe(selectedIds);
      if (!mounted) return;
      _showSnack('Đã báo mất ${selectedIds.length} thẻ thành công');
      Navigator.pop(context, true);
    } on Exception catch (e) {
      if (!mounted) return;
      _showSnack(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppTopBar(
        title: _loai.label,
        actions: [
          // Báo mất thẻ — chỉ show khi có phương tiện (Sửa/Xóa context).
          if (widget.phuongTien != null)
            IconButton(
              tooltip: 'Báo mất thẻ',
              icon: const Icon(Icons.credit_card_off_outlined),
              onPressed: _isSubmitting ? null : _baoMatThe,
            ),
        ],
      ),
      body: _isSubmitting
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: AppSpacing.insetAll16,
                children: [
                  // ── Căn hộ (readonly) ────────────────────────────
                  ReadonlyCanHoCard(canHoInfo: widget.canHoInfo),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Info xe hiện tại (Sửa/Xóa) ──────────────────
                  if (!_isThem && widget.phuongTien != null) ...[
                    _CurrentVehicleCard(pt: widget.phuongTien!),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  // ── Form thông tin (Thêm / Sửa) ──────────────────
                  if (!_isXoa) ...[
                    Text(
                      _isThem
                          ? 'Thông tin phương tiện mới'
                          : 'Thông tin cập nhật',
                      style: AppTypography.subhead,
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    SelectorField.future(
                      label: 'Loại phương tiện *',
                      future: _ptService.getLoaiPhuongTienSelector(),
                      selectedItems:
                          _loaiPhuongTien != null ? [_loaiPhuongTien!] : [],
                      isRequired: true,
                      onChangedSingle: (v) =>
                          setState(() => _loaiPhuongTien = v as SelectorItem),
                    ),
                    const SizedBox(height: AppSpacing.sm2),

                    Field(
                      controller: _tenXeCtrl,
                      label: 'Tên xe *',
                      hint: 'VD: Honda Wave Alpha, Toyota Vios...',
                      validator: _required,
                    ),
                    const SizedBox(height: AppSpacing.sm2),

                    Field(
                      controller: _bienSoCtrl,
                      label: 'Biển số *',
                      hint: 'VD: 51A-123.45',
                      textCapitalization: TextCapitalization.characters,
                      validator: _required,
                    ),
                    const SizedBox(height: AppSpacing.sm2),

                    Field(
                      controller: _mauXeCtrl,
                      label: 'Màu xe',
                      hint: 'VD: Đỏ, Trắng, Đen...',
                    ),
                    const SizedBox(height: AppSpacing.sm2),

                    Field(
                      controller: _noiDungCtrl,
                      label: 'Ghi chú',
                      maxLines: 3,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    Text('Hình ảnh phương tiện', style: AppTypography.subhead),
                    const SizedBox(height: AppSpacing.sm),

                    AppFileUploadField(
                      label: 'Ảnh xe (tùy chọn)',
                      targetContainer: 'tai-lieu-phuong-tien',
                      uploadFn: _ptService.uploadMedia,
                      initialFiles: _uploadedFiles,
                      allowMultiple: true,
                      onChanged: (files) => setState(() {
                        _uploadedFiles
                          ..clear()
                          ..addAll(files);
                      }),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  // ── Lý do (Xóa) ──────────────────────────────────
                  if (_isXoa) ...[
                    Field(
                      controller: _noiDungCtrl,
                      label: 'Lý do huỷ đăng ký',
                      hint: 'Nhập lý do (tùy chọn)',
                      maxLines: 3,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  // ── Buttons ──────────────────────────────────────
                  if (_isXoa)
                    AppButton(
                      label: 'Gửi yêu cầu huỷ đăng ký',
                      variant: AppButtonVariant.danger,
                      onPressed: () => _submit(true),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: 'Lưu nháp',
                            variant: AppButtonVariant.outline,
                            onPressed: () => _submit(false),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm2),
                        Expanded(
                          child: AppButton(
                            label: 'Nộp yêu cầu',
                            onPressed: () => _submit(true),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
    );
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Trường này là bắt buộc' : null;
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget: thông tin xe hiện tại (Sửa / Xóa)
// ─────────────────────────────────────────────────────────────────────────────

class _CurrentVehicleCard extends StatelessWidget {
  final PhuongTien pt;
  const _CurrentVehicleCard({required this.pt});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: AppRadius.buttonSmall,
                ),
                child: Icon(_loaiIcon(pt.loaiPhuongTienId),
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pt.bienSo, style: AppTypography.subhead),
                    Text(
                      '${pt.tenLoaiPhuongTien} • ${pt.tenPhuongTien}',
                      style: AppTypography.caption.secondary,
                    ),
                  ],
                ),
              ),
              AppStatusBadge(
                label: pt.tenTrangThaiPhuongTien,
                variant: _trangThaiVariant(pt.trangThaiPhuongTienId),
              ),
            ],
          ),
          const Divider(height: AppSpacing.lg),
          _Row('Màu xe', pt.mauXe),
          _Row('Vị trí', pt.viTriNgan),
          if (pt.thePhuongTiens.isNotEmpty)
            _Row('Số thẻ', '${pt.thePhuongTiens.length} thẻ'),
        ],
      ),
    );
  }

  AppBadgeVariant _trangThaiVariant(int id) => switch (id) {
    1 => AppBadgeVariant.success,
    2 => AppBadgeVariant.info,
    _ => AppBadgeVariant.warning,
  };

  IconData _loaiIcon(int id) => switch (id) {
    1 => Icons.two_wheeler,
    2 => Icons.directions_car,
    3 => Icons.pedal_bike,
    _ => Icons.commute,
  };
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(label, style: AppTypography.caption.secondary),
          ),
          Expanded(child: Text(value, style: AppTypography.bodyMedium)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom sheet: chọn thẻ báo mất
// ─────────────────────────────────────────────────────────────────────────────

class _BaoMatTheSheet extends StatefulWidget {
  final List<ThePhuongTien> theList;
  const _BaoMatTheSheet({required this.theList});

  @override
  State<_BaoMatTheSheet> createState() => _BaoMatTheSheetState();
}

class _BaoMatTheSheetState extends State<_BaoMatTheSheet> {
  final Set<int> _selected = {};

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          top: AppSpacing.md,
          bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: AppRadius.badge,
                ),
              ),
            ),

            Text('Chọn thẻ báo mất', style: AppTypography.headline),
            const SizedBox(height: 4),
            Text(
              'Chọn các thẻ cần báo mất. Thao tác này không thể hoàn tác.',
              style: AppTypography.caption.secondary,
            ),
            const SizedBox(height: AppSpacing.md),

            // Danh sách thẻ
            ...widget.theList.map((the) {
              final isActive = the.trangThaiThePhuongTienId == 1;
              final isSelected = _selected.contains(the.id);

              return AppCard(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                onTap: isActive
                    ? () => setState(() {
                          if (isSelected) {
                            _selected.remove(the.id);
                          } else {
                            _selected.add(the.id);
                          }
                        })
                    : null,
                color: isSelected ? AppColors.errorLight : null,
                child: Row(
                  children: [
                    // Checkbox
                    Checkbox(
                      value: isSelected,
                      onChanged: isActive
                          ? (v) => setState(() {
                                v == true
                                    ? _selected.add(the.id)
                                    : _selected.remove(the.id);
                              })
                          : null,
                      activeColor: AppColors.error,
                    ),
                    const SizedBox(width: AppSpacing.xs),

                    // Thông tin thẻ
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.credit_card_outlined,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(the.maThe, style: AppTypography.subhead),
                            ],
                          ),
                          if (the.ngayBatDau != null ||
                              the.ngayKetThuc != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              [
                                if (the.ngayBatDau != null)
                                  'Từ: ${_fmtDate(the.ngayBatDau!)}',
                                if (the.ngayKetThuc != null)
                                  'Đến: ${_fmtDate(the.ngayKetThuc!)}',
                              ].join('  •  '),
                              style: AppTypography.captionSmall.secondary,
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Trạng thái
                    AppStatusBadge(
                      label: the.tenTrangThaiThePhuongTien,
                      variant: isActive
                          ? AppBadgeVariant.success
                          : AppBadgeVariant.info,
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: AppSpacing.md),

            // Nút xác nhận
            AppButton(
              label: _selected.isEmpty
                  ? 'Chọn ít nhất 1 thẻ'
                  : 'Báo mất ${_selected.length} thẻ',
              variant: AppButtonVariant.danger,
              onPressed: _selected.isEmpty
                  ? null
                  : () => Navigator.pop(context, _selected.toList()),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Extension helper
// ─────────────────────────────────────────────────────────────────────────────

extension _StringNullIfEmpty on String {
  String? get nullIfEmpty => trim().isEmpty ? null : trim();
}