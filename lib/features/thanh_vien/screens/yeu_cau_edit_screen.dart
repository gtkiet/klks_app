// // lib/features/thanh_vien/screens/yeu_cau_edit_screen.dart

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:image_picker/image_picker.dart';

// import '../../../core/errors/errors.dart';
// import '../services/tv_yeu_cau_service.dart';
// import '../../utils/models/selector_item_model.dart';
// import '../../utils/models/uploaded_file_model.dart';
// import '../../utils/services/utils_service.dart';
// import '../models/yeu_cau_cu_tru_model.dart';
// import '../models/thanh_vien_request.dart';
// import '../models/tai_lieu_cu_tru_request.dart';
// import '../models/thong_tin_cu_dan_model.dart';

// // ── Model nội bộ ──────────────────────────────────────────────────────────────

// class _ExistingFile {
//   final TaiLieuFileModel file;
//   bool deleted;
//   _ExistingFile({required this.file, this.deleted = false});
// }

// class _TaiLieuEntry {
//   final int taiLieuCuTruId; // 0 = nhóm mới
//   final List<_ExistingFile> existingFiles;
//   final List<UploadedFileModel> newFiles;

//   _TaiLieuEntry({
//     this.taiLieuCuTruId = 0,
//     List<_ExistingFile>? existingFiles,
//     List<UploadedFileModel>? newFiles,
//   }) : existingFiles = existingFiles ?? [],
//        newFiles = newFiles ?? [];

//   List<int> get activeFileIds => [
//     ...existingFiles.where((f) => !f.deleted).map((f) => f.file.id),
//     ...newFiles.map((f) => f.fileId),
//   ];
// }

// // ─────────────────────────────────────────────────────────────────────────────

// class YeuCauEditScreen extends StatefulWidget {
//   /// Chỉ cần truyền id — screen tự gọi getYeuCauById để load.
//   final int yeuCauId;

//   const YeuCauEditScreen({super.key, required this.yeuCauId});

//   @override
//   State<YeuCauEditScreen> createState() => _YeuCauEditScreenState();
// }

// class _YeuCauEditScreenState extends State<YeuCauEditScreen> {
//   final _service = YeuCauCuTruService.instance;
//   final _utilsSvc = UtilsService.instance;
//   final _formKey = GlobalKey<FormState>();

//   // ── Load state ────────────────────────────────────────────────────────
//   bool _isLoading = true;
//   AppException? _loadError;

//   // ── Form controllers (khởi tạo sau khi load xong) ─────────────────────
//   TextEditingController? _firstNameCtrl;
//   TextEditingController? _lastNameCtrl;
//   TextEditingController? _cccdCtrl;
//   TextEditingController? _phoneCtrl;
//   TextEditingController? _diaChiCtrl;
//   TextEditingController? _noiDungCtrl;

//   DateTime? _dob;
//   SelectorItemModel? _selectedGioiTinh;
//   SelectorItemModel? _selectedLoaiQuanHe;

//   List<SelectorItemModel> _gioiTinhList = [];
//   List<SelectorItemModel> _loaiQuanHeList = [];

//   final List<_TaiLieuEntry> _taiLieuEntries = [];

//   // ── Save/submit state ─────────────────────────────────────────────────
//   bool _isUploading = false;
//   bool _isSaving = false;
//   bool _isSubmitting = false;

//   // ─────────────────────────────────────────────────────────────────────
//   @override
//   void initState() {
//     super.initState();
//     _loadAll();
//   }

//   @override
//   void dispose() {
//     _firstNameCtrl?.dispose();
//     _lastNameCtrl?.dispose();
//     _cccdCtrl?.dispose();
//     _phoneCtrl?.dispose();
//     _diaChiCtrl?.dispose();
//     _noiDungCtrl?.dispose();
//     super.dispose();
//   }

//   // ── Load dữ liệu + catalog song song ─────────────────────────────────

//   Future<void> _loadAll() async {
//     setState(() {
//       _isLoading = true;
//       _loadError = null;
//       _taiLieuEntries.clear();
//     });

//     try {
//       // Gọi song song: chi tiết yêu cầu + 2 catalog
//       final results = await Future.wait([
//         _service.getYeuCauById(widget.yeuCauId),
//         _utilsSvc.getGioiTinhSelector(),
//         _utilsSvc.getLoaiQuanHeCuTruSelector(),
//       ]);

//       final d = results[0] as YeuCauCuTruModel;
//       final gioiTinh = results[1] as List<SelectorItemModel>;
//       final loaiQuanHe = results[2] as List<SelectorItemModel>;

//       // ── Khởi tạo controllers từ data server ──
//       _firstNameCtrl = TextEditingController(text: d.yeuCauTen ?? '');
//       _lastNameCtrl = TextEditingController(text: d.yeuCauHo ?? '');
//       _cccdCtrl = TextEditingController(text: d.yeuCauCCCD ?? '');
//       _phoneCtrl = TextEditingController(text: d.yeuCauSoDienThoai ?? '');
//       _diaChiCtrl = TextEditingController(text: d.yeuCauDiaChi ?? '');
//       _noiDungCtrl = TextEditingController(text: d.noiDung ?? '');
//       _dob = d.yeuCauNgaySinh;

//       // ── Catalog + pre-select ──
//       _gioiTinhList = gioiTinh;
//       _loaiQuanHeList = loaiQuanHe;
//       _selectedGioiTinh = gioiTinh
//           .where((e) => e.id == d.yeuCauGioiTinhId)
//           .firstOrNull;
//       _selectedLoaiQuanHe = loaiQuanHe
//           .where((e) => e.id == d.yeuCauLoaiQuanHeId)
//           .firstOrNull;

//       // ── Pre-fill tài liệu ──
//       for (final doc in d.documents) {
//         _taiLieuEntries.add(
//           _TaiLieuEntry(
//             taiLieuCuTruId: doc.id,
//             existingFiles: doc.files
//                 .map((f) => _ExistingFile(file: f))
//                 .toList(),
//           ),
//         );
//       }

//       setState(() => _isLoading = false);
//     } on AppException catch (e) {
//       setState(() {
//         _loadError = e;
//         _isLoading = false;
//       });
//     }
//   }

//   // ── Upload ────────────────────────────────────────────────────────────

//   Future<void> _pickAndUpload({_TaiLieuEntry? entry}) async {
//     final picker = ImagePicker();
//     final picked = await picker.pickMultiImage();
//     if (picked.isEmpty || !mounted) return;

//     setState(() => _isUploading = true);
//     try {
//       final uploaded = await _utilsSvc.uploadMedia(
//         files: picked.map((x) => File(x.path)).toList(),
//         targetContainer: 'tai-lieu-cu-tru',
//       );
//       setState(() {
//         if (entry != null) {
//           entry.newFiles.addAll(uploaded);
//         } else {
//           _taiLieuEntries.add(_TaiLieuEntry(newFiles: uploaded));
//         }
//       });
//     } on AppException catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Upload thất bại: ${e.message}')),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isUploading = false);
//     }
//   }

//   void _removeExistingFile(_ExistingFile ef) =>
//       setState(() => ef.deleted = true);

//   void _removeNewFile(_TaiLieuEntry entry, UploadedFileModel f) =>
//       setState(() => entry.newFiles.remove(f));

//   // ── Build request ─────────────────────────────────────────────────────

//   CapNhatYeuCauCuTruRequest _buildRequest({required bool isSubmit}) {
//     final taiLieu = _taiLieuEntries
//         .where((e) => e.activeFileIds.isNotEmpty)
//         .map(
//           (e) => TaiLieuCuTruRequest(
//             taiLieuCuTruId: e.taiLieuCuTruId,
//             fileIds: e.activeFileIds,
//           ),
//         )
//         .toList();

//     return CapNhatYeuCauCuTruRequest(
//       id: widget.yeuCauId,
//       isSubmit: isSubmit,
//       firstName: _firstNameCtrl!.text.trim(),
//       lastName: _lastNameCtrl!.text.trim(),
//       cccd: _cccdCtrl!.text.trim(),
//       phoneNumber: _phoneCtrl!.text.trim(),
//       diaChi: _diaChiCtrl!.text.trim(),
//       dob: _dob,
//       gioiTinhId: _selectedGioiTinh?.id,
//       loaiQuanHeId: _selectedLoaiQuanHe?.id,
//       noiDung: _noiDungCtrl!.text.trim(),
//       taiLieuCuTrus: taiLieu.isEmpty ? null : taiLieu,
//     );
//   }

//   // ── Lưu nháp ─────────────────────────────────────────────────────────

//   Future<void> _saveDraft() async {
//     if (_isSaving || _isSubmitting) return;
//     setState(() => _isSaving = true);
//     try {
//       await _service.updateYeuCau(_buildRequest(isSubmit: false));
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text('Đã lưu nháp')));
//       }
//     } on AppException catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text(e.message)));
//       }
//     } finally {
//       if (mounted) setState(() => _isSaving = false);
//     }
//   }

//   // ── Submit ────────────────────────────────────────────────────────────

//   Future<void> _submit() async {
//     if (!(_formKey.currentState?.validate() ?? false)) return;
//     if (_isSaving || _isSubmitting || _isUploading) return;

//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Xác nhận gửi yêu cầu'),
//         content: const Text(
//           'Sau khi gửi, yêu cầu sẽ chuyển sang trạng thái chờ duyệt '
//           'và không thể chỉnh sửa. Tiếp tục?',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, false),
//             child: const Text('Hủy'),
//           ),
//           FilledButton(
//             onPressed: () => Navigator.pop(ctx, true),
//             child: const Text('Gửi'),
//           ),
//         ],
//       ),
//     );
//     if (confirmed != true || !mounted) return;

//     setState(() => _isSubmitting = true);
//     try {
//       await _service.updateYeuCau(_buildRequest(isSubmit: true));
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text('Gửi yêu cầu thành công')));
//         Navigator.pop(context, true); // báo list reload
//       }
//     } on AppException catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text(e.message)));
//       }
//     } finally {
//       if (mounted) setState(() => _isSubmitting = false);
//     }
//   }

//   // ── Build ─────────────────────────────────────────────────────────────

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Chỉnh sửa #${widget.yeuCauId}'),
//         actions: [
//           if (!_isLoading && _loadError == null)
//             _isSaving
//                 ? const Padding(
//                     padding: EdgeInsets.all(14),
//                     child: SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(strokeWidth: 2),
//                     ),
//                   )
//                 : TextButton(
//                     onPressed: _saveDraft,
//                     child: const Text('Lưu nháp'),
//                   ),
//         ],
//       ),
//       body: _buildBody(),
//     );
//   }

//   Widget _buildBody() {
//     // ── Đang load ──
//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     // ── Lỗi load ──
//     if (_loadError != null) {
//       return Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             AppErrorWidget(error: _loadError!),
//             const SizedBox(height: 12),
//             ElevatedButton.icon(
//               onPressed: _loadAll,
//               icon: const Icon(Icons.refresh),
//               label: const Text('Thử lại'),
//             ),
//           ],
//         ),
//       );
//     }

//     // ── Form ──
//     return Form(
//       key: _formKey,
//       child: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           _buildPersonSection(),
//           const SizedBox(height: 12),
//           _buildNoiDungSection(),
//           const SizedBox(height: 12),
//           _buildTaiLieuSection(),
//           const SizedBox(height: 32),
//           _buildSubmitButton(),
//           const SizedBox(height: 24),
//         ],
//       ),
//     );
//   }

//   // ── Sections ──────────────────────────────────────────────────────────

//   Widget _buildPersonSection() => _FormCard(
//     title: 'Thông tin người được yêu cầu',
//     children: [
//       Row(
//         children: [
//           Expanded(
//             child: _AppField(
//               controller: _lastNameCtrl!,
//               label: 'Họ',
//               hint: 'Nguyễn',
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: _AppField(
//               controller: _firstNameCtrl!,
//               label: 'Tên',
//               hint: 'Văn A',
//             ),
//           ),
//         ],
//       ),
//       const SizedBox(height: 12),
//       _DateField(
//         label: 'Ngày sinh',
//         value: _dob,
//         onChanged: (d) => setState(() => _dob = d),
//       ),
//       const SizedBox(height: 12),
//       _DropdownField<SelectorItemModel>(
//         label: 'Giới tính',
//         value: _selectedGioiTinh,
//         items: _gioiTinhList,
//         itemLabel: (e) => e.name,
//         onChanged: (v) => setState(() => _selectedGioiTinh = v),
//       ),
//       const SizedBox(height: 12),
//       _AppField(
//         controller: _cccdCtrl!,
//         label: 'CCCD',
//         hint: '0xxxxxxxxxx',
//         keyboardType: TextInputType.number,
//         inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//       ),
//       const SizedBox(height: 12),
//       _AppField(
//         controller: _phoneCtrl!,
//         label: 'Số điện thoại',
//         hint: '09xxxxxxxx',
//         keyboardType: TextInputType.phone,
//         inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//       ),
//       const SizedBox(height: 12),
//       _AppField(
//         controller: _diaChiCtrl!,
//         label: 'Địa chỉ thường trú',
//         hint: 'Số nhà, đường, phường/xã...',
//         maxLines: 2,
//       ),
//       const SizedBox(height: 12),
//       _DropdownField<SelectorItemModel>(
//         label: 'Quan hệ cư trú',
//         value: _selectedLoaiQuanHe,
//         items: _loaiQuanHeList,
//         itemLabel: (e) => e.name,
//         onChanged: (v) => setState(() => _selectedLoaiQuanHe = v),
//       ),
//     ],
//   );

//   Widget _buildNoiDungSection() => _FormCard(
//     title: 'Nội dung',
//     children: [
//       _AppField(
//         controller: _noiDungCtrl!,
//         label: 'Nội dung yêu cầu',
//         hint: 'Mô tả chi tiết...',
//         maxLines: 4,
//       ),
//     ],
//   );

//   Widget _buildTaiLieuSection() => _FormCard(
//     title: 'Tài liệu đính kèm',
//     children: [
//       ..._taiLieuEntries.asMap().entries.map((kv) {
//         final entry = kv.value;
//         final hasVisible =
//             entry.existingFiles.any((f) => !f.deleted) ||
//             entry.newFiles.isNotEmpty;
//         if (!hasVisible && entry.taiLieuCuTruId != 0) {
//           return const SizedBox.shrink();
//         }
//         return _TaiLieuEntryWidget(
//           index: kv.key + 1,
//           entry: entry,
//           isUploading: _isUploading,
//           onRemoveExisting: _removeExistingFile,
//           onRemoveNew: (f) => _removeNewFile(entry, f),
//           onAddFiles: () => _pickAndUpload(entry: entry),
//         );
//       }),
//       const SizedBox(height: 8),
//       OutlinedButton.icon(
//         onPressed: _isUploading ? null : () => _pickAndUpload(),
//         icon: const Icon(Icons.attach_file),
//         label: const Text('Thêm tài liệu mới'),
//       ),
//       if (_isUploading)
//         const Padding(
//           padding: EdgeInsets.only(top: 10),
//           child: Row(
//             children: [
//               SizedBox(
//                 width: 16,
//                 height: 16,
//                 child: CircularProgressIndicator(strokeWidth: 2),
//               ),
//               SizedBox(width: 8),
//               Text('Đang tải lên...'),
//             ],
//           ),
//         ),
//     ],
//   );

//   Widget _buildSubmitButton() => FilledButton.icon(
//     onPressed: (_isSubmitting || _isUploading) ? null : _submit,
//     icon: _isSubmitting
//         ? const SizedBox(
//             width: 18,
//             height: 18,
//             child: CircularProgressIndicator(
//               strokeWidth: 2,
//               color: Colors.white,
//             ),
//           )
//         : const Icon(Icons.send_outlined),
//     label: const Text('Gửi yêu cầu'),
//     style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
//   );
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // _TaiLieuEntryWidget
// // ─────────────────────────────────────────────────────────────────────────────

// class _TaiLieuEntryWidget extends StatelessWidget {
//   final int index;
//   final _TaiLieuEntry entry;
//   final bool isUploading;
//   final void Function(_ExistingFile) onRemoveExisting;
//   final void Function(UploadedFileModel) onRemoveNew;
//   final VoidCallback onAddFiles;

//   const _TaiLieuEntryWidget({
//     required this.index,
//     required this.entry,
//     required this.isUploading,
//     required this.onRemoveExisting,
//     required this.onRemoveNew,
//     required this.onAddFiles,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final visibleExisting = entry.existingFiles
//         .where((f) => !f.deleted)
//         .toList();

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Theme.of(
//           context,
//         ).colorScheme.surfaceContainerHighest.withOpacity(0.4),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               const Icon(Icons.folder_outlined, size: 16),
//               const SizedBox(width: 6),
//               Text(
//                 'Tài liệu $index',
//                 style: Theme.of(
//                   context,
//                 ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
//               ),
//               const Spacer(),
//               TextButton.icon(
//                 onPressed: isUploading ? null : onAddFiles,
//                 icon: const Icon(Icons.add, size: 16),
//                 label: const Text('Thêm'),
//                 style: TextButton.styleFrom(
//                   visualDensity: VisualDensity.compact,
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 8,
//                     vertical: 4,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           ...visibleExisting.map(
//             (ef) => _FileRow(
//               icon: ef.file.contentType.startsWith('image/')
//                   ? Icons.image_outlined
//                   : Icons.picture_as_pdf_outlined,
//               name: ef.file.fileName,
//               badge: 'Đã lưu',
//               badgeColor: Colors.green.shade50,
//               badgeTextColor: Colors.green.shade700,
//               onDelete: () => onRemoveExisting(ef),
//             ),
//           ),
//           ...entry.newFiles.map(
//             (f) => _FileRow(
//               icon: f.isImage
//                   ? Icons.image_outlined
//                   : Icons.picture_as_pdf_outlined,
//               name: f.fileName,
//               badge: 'Mới',
//               badgeColor: Colors.blue.shade50,
//               badgeTextColor: Colors.blue.shade700,
//               onDelete: () => onRemoveNew(f),
//             ),
//           ),
//           if (visibleExisting.isEmpty && entry.newFiles.isEmpty)
//             Text(
//               'Chưa có file nào',
//               style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                 color: Theme.of(context).colorScheme.outline,
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// class _FileRow extends StatelessWidget {
//   final IconData icon;
//   final String name;
//   final String badge;
//   final Color badgeColor;
//   final Color badgeTextColor;
//   final VoidCallback onDelete;

//   const _FileRow({
//     required this.icon,
//     required this.name,
//     required this.badge,
//     required this.badgeColor,
//     required this.badgeTextColor,
//     required this.onDelete,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               name,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: Theme.of(context).textTheme.bodySmall,
//             ),
//           ),
//           const SizedBox(width: 6),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//             decoration: BoxDecoration(
//               color: badgeColor,
//               borderRadius: BorderRadius.circular(4),
//             ),
//             child: Text(
//               badge,
//               style: TextStyle(
//                 fontSize: 10,
//                 color: badgeTextColor,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//           const SizedBox(width: 4),
//           InkWell(
//             onTap: onDelete,
//             borderRadius: BorderRadius.circular(12),
//             child: const Padding(
//               padding: EdgeInsets.all(4),
//               child: Icon(Icons.close, size: 16, color: Colors.red),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // Shared form widgets
// // ─────────────────────────────────────────────────────────────────────────────

// class _FormCard extends StatelessWidget {
//   final String title;
//   final List<Widget> children;

//   const _FormCard({required this.title, required this.children});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: EdgeInsets.zero,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: Theme.of(
//                 context,
//               ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
//             ),
//             const Divider(height: 16),
//             ...children,
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _AppField extends StatelessWidget {
//   final TextEditingController controller;
//   final String label;
//   final String? hint;
//   final int maxLines;
//   final TextInputType? keyboardType;
//   final List<TextInputFormatter>? inputFormatters;
//   final String? Function(String?)? validator;

//   const _AppField({
//     required this.controller,
//     required this.label,
//     this.hint,
//     this.maxLines = 1,
//     this.keyboardType,
//     this.inputFormatters,
//     this.validator,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       controller: controller,
//       maxLines: maxLines,
//       keyboardType: keyboardType,
//       inputFormatters: inputFormatters,
//       validator: validator,
//       decoration: InputDecoration(
//         labelText: label,
//         hintText: hint,
//         border: const OutlineInputBorder(),
//         isDense: true,
//       ),
//     );
//   }
// }

// class _DateField extends StatelessWidget {
//   final String label;
//   final DateTime? value;
//   final ValueChanged<DateTime?> onChanged;

//   const _DateField({
//     required this.label,
//     required this.value,
//     required this.onChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: () async {
//         final picked = await showDatePicker(
//           context: context,
//           initialDate: value ?? DateTime(1990),
//           firstDate: DateTime(1900),
//           lastDate: DateTime.now(),
//         );
//         onChanged(picked);
//       },
//       borderRadius: BorderRadius.circular(4),
//       child: InputDecorator(
//         decoration: InputDecoration(
//           labelText: label,
//           border: const OutlineInputBorder(),
//           isDense: true,
//           suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
//         ),
//         child: Text(
//           value != null
//               ? '${value!.day.toString().padLeft(2, '0')}/'
//                     '${value!.month.toString().padLeft(2, '0')}/'
//                     '${value!.year}'
//               : 'Chọn ngày',
//           style: value != null
//               ? null
//               : TextStyle(color: Theme.of(context).hintColor),
//         ),
//       ),
//     );
//   }
// }

// class _DropdownField<T> extends StatelessWidget {
//   final String label;
//   final T? value;
//   final List<T> items;
//   final String Function(T) itemLabel;
//   final ValueChanged<T?> onChanged;

//   const _DropdownField({
//     required this.label,
//     required this.value,
//     required this.items,
//     required this.itemLabel,
//     required this.onChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return DropdownButtonFormField<T>(
//       initialValue: value,
//       decoration: InputDecoration(
//         labelText: label,
//         border: const OutlineInputBorder(),
//         isDense: true,
//       ),
//       items: items
//           .map((e) => DropdownMenuItem<T>(value: e, child: Text(itemLabel(e))))
//           .toList(),
//       onChanged: onChanged,
//     );
//   }
// }

// lib/features/thanh_vien/screens/yeu_cau_edit_screen.dart

import 'package:flutter/material.dart';

import '../../../core/errors/errors.dart';
import '../../cu_tru/widgets/shared_widget.dart';
import '../widgets/tai_lieu_cu_tru_editor.dart';
import '../services/tv_yeu_cau_service.dart';
import '../models/yeu_cau_cu_tru_model.dart';
import '../models/thanh_vien_request.dart';
import '../models/tai_lieu_cu_tru_request.dart';
// import '../models/thong_tin_cu_dan_model.dart';
import '../../utils/models/selector_item_model.dart';
import '../../utils/services/utils_service.dart';
import '../../utils/widgets/app_selector_field.dart';

class YeuCauEditScreen extends StatefulWidget {
  final int yeuCauId;

  const YeuCauEditScreen({super.key, required this.yeuCauId});

  @override
  State<YeuCauEditScreen> createState() => _YeuCauEditScreenState();
}

class _YeuCauEditScreenState extends State<YeuCauEditScreen> {
  final _service    = YeuCauCuTruService.instance;
  final _utilsSvc   = UtilsService.instance;
  final _formKey    = GlobalKey<FormState>();
  final _scrollCtrl = ScrollController();

  // ── Load state ────────────────────────────────────────────────────────
  bool _isLoading = true;
  AppException? _loadError;

  // ── Form data (set sau khi load) ──────────────────────────────────────
  YeuCauCuTruModel? _yeuCau;

  final _hoCtrl      = TextEditingController();
  final _tenCtrl     = TextEditingController();
  final _cccdCtrl    = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _diaChiCtrl  = TextEditingController();
  final _noiDungCtrl = TextEditingController();

  DateTime? _dob;
  SelectorItemModel? _gioiTinh;
  SelectorItemModel? _loaiQuanHe;

  // Catalog futures — khởi tạo sớm, dùng chung cho AppSelectorField
  late final Future<List<SelectorItemModel>> _gioiTinhFuture =
      _utilsSvc.getGioiTinhSelector();
  late final Future<List<SelectorItemModel>> _loaiQuanHeFuture =
      _utilsSvc.getLoaiQuanHeCuTruSelector();

  // Tài liệu — quản lý bởi TaiLieuCuTruEditor
  List<TaiLieuCuTruRequest> _taiLieuCuTrus = [];

  // ── Submit state ──────────────────────────────────────────────────────
  bool _isSubmitting = false;
  AppException? _submitError;

  // ─────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _hoCtrl.dispose();
    _tenCtrl.dispose();
    _cccdCtrl.dispose();
    _phoneCtrl.dispose();
    _diaChiCtrl.dispose();
    _noiDungCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ── Load chi tiết + catalog song song ────────────────────────────────

  Future<void> _loadAll() async {
    setState(() {
      _isLoading   = true;
      _loadError   = null;
      _submitError = null;
    });

    try {
      final results = await Future.wait([
        _service.getYeuCauById(widget.yeuCauId),
        _gioiTinhFuture,
        _loaiQuanHeFuture,
      ]);

      final d          = results[0] as YeuCauCuTruModel;
      final gioiTinh   = results[1] as List<SelectorItemModel>;
      final loaiQuanHe = results[2] as List<SelectorItemModel>;

      // Pre-fill text controllers
      _hoCtrl.text      = d.yeuCauHo ?? '';
      _tenCtrl.text     = d.yeuCauTen ?? '';
      _cccdCtrl.text    = d.yeuCauCCCD ?? '';
      _phoneCtrl.text   = d.yeuCauSoDienThoai ?? '';
      _diaChiCtrl.text  = d.yeuCauDiaChi ?? '';
      _noiDungCtrl.text = d.noiDung ?? '';
      _dob              = d.yeuCauNgaySinh;

      // Pre-select catalog
      _gioiTinh   = gioiTinh.where((e) => e.id == d.yeuCauGioiTinhId).firstOrNull;
      _loaiQuanHe = loaiQuanHe.where((e) => e.id == d.yeuCauLoaiQuanHeId).firstOrNull;

      setState(() {
        _yeuCau   = d;
        _isLoading = false;
      });
    } on AppException catch (e) {
      setState(() {
        _loadError = e;
        _isLoading = false;
      });
    }
  }

  // ── Validate selector / date bắt buộc ────────────────────────────────

  bool _validateRequiredFields() {
    final missing = <String>[
      if (_dob == null) 'Ngày sinh',
      if (_gioiTinh == null) 'Giới tính',
      if (_loaiQuanHe == null) 'Loại quan hệ',
    ];
    if (missing.isNotEmpty) {
      _showSnack('Vui lòng điền: ${missing.join(', ')}');
      return false;
    }
    return true;
  }

  // ── Submit (lưu nháp hoặc nộp) ────────────────────────────────────────

  Future<void> _submit(bool isSubmit) async {
    if (!_formKey.currentState!.validate()) return;
    if (!_validateRequiredFields()) return;
    if (_isSubmitting) return;

    // Confirm khi nộp thật
    if (isSubmit) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Xác nhận gửi yêu cầu'),
          content: const Text(
            'Sau khi gửi, yêu cầu sẽ chuyển sang trạng thái chờ duyệt '
            'và không thể chỉnh sửa. Tiếp tục?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Gửi'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }

    setState(() {
      _isSubmitting = true;
      _submitError  = null;
    });

    try {
      await _service.updateYeuCau(
        CapNhatYeuCauCuTruRequest(
          id:          widget.yeuCauId,
          isSubmit:    isSubmit,
          lastName:    _hoCtrl.text.trim(),
          firstName:   _tenCtrl.text.trim(),
          dob:         _dob,
          gioiTinhId:  _gioiTinh?.id,
          loaiQuanHeId: _loaiQuanHe?.id,
          cccd:        _cccdCtrl.text.trim().isEmpty ? null : _cccdCtrl.text.trim(),
          phoneNumber: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
          diaChi:      _diaChiCtrl.text.trim().isEmpty ? null : _diaChiCtrl.text.trim(),
          noiDung:     _noiDungCtrl.text.trim().isEmpty ? null : _noiDungCtrl.text.trim(),
          taiLieuCuTrus: _taiLieuCuTrus.isEmpty ? null : _taiLieuCuTrus,
        ),
      );

      if (mounted) {
        _showSnack(isSubmit ? 'Đã nộp yêu cầu thành công' : 'Đã lưu nháp');
        Navigator.pop(context, true);
      }
    } on AppException catch (e) {
      setState(() => _submitError = e);
      _scrollCtrl.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chỉnh sửa yêu cầu #${widget.yeuCauId}'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppErrorWidget(error: _loadError!),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _loadAll,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    return _isSubmitting
        ? const Center(child: CircularProgressIndicator())
        : Form(
            key: _formKey,
            child: ListView(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              children: [
                // Căn hộ readonly (thông tin từ yeuCau)
                _CanHoReadonlyCard(yeuCau: _yeuCau!),
                const SizedBox(height: 20),

                // Lỗi submit
                if (_submitError != null) ...[
                  AppErrorWidget(error: _submitError!),
                  const SizedBox(height: 12),
                ],

                // ── Thông tin người ───────────────────────────────────
                const SectionLabel('Thông tin người được yêu cầu *'),

                Row(
                  children: [
                    Expanded(
                      child: Field(
                        controller: _hoCtrl,
                        label: 'Họ *',
                        validator: _required,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Field(
                        controller: _tenCtrl,
                        label: 'Tên *',
                        validator: _required,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                DatePickerField(
                  label: 'Ngày sinh *',
                  value: _dob,
                  onTap: _pickDob,
                ),
                const SizedBox(height: 12),

                AppSelectorField.future(
                  label: 'Giới tính *',
                  future: _gioiTinhFuture,
                  selectedItems: _gioiTinh != null ? [_gioiTinh!] : [],
                  isRequired: true,
                  onChangedSingle: (v) => setState(() => _gioiTinh = v),
                ),
                const SizedBox(height: 12),

                AppSelectorField.future(
                  label: 'Loại quan hệ *',
                  future: _loaiQuanHeFuture,
                  selectedItems: _loaiQuanHe != null ? [_loaiQuanHe!] : [],
                  isRequired: true,
                  onChangedSingle: (v) => setState(() => _loaiQuanHe = v),
                ),
                const SizedBox(height: 20),

                // ── Thông tin bổ sung ─────────────────────────────────
                const SectionLabel('Thông tin bổ sung'),

                Field(
                  controller: _cccdCtrl,
                  label: 'CMND/CCCD',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),

                Field(
                  controller: _phoneCtrl,
                  label: 'Số điện thoại',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),

                Field(
                  controller: _diaChiCtrl,
                  label: 'Địa chỉ thường trú',
                ),
                const SizedBox(height: 12),

                Field(
                  controller: _noiDungCtrl,
                  label: 'Ghi chú',
                  maxLines: 3,
                ),
                const SizedBox(height: 20),

                // ── Tài liệu đính kèm ─────────────────────────────────
                const SectionLabel('Tài liệu đính kèm'),

                TaiLieuCuTruEditor(
                  // TODO: Pre-fill tài liệu từ nháp cũ
                  initialDocuments: _yeuCau!.documents,
                  onChanged: (list) => setState(() => _taiLieuCuTrus = list),
                ),
                const SizedBox(height: 24),

                // ── 2 nút ────────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _submit(false),
                        child: const Text('Lưu nháp'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => _submit(true),
                        child: const Text('Nộp yêu cầu'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Trường này là bắt buộc' : null;
}

// ── Card căn hộ readonly (từ YeuCauCuTruModel) ────────────────────────────────

class _CanHoReadonlyCard extends StatelessWidget {
  final YeuCauCuTruModel yeuCau;

  const _CanHoReadonlyCard({required this.yeuCau});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.apartment_outlined,
                color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    yeuCau.diaChiCanHo,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    'Loại yêu cầu: ${yeuCau.tenLoaiYeuCau}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}