// lib/features/dich_vu/widgets/common_widgets.dart

import 'package:flutter/material.dart';

// ── ErrorStateWidget ──────────────────────────────────────────────────────────

/// Hiển thị trạng thái lỗi: icon + message + nút Thử lại.
/// Dùng cho cả full-screen error lẫn inline error trong list.
class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorStateWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

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
            Text(message, textAlign: TextAlign.center),
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

// ── EmptyStateWidget ──────────────────────────────────────────────────────────

/// Hiển thị trạng thái rỗng: icon + message tuỳ chỉnh.
class EmptyStateWidget extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── LoadMoreIndicator ─────────────────────────────────────────────────────────

/// Spinner nhỏ ở cuối ListView khi đang load thêm trang.
class LoadMoreIndicator extends StatelessWidget {
  const LoadMoreIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

// ── PagingBanner ──────────────────────────────────────────────────────────────

/// Banner hiển thị tổng số item + trang hiện tại ở đầu list.
class PagingBanner extends StatelessWidget {
  final int totalItems;
  final int pageNumber;
  final String itemLabel;

  const PagingBanner({
    super.key,
    required this.totalItems,
    required this.pageNumber,
    this.itemLabel = 'kết quả',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.blue.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Text(
        'Tổng: $totalItems $itemLabel  •  Trang $pageNumber',
        style: const TextStyle(fontSize: 13, color: Colors.blue),
      ),
    );
  }
}
