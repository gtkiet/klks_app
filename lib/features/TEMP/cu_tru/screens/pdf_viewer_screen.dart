// lib/features/cu_tru/screens/pdf_viewer_screen.dart
//
// Viewer PDF trong app:
//   - Download từ URL → lưu temp → render bằng flutter_pdfview
//   - Hiển thị "Trang X / Y" + thanh progress loading
//   - Nút: mở app ngoài, đóng
//   - Error state với retry

// import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../utils/file_opener.dart';

class PdfViewerScreen extends StatefulWidget {
  final OpenableFile file;

  const PdfViewerScreen({super.key, required this.file});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  // Trạng thái download
  _LoadState _loadState = _LoadState.downloading;
  double _downloadProgress = 0;
  String? _errorMessage;
  String? _localPath;

  // Trạng thái PDF
  PDFViewController? _pdfController;
  int _currentPage = 0;
  int _totalPages = 0;
  bool _pdfReady = false;

  @override
  void initState() {
    super.initState();
    _downloadPdf();
  }

  Future<void> _downloadPdf() async {
    setState(() {
      _loadState = _LoadState.downloading;
      _downloadProgress = 0;
      _errorMessage = null;
    });

    try {
      final dir = await getTemporaryDirectory();
      final savePath = path.join(
        dir.path,
        '${DateTime.now().millisecondsSinceEpoch}_${widget.file.fileName}',
      );

      await Dio().download(
        widget.file.fileUrl,
        savePath,
        onReceiveProgress: (recv, total) {
          if (total > 0 && mounted) {
            setState(() => _downloadProgress = recv / total);
          }
        },
      );

      setState(() {
        _localPath = savePath;
        _loadState = _LoadState.rendering;
      });
    } catch (e) {
      setState(() {
        _loadState = _LoadState.error;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _openExternal() async {
    if (_localPath == null) return;
    final result = await OpenFilex.open(_localPath!);
    if (result.type != ResultType.done && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể mở: ${result.message}')),
      );
    }
  }

  void _goToPage(int delta) {
    if (_pdfController == null) return;
    final target = (_currentPage + delta).clamp(0, _totalPages - 1);
    _pdfController!.setPage(target);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.file.fileName,
              style: const TextStyle(fontSize: 14, color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
            if (_pdfReady && _totalPages > 0)
              Text(
                'Trang ${_currentPage + 1} / $_totalPages',
                style: const TextStyle(fontSize: 11, color: Colors.white60),
              ),
          ],
        ),
        actions: [
          if (_loadState == _LoadState.rendering || _pdfReady)
            IconButton(
              icon: const Icon(Icons.open_in_new),
              tooltip: 'Mở bằng app khác',
              onPressed: _openExternal,
            ),
        ],
      ),
      body: _buildBody(),
      // Navigation bar trang (chỉ hiện khi PDF đã load)
      bottomNavigationBar: _pdfReady && _totalPages > 1
          ? _PageNavBar(
              currentPage: _currentPage,
              totalPages: _totalPages,
              onPrev: () => _goToPage(-1),
              onNext: () => _goToPage(1),
            )
          : null,
    );
  }

  Widget _buildBody() {
    switch (_loadState) {
      case _LoadState.downloading:
        return _DownloadingView(progress: _downloadProgress);

      case _LoadState.error:
        return _ErrorView(
          message: _errorMessage ?? 'Lỗi không xác định',
          onRetry: _downloadPdf,
        );

      case _LoadState.rendering:
        return Stack(
          children: [
            if (_localPath != null)
              PDFView(
                filePath: _localPath!,
                enableSwipe: true,
                swipeHorizontal: false,
                autoSpacing: true,
                pageFling: true,
                pageSnap: true,
                defaultPage: _currentPage,
                fitPolicy: FitPolicy.BOTH,
                onRender: (pages) {
                  if (mounted) {
                    setState(() {
                      _totalPages = pages ?? 0;
                      _pdfReady = true;
                      _loadState = _LoadState.rendering;
                    });
                  }
                },
                onViewCreated: (controller) {
                  _pdfController = controller;
                },
                onPageChanged: (page, _) {
                  if (mounted) setState(() => _currentPage = page ?? 0);
                },
                onError: (e) {
                  if (mounted) {
                    setState(() {
                      _loadState = _LoadState.error;
                      _errorMessage = e.toString();
                    });
                  }
                },
              ),
            // Overlay loading khi PDF chưa render xong
            if (!_pdfReady)
              Container(
                color: Colors.grey.shade900,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white54),
                      SizedBox(height: 16),
                      Text(
                        'Đang mở PDF...',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
    }
  }
}

// ─── States ───────────────────────────────────────────────────────────────────

enum _LoadState { downloading, rendering, error }

// ─── DownloadingView ──────────────────────────────────────────────────────────

class _DownloadingView extends StatelessWidget {
  final double progress;
  const _DownloadingView({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.picture_as_pdf_outlined,
              size: 64,
              color: Colors.white24,
            ),
            const SizedBox(height: 24),
            const Text(
              'Đang tải PDF...',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: progress > 0 ? progress : null,
              backgroundColor: Colors.white12,
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text(
              progress > 0
                  ? '${(progress * 100).toStringAsFixed(0)}%'
                  : 'Đang kết nối...',
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── ErrorView ────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white60),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
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

// ─── PageNavBar ───────────────────────────────────────────────────────────────

class _PageNavBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _PageNavBar({
    required this.currentPage,
    required this.totalPages,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade900,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.white),
              onPressed: currentPage > 0 ? onPrev : null,
            ),
            Text(
              '${currentPage + 1} / $totalPages',
              style: const TextStyle(color: Colors.white70),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: Colors.white),
              onPressed: currentPage < totalPages - 1 ? onNext : null,
            ),
          ],
        ),
      ),
    );
  }
}
