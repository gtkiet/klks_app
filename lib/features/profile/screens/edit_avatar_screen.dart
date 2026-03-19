import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../services/profile_service.dart';

import '../../../widgets/app_button.dart';

class EditAvatarScreen extends StatefulWidget {
  const EditAvatarScreen({super.key});

  @override
  State<EditAvatarScreen> createState() => _EditAvatarScreenState();
}

class _EditAvatarScreenState extends State<EditAvatarScreen> {
  File? _selectedImage;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();
  final GlobalKey _previewKey = GlobalKey();

  // Transform
  Offset _dragOffset = Offset.zero;
  Offset _dragStart = Offset.zero;
  Offset _dragStartOffset = Offset.zero;

  double _rotation = 0.0;
  bool _flipHorizontal = false;

  double _scale = 1.0;
  double _startScale = 1.0;

  static const double boxSize = 230.0;
  static const double minScale = 0.5;
  static const double maxScale = 5.0;

  // =========================
  // PICK IMAGE (CAMERA OR GALLERY)
  // =========================
  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 90,
    );
    if (image == null) return;

    final file = File(image.path);
    setState(() {
      _selectedImage = file;
      _resetTransform();
    });
    await _fitImage(file);
  }

  // =========================
  // FIT IMAGE TO CROP BOX (cover)
  // =========================
  Future<void> _fitImage(File file) async {
    final bytes = await file.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return;

    final scaleX = boxSize / decoded.width;
    final scaleY = boxSize / decoded.height;

    setState(() {
      _scale = math.max(scaleX, scaleY);
      _dragOffset = Offset.zero;
    });
  }

  void _resetTransform() {
    _dragOffset = Offset.zero;
    _scale = 1.0;
    _rotation = 0.0;
    _flipHorizontal = false;
  }

  // =========================
  // EXPORT & SAVE AVATAR
  // =========================
  Future<File> _exportImage() async {
    final context = _previewKey.currentContext;
    final boundary = context!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    final decoded = img.decodeImage(pngBytes)!;
    final jpgBytes = img.encodeJpg(decoded, quality: 90);

    final tempDir = await getTemporaryDirectory();
    final file = File(
      "${tempDir.path}/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg",
    );
    await file.writeAsBytes(jpgBytes);
    return file;
  }

  Future<void> _saveAvatar() async {
    if (_isLoading) return;
    if (_selectedImage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Vui lòng chọn ảnh")));
      return;
    }

    // Preview before save
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xem trước avatar"),
        content: SizedBox(
          width: boxSize,
          height: boxSize,
          child: ClipOval(child: _buildCropContent()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Lưu"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final file = await _exportImage();
      final newUrl = await ProfileService.changeAvatar(file);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cập nhật avatar thành công")),
      );
      Navigator.pop(context, newUrl);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    final avatarUrl = ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      appBar: AppBar(title: const Text('Chỉnh sửa ảnh đại diện')),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Center(child: _buildCropBox(avatarUrl)),
          const SizedBox(height: 20),
          _buildToolbar(),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              // child: ElevatedButton(
              //   onPressed: _isLoading ? null : _saveAvatar,
              //   child: _isLoading
              //       ? const CircularProgressIndicator(color: Colors.white)
              //       : const Text("Lưu"),
              // ),
              child: EditButton(onPressed: _saveAvatar, isLoading: _isLoading),
            ),
          ),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap) {
    return IconButton(onPressed: onTap, icon: Icon(icon));
  }

  Widget _buildToolbar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _btn(Icons.camera_alt, () => _pickImage(ImageSource.camera)),
        _btn(Icons.photo, () => _pickImage(ImageSource.gallery)),
        _btn(
          Icons.zoom_in,
          () => setState(() {
            _scale = (_scale * 1.1).clamp(minScale, maxScale);
          }),
        ),
        _btn(
          Icons.zoom_out,
          () => setState(() {
            _scale = (_scale / 1.1).clamp(minScale, maxScale);
          }),
        ),
        _btn(Icons.rotate_left, () => setState(() => _rotation -= 90)),
        _btn(Icons.rotate_right, () => setState(() => _rotation += 90)),
        _btn(
          Icons.flip,
          () => setState(() => _flipHorizontal = !_flipHorizontal),
        ),
      ],
    );
  }

  Widget _buildCropBox(String? avatarUrl) {
    return GestureDetector(
      onScaleStart: (details) {
        _dragStart = details.focalPoint;
        _dragStartOffset = _dragOffset;
        _startScale = _scale;
      },
      onScaleUpdate: (details) {
        setState(() {
          _scale = (_startScale * details.scale).clamp(minScale, maxScale);
          final delta = details.focalPoint - _dragStart;
          final limit = boxSize * _scale / 2;
          _dragOffset = Offset(
            (_dragStartOffset.dx + delta.dx).clamp(-limit, limit),
            (_dragStartOffset.dy + delta.dy).clamp(-limit, limit),
          );
        });
      },
      child: RepaintBoundary(
        key: _previewKey,
        child: Container(
          width: boxSize,
          height: boxSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipOval(child: _buildCropContent()),
        ),
      ),
    );
  }

  Widget _buildCropContent() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..translate(_dragOffset.dx, _dragOffset.dy)
        ..rotateZ(_rotation * math.pi / 180)
        ..scale((_flipHorizontal ? -1.0 : 1.0) * _scale, _scale),
      child: _selectedImage != null
          ? Image.file(_selectedImage!, fit: BoxFit.cover)
          : const Icon(Icons.person, size: 80, color: Colors.grey),
    );
  }
}
