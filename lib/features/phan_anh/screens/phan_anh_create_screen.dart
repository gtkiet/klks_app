// lib/features/phan_anh/screens/phan_anh_create_screen.dart

import 'package:flutter/material.dart';
import '../../../core/errors/errors.dart';
import '../models/phan_anh_model.dart';
import '../services/phan_anh_service.dart';

/// Màn hình tạo mới hoặc chỉnh sửa phản ánh.
///
/// - Truyền [existing] để vào chế độ chỉnh sửa (chỉ hoạt động khi status là
///   Nháp hoặc Đã thu hồi).
/// - Không truyền → chế độ tạo mới.
class PhanAnhCreateScreen extends StatefulWidget {
  final PhanAnhResponse? existing;

  const PhanAnhCreateScreen({super.key, this.existing});

  @override
  State<PhanAnhCreateScreen> createState() => _PhanAnhCreateScreenState();
}

class _PhanAnhCreateScreenState extends State<PhanAnhCreateScreen> {
  final _service = PhanAnhService();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _tieuDeCtrl;
  late final TextEditingController _noiDungCtrl;
  late final TextEditingController _canHoIdCtrl;
  late final TextEditingController _loaiCtrl;

  bool _isSubmitting = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _tieuDeCtrl = TextEditingController(text: e?.tieuDe ?? '');
    _noiDungCtrl = TextEditingController();
    _canHoIdCtrl =
        TextEditingController(text: e != null ? '${e.canHoId}' : '');
    _loaiCtrl =
        TextEditingController(text: e != null ? '${e.loaiPhanAnhId}' : '1');
  }

  @override
  void dispose() {
    _tieuDeCtrl.dispose();
    _noiDungCtrl.dispose();
    _canHoIdCtrl.dispose();
    _loaiCtrl.dispose();
    super.dispose();
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _submit({required bool asDraft}) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // TODO: refactor validation into a validator class
    final canHoId = int.tryParse(_canHoIdCtrl.text.trim());
    final loaiId = int.tryParse(_loaiCtrl.text.trim());
    if (canHoId == null) {
      _showError('Mã căn hộ phải là số nguyên.');
      return;
    }
    if (loaiId == null) {
      _showError('Mã loại phản ánh phải là số nguyên.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      PhanAnhResponse result;

      if (_isEdit) {
        result = await _service.update(
          id: widget.existing!.id,
          tieuDe: _tieuDeCtrl.text.trim(),
          noiDung: _noiDungCtrl.text.trim(),
          loaiPhanAnhId: loaiId,
          isSubmit: !asDraft,
          isWithdraw: false,
        );
      } else {
        result = await _service.create(
          canHoId: canHoId,
          tieuDe: _tieuDeCtrl.text.trim(),
          noiDung: _noiDungCtrl.text.trim(),
          loaiPhanAnhId: loaiId,
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
      Navigator.pop(context, true); // signal list to refresh
    } on AppException catch (e) {
      _showError(e.message);
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

  // ── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Chỉnh sửa phản ánh' : 'Tạo phản ánh mới'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Căn hộ ID ────────────────────────────────────────────────
            if (!_isEdit) ...[
              _SectionLabel('Mã căn hộ *'),
              TextFormField(
                controller: _canHoIdCtrl,
                keyboardType: TextInputType.number,
                decoration: _inputDeco('Nhập ID căn hộ, VD: 12'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Mã căn hộ không được để trống';
                  }
                  if (int.tryParse(v.trim()) == null) {
                    return 'Mã căn hộ phải là số nguyên';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
            ],

            // ── Loại phản ánh ────────────────────────────────────────────
            _SectionLabel('Mã loại phản ánh *'),
            TextFormField(
              controller: _loaiCtrl,
              keyboardType: TextInputType.number,
              decoration: _inputDeco('VD: 1 = Vệ sinh, 3 = Hạ tầng...'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Loại phản ánh không được để trống';
                }
                if (int.tryParse(v.trim()) == null) {
                  return 'Phải là số nguyên';
                }
                return null;
              },
            ),
            // TODO: replace with DropdownButtonFormField fetched from API
            const SizedBox(height: 16),

            // ── Tiêu đề ──────────────────────────────────────────────────
            _SectionLabel('Tiêu đề *'),
            TextFormField(
              controller: _tieuDeCtrl,
              decoration: _inputDeco('Mô tả ngắn gọn sự cố...'),
              maxLength: 200,
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

            // ── Nội dung ─────────────────────────────────────────────────
            _SectionLabel('Nội dung chi tiết *'),
            TextFormField(
              controller: _noiDungCtrl,
              decoration: _inputDeco(
                  'Mô tả chi tiết vị trí, tình trạng hư hỏng...'),
              minLines: 4,
              maxLines: 10,
              maxLength: 2000,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Nội dung không được để trống';
                }
                return null;
              },
            ),

            // TODO: Add file picker for danhSachTepIds
            const SizedBox(height: 8),
            const Text(
              '* Tệp đính kèm: chưa tích hợp trong bản test này.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),

            const SizedBox(height: 32),

            // ── Buttons ───────────────────────────────────────────────────
            if (_isSubmitting)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _submit(asDraft: false),
                    icon: const Icon(Icons.send),
                    label: Text(_isEdit ? 'Lưu và gửi' : 'Gửi phản ánh'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () => _submit(asDraft: true),
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Lưu nháp'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint) => InputDecoration(
        hintText: hint,
        border: const OutlineInputBorder(),
        isDense: true,
      );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}