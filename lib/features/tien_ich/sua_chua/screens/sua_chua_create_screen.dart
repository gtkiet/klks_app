// lib/features/tien_ich/sua_chua/screens/sua_chua_create_screen.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../cu_tru/quan_he/models/quan_he_cu_tru_model.dart';
import '../models/sua_chua_model.dart';
import '../models/sua_chua_request.dart';
import '../services/sua_chua_service.dart';

class YeuCauCreateScreen extends StatefulWidget {
  final List<QuanHeCuTruModel> dsCanHo;
  final YeuCauSuaChua? editData;

  const YeuCauCreateScreen({super.key, required this.dsCanHo, this.editData});

  @override
  State<YeuCauCreateScreen> createState() => _YeuCauCreateScreenState();
}

class _YeuCauCreateScreenState extends State<YeuCauCreateScreen> {
  final _service = YeuCauSuaChuaService.instance;
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  // Controllers
  final _noiDungCtrl = TextEditingController();
  final _moTaViTriCtrl = TextEditingController();

  // Form values
  QuanHeCuTruModel? _selectedCanHo;
  CatalogItem? _selectedPhamVi;
  CatalogItem? _selectedLoaiSuCo;

  // Catalog data (load từ API)
  List<CatalogItem> _dsPhamVi = [];
  List<CatalogItem> _dsLoaiSuCo = [];

  // Upload state
  // List<XFile> _selectedImages = [];
  // List<int> _uploadedFileIds = [];
  final List<XFile> _selectedImages = [];
  final List<int> _uploadedFileIds = [];
  bool _isUploading = false;

  bool _isSubmitting = false;
  bool _isCatalogLoading = true;
  String? _catalogError;

  bool get _isEditMode => widget.editData != null;

  @override
  void initState() {
    super.initState();
    _loadCatalogs();
  }

  Future<void> _loadCatalogs() async {
    try {
      final results = await Future.wait([
        _service.getPhamViSuaChua(),
        _service.getLoaiSuCo(),
      ]);

      setState(() {
        // _dsPhamVi = results[0] as List<CatalogItem>;
        _dsPhamVi = results[0];
        // _dsLoaiSuCo = results[1] as List<CatalogItem>;
        _dsLoaiSuCo = results[1];
        _isCatalogLoading = false;
      });

      _initFromEditData();
    } on Exception catch (e) {
      setState(() {
        _catalogError = e.toString();
        _isCatalogLoading = false;
      });
    }
  }

  void _initFromEditData() {
    final d = widget.editData;
    if (d == null) {
      // Tạo mới: chọn căn hộ đầu tiên mặc định
      if (widget.dsCanHo.isNotEmpty) {
        setState(() => _selectedCanHo = widget.dsCanHo.first);
      }
      return;
    }

    _noiDungCtrl.text = d.noiDung;
    _moTaViTriCtrl.text = d.moTaViTri ?? '';

    // Tìm căn hộ từ dsCanHo
    try {
      _selectedCanHo = widget.dsCanHo.firstWhere((c) => c.canHoId == d.canHoId);
    } catch (_) {
      if (widget.dsCanHo.isNotEmpty) _selectedCanHo = widget.dsCanHo.first;
    }

    // Tìm phamVi & loaiSuCo từ catalog đã load
    if (d.phamViId != null) {
      try {
        _selectedPhamVi = _dsPhamVi.firstWhere((p) => p.id == d.phamViId);
      } catch (_) {}
    }
    if (d.loaiSuCoId != null) {
      try {
        _selectedLoaiSuCo = _dsLoaiSuCo.firstWhere((l) => l.id == d.loaiSuCoId);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _noiDungCtrl.dispose();
    _moTaViTriCtrl.dispose();
    super.dispose();
  }

  // ── Image picker & upload ─────────────────────────────────────────────────

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isEmpty) return;

    if (!mounted) return;

    // Giới hạn tổng 5 ảnh
    final remaining = 5 - _selectedImages.length;
    if (remaining <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tối đa 5 ảnh')));
      return;
    }

    final toAdd = picked.take(remaining).toList();
    setState(() => _selectedImages.addAll(toAdd));

    // Upload ngay sau khi chọn
    await _uploadImages(toAdd);
  }

  Future<void> _uploadImages(List<XFile> images) async {
    setState(() => _isUploading = true);
    try {
      final paths = images.map((x) => x.path).toList();
      final uploaded = await _service.uploadMedia(paths);
      setState(() {
        _uploadedFileIds.addAll(uploaded.map((u) => u.fileId));
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
      // Nếu đã upload, xóa fileId tương ứng (best-effort)
      if (index < _uploadedFileIds.length) {
        _uploadedFileIds.removeAt(index);
      }
    });
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
    if (_selectedPhamVi == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn phạm vi sửa chữa')),
      );
      return;
    }
    if (_selectedLoaiSuCo == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn loại sự cố')));
      return;
    }
    if (_isUploading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đang upload ảnh, vui lòng chờ...')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      if (_isEditMode) {
        await _service.capNhatYeuCau(
          CapNhatYeuCauRequest(
            id: widget.editData!.id,
            phamViId: _selectedPhamVi!.id,
            loaiSuCoId: _selectedLoaiSuCo!.id,
            noiDung: _noiDungCtrl.text.trim(),
            moTaViTri: _moTaViTriCtrl.text.trim().isEmpty
                ? null
                : _moTaViTriCtrl.text.trim(),
            danhSachTepIds: _uploadedFileIds,
            isSubmit: isSubmit,
          ),
        );
      } else {
        await _service.taoYeuCau(
          TaoYeuCauRequest(
            canHoId: _selectedCanHo!.canHoId,
            phamViId: _selectedPhamVi!.id,
            loaiSuCoId: _selectedLoaiSuCo!.id,
            noiDung: _noiDungCtrl.text.trim(),
            moTaViTri: _moTaViTriCtrl.text.trim().isEmpty
                ? null
                : _moTaViTriCtrl.text.trim(),
            danhSachTepIds: _uploadedFileIds,
            isSubmit: isSubmit,
          ),
        );
      }

      if (!mounted) return;

      final msg = isSubmit
          ? (_isEditMode ? 'Đã gửi lại yêu cầu' : 'Gửi yêu cầu thành công!')
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Chỉnh sửa yêu cầu' : 'Tạo yêu cầu mới'),
      ),
      body: _isCatalogLoading
          ? const Center(child: CircularProgressIndicator())
          : _catalogError != null
          ? _ErrorRetry(message: _catalogError!, onRetry: _loadCatalogs)
          : _buildForm(),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Chọn căn hộ (từ CuTruService thực) ───────────────────────────
          if (widget.dsCanHo.length == 1)
            // Chỉ 1 căn hộ → hiển thị readonly
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
            // Nhiều căn hộ → cho chọn
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

          // ── Phạm vi (từ catalog API) ───────────────────────────────────────
          DropdownButtonFormField<CatalogItem>(
            initialValue: _selectedPhamVi,
            decoration: const InputDecoration(
              labelText: 'Phạm vi sửa chữa *',
              border: OutlineInputBorder(),
            ),
            items: _dsPhamVi
                .map((p) => DropdownMenuItem(value: p, child: Text(p.name)))
                .toList(),
            onChanged: (v) => setState(() => _selectedPhamVi = v),
            validator: (v) => v == null ? 'Vui lòng chọn phạm vi' : null,
          ),
          const SizedBox(height: 16),

          // ── Loại sự cố (từ catalog API) ───────────────────────────────────
          DropdownButtonFormField<CatalogItem>(
            initialValue: _selectedLoaiSuCo,
            decoration: const InputDecoration(
              labelText: 'Loại sự cố *',
              border: OutlineInputBorder(),
            ),
            items: _dsLoaiSuCo
                .map((l) => DropdownMenuItem(value: l, child: Text(l.name)))
                .toList(),
            onChanged: (v) => setState(() => _selectedLoaiSuCo = v),
            validator: (v) => v == null ? 'Vui lòng chọn loại sự cố' : null,
          ),
          const SizedBox(height: 16),

          // ── Nội dung ──────────────────────────────────────────────────────
          TextFormField(
            controller: _noiDungCtrl,
            decoration: const InputDecoration(
              labelText: 'Mô tả sự cố *',
              hintText: 'Vd: Bình nóng lạnh không vào điện từ tối qua',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 4,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Vui lòng mô tả sự cố';
              if (v.trim().length < 10) {
                return 'Mô tả quá ngắn (tối thiểu 10 ký tự)';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // ── Mô tả vị trí ──────────────────────────────────────────────────
          TextFormField(
            controller: _moTaViTriCtrl,
            decoration: const InputDecoration(
              labelText: 'Mô tả vị trí (không bắt buộc)',
              hintText: 'Vd: Phòng tắm chung, gần cửa sổ...',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),

          // ── Ảnh đính kèm ──────────────────────────────────────────────────
          _buildImageSection(),
          const SizedBox(height: 32),

          // ── Buttons ───────────────────────────────────────────────────────
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
                    _isEditMode ? 'Gửi lại yêu cầu' : 'Gửi yêu cầu ngay',
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
              'Ảnh hiện trạng (${_selectedImages.length}/5)',
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
                    // Upload done badge
                    if (i < _uploadedFileIds.length)
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

class _ErrorRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorRetry({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
