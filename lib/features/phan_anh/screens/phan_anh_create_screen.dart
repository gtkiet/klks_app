// lib/features/phan_anh/screens/phan_anh_create_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/phan_anh_model.dart';
import '../services/phan_anh_service.dart';

// ─── Danh sách loại phản ánh (hardcode cho bản test).
const _kLoaiPhanAnh = <(int, String)>[
  (1, 'Vệ sinh & Môi trường'),
  (2, 'An ninh & Bảo vệ'),
  (3, 'Hạ tầng & Kỹ thuật'),
  (4, 'Thái độ phục vụ'),
  (5, 'Tài chính & Phí dịch vụ'),
  (6, 'Khác'),
];

class PhanAnhCreateScreen extends StatefulWidget {
  /// Truyền vào khi muốn chỉnh sửa phản ánh đang ở trạng thái Nháp (8)
  /// hoặc Đã thu hồi (9).
  final PhanAnhDetailResponse? existing;

  const PhanAnhCreateScreen({super.key, this.existing});

  @override
  State<PhanAnhCreateScreen> createState() => _PhanAnhCreateScreenState();
}

class _PhanAnhCreateScreenState extends State<PhanAnhCreateScreen> {
  final _service = PhanAnhService.instance;
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _tieuDeCtrl;
  late final TextEditingController _noiDungCtrl;
  late final TextEditingController _canHoIdCtrl;

  // Dropdown loại phản ánh — mặc định là item đầu tiên
  late int _selectedLoaiId;

  bool _isSubmitting = false;

  bool get _isEdit => widget.existing != null;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    final e = widget.existing;

    _tieuDeCtrl = TextEditingController(text: e?.tieuDe ?? '');
    // Pre-fill noiDung nếu đang ở chế độ edit
    _noiDungCtrl = TextEditingController(text: e?.noiDung ?? '');
    _canHoIdCtrl =
        TextEditingController(text: e != null ? '${e.canHoId}' : '');

    // Tìm loại phù hợp trong danh sách; fallback về item đầu nếu không có
    final existingLoai = e?.loaiPhanAnhId;
    _selectedLoaiId = _kLoaiPhanAnh.any((l) => l.$1 == existingLoai)
        ? existingLoai!
        : _kLoaiPhanAnh.first.$1;
  }

  @override
  void dispose() {
    _tieuDeCtrl.dispose();
    _noiDungCtrl.dispose();
    _canHoIdCtrl.dispose();
    super.dispose();
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _submit({required bool asDraft}) async {
    // Form-level validation (required, minLength, ...)
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // canHoId chỉ cần validate khi tạo mới
    int? canHoId;
    if (!_isEdit) {
      canHoId = int.tryParse(_canHoIdCtrl.text.trim());
      if (canHoId == null || canHoId <= 0) {
        _showError('Mã căn hộ phải là số nguyên dương.');
        return;
      }
    }

    setState(() => _isSubmitting = true);
    try {
      PhanAnhResponse result;

      if (_isEdit) {
        result = await _service.update(
          id: widget.existing!.id,
          tieuDe: _tieuDeCtrl.text.trim(),
          noiDung: _noiDungCtrl.text.trim(),
          loaiPhanAnhId: _selectedLoaiId,
          isSubmit: !asDraft,
          isWithdraw: false,
        );
      } else {
        result = await _service.create(
          canHoId: canHoId!,
          tieuDe: _tieuDeCtrl.text.trim(),
          noiDung: _noiDungCtrl.text.trim(),
          loaiPhanAnhId: _selectedLoaiId,
          isSubmit: !asDraft,
        );
      }

      if (!mounted) return;
      final action = asDraft ? 'Đã lưu nháp' : 'Đã gửi phản ánh';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$action (ID: ${result.id})'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // báo list reload
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(_isEdit ? 'Chỉnh sửa phản ánh' : 'Tạo phản ánh mới'),
      ),
      // Tránh overflow khi bàn phím bật lên
      resizeToAvoidBottomInset: true,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Mã căn hộ (chỉ hiện khi tạo mới) ──────────────────────
            if (!_isEdit) ...[
              _SectionLabel('Mã căn hộ *'),
              TextFormField(
                controller: _canHoIdCtrl,
                keyboardType: TextInputType.number,
                // Chỉ cho nhập số
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: _inputDeco(
                  hint: 'Nhập ID căn hộ, VD: 12',
                  prefixIcon: Icons.home_outlined,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Mã căn hộ không được để trống';
                  }
                  final n = int.tryParse(v.trim());
                  if (n == null || n <= 0) {
                    return 'Mã căn hộ phải là số nguyên dương';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
            ],

            // ── Loại phản ánh (Dropdown) ────────────────────────────────
            _SectionLabel('Loại phản ánh *'),
            DropdownButtonFormField<int>(
              initialValue: _selectedLoaiId,
              decoration: _inputDeco(
                hint: 'Chọn loại phản ánh',
                prefixIcon: Icons.category_outlined,
              ),
              items: _kLoaiPhanAnh
                  .map((l) => DropdownMenuItem(
                        value: l.$1,
                        child: Text(l.$2),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedLoaiId = v);
              },
              validator: (v) =>
                  v == null ? 'Vui lòng chọn loại phản ánh' : null,
            ),
            const SizedBox(height: 16),

            // ── Tiêu đề ─────────────────────────────────────────────────
            _SectionLabel('Tiêu đề *'),
            TextFormField(
              controller: _tieuDeCtrl,
              decoration: _inputDeco(
                hint: 'Mô tả ngắn gọn sự cố...',
                prefixIcon: Icons.title,
              ),
              maxLength: 200,
              textCapitalization: TextCapitalization.sentences,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Tiêu đề không được để trống';
                }
                if (v.trim().length < 5) {
                  return 'Tiêu đề phải có ít nhất 5 ký tự';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ── Nội dung ────────────────────────────────────────────────
            _SectionLabel('Nội dung chi tiết *'),
            TextFormField(
              controller: _noiDungCtrl,
              decoration: _inputDeco(
                hint:
                    'Mô tả chi tiết vị trí, tình trạng hư hỏng...',
                prefixIcon: Icons.notes,
              ),
              minLines: 4,
              maxLines: 10,
              maxLength: 2000,
              textCapitalization: TextCapitalization.sentences,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Nội dung không được để trống';
                }
                if (v.trim().length < 10) {
                  return 'Nội dung phải có ít nhất 10 ký tự';
                }
                return null;
              },
            ),
            const SizedBox(height: 4),

            // ── Tệp đính kèm placeholder ────────────────────────────────
            // TODO: tích hợp image_picker + upload endpoint để lấy fileId
            // rồi đưa vào danhSachTepIds trước khi submit.
            _AttachmentPlaceholder(),

            const SizedBox(height: 32),

            // ── Buttons ─────────────────────────────────────────────────
            if (_isSubmitting)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _submit(asDraft: false),
                    icon: const Icon(Icons.send),
                    label: Text(
                        _isEdit ? 'Lưu và gửi' : 'Gửi phản ánh'),
                    style: ElevatedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () => _submit(asDraft: true),
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Lưu nháp'),
                    style: OutlinedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
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

  InputDecoration _inputDeco({
    required String hint,
    IconData? prefixIcon,
  }) =>
      InputDecoration(
        hintText: hint,
        prefixIcon:
            prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
        border: const OutlineInputBorder(),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 12),
      );
}

// ─── Widgets nội bộ ──────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Placeholder cho tính năng đính kèm file — hiển thị card gợi ý
/// thay vì comment text dễ bị bỏ qua.
class _AttachmentPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: Colors.grey[300]!, style: BorderStyle.solid),
      ),
      child: Row(
        children: [
          Icon(Icons.attach_file, color: Colors.grey[500], size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tệp đính kèm',
                  style: TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 13),
                ),
                Text(
                  'Tính năng upload ảnh/tài liệu chưa tích hợp trong bản test.\n'
                  'TODO: dùng image_picker → upload → lấy fileId.',
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}