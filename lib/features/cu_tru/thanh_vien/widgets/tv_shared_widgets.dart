// lib/features/cu_tru/thanh_vien/widgets/tv_shared_widgets.dart
//
// Shared widgets dùng chung trong toàn bộ feature thanh_vien.
// Import file này thay vì định nghĩa lại ở từng screen.

import 'package:flutter/material.dart';

import '../../../../core/errors/errors.dart';
import '../models/thanh_vien_cu_tru_model.dart';

// =============================================================================
// DATE FORMATTING
// =============================================================================

/// Format DateTime → 'dd/MM/yyyy'.
/// Dùng: context.fmtDate(d) hoặc fmtDate(d) nếu import top-level.
String tvFmtDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/'
    '${d.month.toString().padLeft(2, '0')}/'
    '${d.year}';

extension TvDateTimeExt on DateTime {
  String get tvFormatted => tvFmtDate(this);
}

// =============================================================================
// LOADING / ERROR LAYOUT
// =============================================================================

/// Full-screen loading + error + retry pattern.
/// Dùng trong body của StatefulWidget thay cho boilerplate lặp lại.
///
/// ```dart
/// if (_isLoading || _error != null) {
///   return TvAsyncLayout(
///     isLoading: _isLoading,
///     error: _error,
///     onRetry: _loadData,
///   );
/// }
/// ```
class TvAsyncLayout extends StatelessWidget {
  final bool isLoading;
  final AppException? error;
  final VoidCallback? onRetry;

  /// Widget hiển thị khi không loading, không lỗi nhưng data rỗng.
  final Widget? empty;

  const TvAsyncLayout({
    super.key,
    required this.isLoading,
    this.error,
    this.onRetry,
    this.empty,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppErrorWidget(error: error!),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ],
        ),
      );
    }
    return empty ?? const SizedBox.shrink();
  }
}

// =============================================================================
// SECTION CARD
// =============================================================================

/// Card tiêu đề + danh sách children, dùng trong detail screens.
class TvSectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  const TvSectionCard({
    super.key,
    required this.title,
    required this.children,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// INFO ROW
// =============================================================================

/// Label + value row dùng trong detail card.
/// [labelWidth] mặc định 120, có thể override.
class TvInfoRow extends StatelessWidget {
  final String label;
  final String value;

  /// Nếu true: value hiển thị màu đỏ + bold (dùng cho lý do từ chối...).
  final bool highlight;

  /// Độ rộng cột label. Mặc định 120.
  final double labelWidth;

  const TvInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.highlight = false,
    this.labelWidth = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: highlight ? Colors.red.shade700 : null,
                fontWeight: highlight ? FontWeight.w600 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// MEMBER AVATAR
// =============================================================================

/// CircleAvatar hiển thị ảnh đại diện hoặc chữ cái đầu.
class TvMemberAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double radius;
  final double? fontSize;

  const TvMemberAvatar({
    super.key,
    required this.imageUrl,
    required this.name,
    this.radius = 24,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return CircleAvatar(
      radius: radius,
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
      child: imageUrl == null
          ? Text(
              initial,
              style: fontSize != null ? TextStyle(fontSize: fontSize) : null,
            )
          : null,
    );
  }
}

// =============================================================================
// MEMBER READONLY CARD
// =============================================================================

/// Card thành viên readonly — hiển thị ở đầu form tạo/sửa/xóa yêu cầu.
/// [badgeLabel] + [badgeColor] xác định loại yêu cầu (Sửa / Xóa).
class TvMemberReadonlyCard extends StatelessWidget {
  final ThanhVienCuTruModel thanhVien;

  /// Địa chỉ căn hộ đầy đủ (VD: "Toà A - Tầng 3 - A301").
  final String diaChiCanHo;

  /// Text badge loại yêu cầu.
  final String badgeLabel;

  /// Màu nền badge (mặc định orange cho Sửa).
  final Color badgeColor;

  const TvMemberReadonlyCard({
    super.key,
    required this.thanhVien,
    required this.diaChiCanHo,
    required this.badgeLabel,
    this.badgeColor = Colors.orange,
  });

  @override
  Widget build(BuildContext context) {
    final badgeBg = badgeColor == Colors.orange
        ? Colors.orange.shade50
        : Colors.red.shade50;
    final badgeFg = badgeColor == Colors.orange
        ? Colors.orange.shade800
        : Colors.red.shade800;

    return Card(
      margin: EdgeInsets.zero,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            TvMemberAvatar(
              imageUrl: thanhVien.anhDaiDienUrl,
              name: thanhVien.fullName,
              radius: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    thanhVien.fullName,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    '${thanhVien.loaiQuanHeTen} · $diaChiCanHo',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badgeLabel,
                style: TextStyle(
                  fontSize: 12,
                  color: badgeFg,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// STATUS BANNER
// =============================================================================

/// Banner trạng thái — dùng trong YeuCauDetailScreen.
class TvStatusBanner extends StatelessWidget {
  final int trangThaiId;
  final String tenTrangThai;

  const TvStatusBanner({
    super.key,
    required this.trangThaiId,
    required this.tenTrangThai,
  });

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = _resolve(trangThaiId);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: fg),
          const SizedBox(width: 10),
          Text(
            tenTrangThai,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  (Color bg, Color fg, IconData icon) _resolve(int id) => switch (id) {
    4 => (Colors.grey.shade100, Colors.grey.shade700, Icons.save_outlined),
    1 => (Colors.orange.shade50, Colors.orange.shade800, Icons.hourglass_top),
    2 => (
      Colors.green.shade50,
      Colors.green.shade800,
      Icons.check_circle_outline,
    ),
    3 => (Colors.red.shade50, Colors.red.shade800, Icons.cancel_outlined),
    _ => (Colors.blue.shade50, Colors.blue.shade800, Icons.info_outline),
  };
}

// =============================================================================
// TRANG THAI COLOR HELPER
// =============================================================================

/// Trả về (bgColor, textColor) theo trangThaiId — dùng trong list card.
(Color bg, Color text) tvTrangThaiColor(int id) => switch (id) {
  4 => (Colors.grey.shade100, Colors.grey.shade600),
  1 => (Colors.orange.shade50, Colors.orange.shade800),
  2 => (Colors.green.shade50, Colors.green.shade800),
  3 => (Colors.red.shade50, Colors.red.shade800),
  _ => (Colors.blue.shade50, Colors.blue.shade800),
};

/// Icon theo loại yêu cầu — dùng trong list card.
IconData tvLoaiYeuCauIcon(int id) => switch (id) {
  1 => Icons.person_add_outlined,
  2 => Icons.edit_outlined,
  3 => Icons.person_remove_outlined,
  _ => Icons.description_outlined,
};
