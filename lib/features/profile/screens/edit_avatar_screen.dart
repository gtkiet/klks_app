import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';

import '../providers/profile_provider.dart';
// import '../../../models/user_profile.dart';

class EditAvatarScreen extends StatefulWidget {
  const EditAvatarScreen({super.key});

  @override
  State<EditAvatarScreen> createState() => _EditAvatarScreenState();
}

class _EditAvatarScreenState extends State<EditAvatarScreen> {
  Offset _dragOffset = Offset.zero;
  Offset _dragStart = Offset.zero;
  Offset _dragStartOffset = Offset.zero;

  double _rotation = 0.0;
  bool _flipHorizontal = false;

  double _scale = 1.0;
  double _startScale = 1.0;

  File? selectedImage;
  final ImagePicker _picker = ImagePicker();
  final GlobalKey _previewKey = GlobalKey();

  bool isLoading = false;

  /// =========================
  /// AUTO FIT SCALE (FIX ZOOM)
  /// =========================
  Future<void> _fitImage(File file) async {
    final bytes = await file.readAsBytes();
    final decoded = img.decodeImage(bytes);

    if (decoded == null) return;

    final imageWidth = decoded.width.toDouble();
    final imageHeight = decoded.height.toDouble();

    const boxSize = 230.0;
    final scaleX = boxSize / imageWidth;
    final scaleY = boxSize / imageHeight;

    final fitScale = math.max(scaleX, scaleY);

    setState(() {
      _scale = fitScale;
      _dragOffset = Offset.zero;
    });
  }

  /// =========================
  /// PICK IMAGE
  /// =========================
  Future<void> _pickFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );

    if (image != null) {
      final file = File(image.path);
      setState(() {
        selectedImage = file;
        _resetTransform();
      });
      await _fitImage(file);
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (image != null) {
      final file = File(image.path);
      setState(() {
        selectedImage = file;
        _resetTransform();
      });
      await _fitImage(file);
    }
  }

  void _resetTransform() {
    _dragOffset = Offset.zero;
    _scale = 1.0;
    _rotation = 0.0;
    _flipHorizontal = false;
  }

  /// =========================
  /// EXPORT IMAGE
  /// =========================
  Future<File> _exportImage() async {
    await Future.delayed(const Duration(milliseconds: 100));
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

  /// =========================
  /// SAVE AVATAR (UPDATE PROVIDER)
  /// =========================
  Future<void> _saveAvatar() async {
    if (isLoading) return;
    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn ảnh")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final file = await _exportImage();
      final provider = context.read<ProfileProvider>();

      final success = await provider.changeAvatar(file);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cập nhật avatar thành công")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error ?? "Cập nhật thất bại")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $e")),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    final avatarUrl = selectedImage != null
        ? null
        : provider.profile?.anhDaiDienUrl ?? "";

    return Scaffold(
      appBar: AppBar(title: const Text('Chỉnh sửa ảnh đại diện')),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Center(child: _buildCropBox(avatarUrl)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _btn(Icons.camera_alt, _pickFromCamera),
              _btn(Icons.photo, _pickFromGallery),
              _btn(Icons.rotate_left, () => setState(() => _rotation -= 90)),
              _btn(Icons.rotate_right, () => setState(() => _rotation += 90)),
              _btn(Icons.flip, () => setState(() => _flipHorizontal = !_flipHorizontal)),
            ],
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: isLoading ? null : _saveAvatar,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Lưu"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap) {
    return IconButton(onPressed: onTap, icon: Icon(icon));
  }

  Widget _buildCropBox(String? avatarUrl) {
    final url = avatarUrl ?? "";

    return GestureDetector(
      onScaleStart: (details) {
        _dragStart = details.focalPoint;
        _dragStartOffset = _dragOffset;
        _startScale = _scale;
      },
      onScaleUpdate: (details) {
        setState(() {
          _scale = (_startScale * details.scale).clamp(0.5, 5.0);
          final delta = details.focalPoint - _dragStart;
          final limit = 120.0 * _scale;
          _dragOffset = Offset(
            (_dragStartOffset.dx + delta.dx).clamp(-limit, limit),
            (_dragStartOffset.dy + delta.dy).clamp(-limit, limit),
          );
        });
      },
      child: RepaintBoundary(
        key: _previewKey,
        child: Container(
          width: 230,
          height: 230,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipOval(
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..translate(_dragOffset.dx, _dragOffset.dy)
                ..rotateZ(_rotation * math.pi / 180)
                ..scale((_flipHorizontal ? -1.0 : 1.0) * _scale, _scale),
              child: selectedImage != null
                  ? Image.file(selectedImage!, fit: BoxFit.cover)
                  : (url.isNotEmpty
                      ? Image.network(url, fit: BoxFit.cover)
                      : const Icon(Icons.person, size: 80)),
            ),
          ),
        ),
      ),
    );
  }
}