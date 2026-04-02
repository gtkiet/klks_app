// lib/features/profile/screens/change_avatar_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/profile_service.dart';

class ChangeAvatarScreen extends StatefulWidget {
  const ChangeAvatarScreen({super.key});

  @override
  State<ChangeAvatarScreen> createState() => _ChangeAvatarScreenState();
}

class _ChangeAvatarScreenState extends State<ChangeAvatarScreen> {
  final ProfileService _service = ProfileService();
  File? _file;
  bool _loading = false;

  Future<void> _pick() async {
    final picker = ImagePicker();
    final res = await picker.pickImage(source: ImageSource.gallery);

    if (res != null) {
      setState(() => _file = File(res.path));
    }
  }

  Future<void> _upload() async {
    if (_file == null) return;

    try {
      setState(() => _loading = true);

      final url = await _service.changeAvatar(_file!);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Uploaded: $url')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Avatar')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_file != null) Image.file(_file!, height: 150),

            const SizedBox(height: 16),

            ElevatedButton(onPressed: _pick, child: const Text('Pick Image')),

            ElevatedButton(
              onPressed: _loading ? null : _upload,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }
}
