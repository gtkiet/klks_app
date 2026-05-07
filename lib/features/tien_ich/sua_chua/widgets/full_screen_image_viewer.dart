// lib/features/yeu_cau_sua_chua/widgets/full_screen_image_viewer.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/sua_chua_model.dart';

/// Mở full-screen image viewer với hỗ trợ pinch-to-zoom, swipe qua lại,
/// và hiển thị tên file + số thứ tự ảnh.
///
/// Cách dùng:
/// ```dart
/// FullScreenImageViewer.show(
///   context,
///   files: d.danhSachTep,
///   initialIndex: i,
/// );
/// ```
class FullScreenImageViewer extends StatefulWidget {
  final List<DanhSachTep> files;
  final int initialIndex;

  const FullScreenImageViewer({
    super.key,
    required this.files,
    required this.initialIndex,
  });

  /// Convenience: push route
  static void show(
    BuildContext context, {
    required List<DanhSachTep> files,
    int initialIndex = 0,
  }) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (_, _, _) =>
            FullScreenImageViewer(files: files, initialIndex: initialIndex),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 220),
      ),
    );
  }

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late final PageController _pageController;
  late int _currentIndex;
  bool _barsVisible = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    // Ẩn status bar khi mở viewer
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Khôi phục UI khi đóng
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggleBars() => setState(() => _barsVisible = !_barsVisible);

  void _close() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    final file = widget.files[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleBars,
        child: Stack(
          children: [
            // ── Paged image list ──────────────────────────────────────────
            PageView.builder(
              controller: _pageController,
              itemCount: widget.files.length,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemBuilder: (context, i) {
                final f = widget.files[i];
                return _ZoomableImage(url: f.fileUrl);
              },
            ),

            // ── Top bar ───────────────────────────────────────────────────
            AnimatedOpacity(
              opacity: _barsVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: IgnorePointer(
                ignoring: !_barsVisible,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black87, Colors.transparent],
                    ),
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: _close,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                file.fileName ?? 'Ảnh ${_currentIndex + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${_currentIndex + 1} / ${widget.files.length}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Bottom dots indicator ─────────────────────────────────────
            if (widget.files.length > 1)
              AnimatedOpacity(
                opacity: _barsVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: IgnorePointer(
                  ignoring: !_barsVisible,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _DotsIndicator(
                          count: widget.files.length,
                          current: _currentIndex,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // ── Prev / Next arrow buttons ─────────────────────────────────
            if (widget.files.length > 1)
              AnimatedOpacity(
                opacity: _barsVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: IgnorePointer(
                  ignoring: !_barsVisible,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _NavArrow(
                      icon: Icons.chevron_left,
                      onTap: _currentIndex > 0
                          ? () => _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            if (widget.files.length > 1)
              AnimatedOpacity(
                opacity: _barsVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: IgnorePointer(
                  ignoring: !_barsVisible,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _NavArrow(
                      icon: Icons.chevron_right,
                      onTap: _currentIndex < widget.files.length - 1
                          ? () => _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            )
                          : null,
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

// ─── Zoomable image (InteractiveViewer) ──────────────────────────────────────

class _ZoomableImage extends StatefulWidget {
  final String url;
  const _ZoomableImage({required this.url});

  @override
  State<_ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<_ZoomableImage> {
  final _transformController = TransformationController();

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _transformController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {
        // Double-tap: reset nếu đang zoom, ngược lại zoom 2×
        if (_transformController.value != Matrix4.identity()) {
          _resetZoom();
        } else {
          _transformController.value = Matrix4.diagonal3Values(2.5, 2.5, 1);
        }
      },
      child: InteractiveViewer(
        transformationController: _transformController,
        minScale: 0.8,
        maxScale: 5.0,
        child: Center(
          child: Image.network(
            widget.url,
            fit: BoxFit.contain,
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded /
                            progress.expectedTotalBytes!
                      : null,
                  color: Colors.white,
                ),
              );
            },
            errorBuilder: (_, _, _) => Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.broken_image, color: Colors.white54, size: 64),
                SizedBox(height: 8),
                Text(
                  'Không thể tải ảnh',
                  style: TextStyle(color: Colors.white54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Dots indicator ───────────────────────────────────────────────────────────

class _DotsIndicator extends StatelessWidget {
  final int count;
  final int current;
  const _DotsIndicator({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.white38,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

// ─── Nav arrow button ─────────────────────────────────────────────────────────

class _NavArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _NavArrow({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: onTap != null ? Colors.black45 : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: onTap != null ? Colors.white : Colors.white24,
          size: 32,
        ),
      ),
    );
  }
}
