// lib/features/cu_tru/screens/image_gallery_screen.dart
//
// Viewer ảnh fullscreen với:
//   - Swipe ngang để chuyển ảnh (PageView)
//   - Pinch-to-zoom + double-tap zoom + pan (InteractiveViewer)
//   - Hiển thị tên file + số thứ tự "2 / 5"
//   - Nút: mở app ngoài, đóng
//   - Loading skeleton & error placeholder khi ảnh lỗi

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:dio/dio.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

import '../utils/file_opener.dart';

class ImageGalleryScreen extends StatefulWidget {
  final List<OpenableFile> files;
  final int initialIndex;

  const ImageGalleryScreen({
    super.key,
    required this.files,
    this.initialIndex = 0,
  });

  @override
  State<ImageGalleryScreen> createState() => _ImageGalleryScreenState();
}

class _ImageGalleryScreenState extends State<ImageGalleryScreen> {
  late final PageController _pageController;
  late int _currentIndex;
  bool _uiVisible = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    // Ẩn status bar để fullscreen thật sự
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _pageController.dispose();
    super.dispose();
  }

  void _toggleUi() => setState(() => _uiVisible = !_uiVisible);

  OpenableFile get _current => widget.files[_currentIndex];

  Future<void> _openExternal() async {
    setState(() => _isSaving = true);
    try {
      final dir = await getTemporaryDirectory();
      final savePath = path.join(
        dir.path,
        '${DateTime.now().millisecondsSinceEpoch}_${_current.fileName}',
      );
      await Dio().download(_current.fileUrl, savePath);
      await OpenFilex.open(savePath);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleUi,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // ── PageView ảnh ───────────────────────────────────────────────
            PageView.builder(
              controller: _pageController,
              itemCount: widget.files.length,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemBuilder: (_, i) => _ZoomableImage(file: widget.files[i]),
            ),

            // ── Top bar (AppBar custom) ────────────────────────────────────
            AnimatedSlide(
              offset: _uiVisible ? Offset.zero : const Offset(0, -1),
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              child: AnimatedOpacity(
                opacity: _uiVisible ? 1 : 0,
                duration: const Duration(milliseconds: 220),
                child: _TopBar(
                  file: _current,
                  currentIndex: _currentIndex,
                  total: widget.files.length,
                  isSaving: _isSaving,
                  onClose: () => Navigator.pop(context),
                  onOpenExternal: _openExternal,
                ),
              ),
            ),

            // ── Bottom: indicator dots ─────────────────────────────────────
            if (widget.files.length > 1)
              AnimatedSlide(
                offset: _uiVisible ? Offset.zero : const Offset(0, 1),
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                child: AnimatedOpacity(
                  opacity: _uiVisible ? 1 : 0,
                  duration: const Duration(milliseconds: 220),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _DotIndicator(
                          count: widget.files.length,
                          current: _currentIndex,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── ZoomableImage ────────────────────────────────────────────────────────────

class _ZoomableImage extends StatefulWidget {
  final OpenableFile file;
  const _ZoomableImage({required this.file});

  @override
  State<_ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<_ZoomableImage>
    with SingleTickerProviderStateMixin {
  final TransformationController _transformCtrl = TransformationController();
  late AnimationController _animCtrl;
  Animation<Matrix4>? _animation;

  @override
  void initState() {
    super.initState();
    _animCtrl =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 250),
        )..addListener(() {
          if (_animation != null) {
            _transformCtrl.value = _animation!.value;
          }
        });
  }

  @override
  void dispose() {
    _transformCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _onDoubleTap(TapDownDetails details) {
    final isZoomedIn = _transformCtrl.value != Matrix4.identity();

    if (isZoomedIn) {
      _animation = Matrix4Tween(
        begin: _transformCtrl.value,
        end: Matrix4.identity(),
      ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    } else {
      final pos = details.localPosition;
      final scale = 2.5;

      final dx = -pos.dx * (scale - 1);
      final dy = -pos.dy * (scale - 1);

      final zoomed = Matrix4.identity()
        ..translateByVector3(Vector3(dx, dy, 0))
        ..scaleByVector3(Vector3.all(scale));

      _animation = Matrix4Tween(
        begin: _transformCtrl.value,
        end: zoomed,
      ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    }

    _animCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: _onDoubleTap,
      onDoubleTap: () {}, // Cần để GestureDetector nhận onDoubleTapDown
      child: InteractiveViewer(
        transformationController: _transformCtrl,
        minScale: 0.5,
        maxScale: 5.0,
        clipBehavior: Clip.none,
        child: Center(
          child: CachedNetworkImage(
            imageUrl: widget.file.fileUrl,
            fit: BoxFit.contain,
            placeholder: (_, _) => const Center(
              child: CircularProgressIndicator(color: Colors.white54),
            ),
            errorWidget: (_, url, _) => Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.broken_image_outlined,
                  color: Colors.white38,
                  size: 64,
                ),
                SizedBox(height: 12),
                Text(
                  'Không thể tải ảnh',
                  style: TextStyle(color: Colors.white38),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── TopBar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final OpenableFile file;
  final int currentIndex;
  final int total;
  final bool isSaving;
  final VoidCallback onClose;
  final VoidCallback onOpenExternal;

  const _TopBar({
    required this.file,
    required this.currentIndex,
    required this.total,
    required this.isSaving,
    required this.onClose,
    required this.onOpenExternal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black87, Colors.transparent],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            children: [
              // Nút đóng
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: onClose,
              ),
              const SizedBox(width: 4),

              // Tên file + số thứ tự
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      file.fileName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (total > 1)
                      Text(
                        '${currentIndex + 1} / $total',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),

              // Nút mở app ngoài
              if (isSaving)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                )
              else
                IconButton(
                  icon: const Icon(Icons.open_in_new, color: Colors.white),
                  tooltip: 'Mở bằng app khác',
                  onPressed: onOpenExternal,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── DotIndicator ─────────────────────────────────────────────────────────────

class _DotIndicator extends StatelessWidget {
  final int count;
  final int current;

  const _DotIndicator({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white38,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}
