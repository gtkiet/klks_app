// lib/features/cu_tru/thanh_vien/widgets/tv_shared_widgets.dart
//
// Shared widgets dùng chung trong toàn bộ feature thanh_vien.

import 'package:flutter/material.dart';

import '../models/thanh_vien_cu_tru_model.dart';

// =============================================================================
// DATE FORMATTING
// =============================================================================

String tvFmtDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/'
    '${d.month.toString().padLeft(2, '0')}/'
    '${d.year}';

extension TvDateTimeExt on DateTime {
  String get tvFormatted => tvFmtDate(this);
}

// =============================================================================
// LOADING LAYOUT
// =============================================================================

/// Full-screen loading pattern.
class TvAsyncLayout extends StatelessWidget {
  final bool isLoading;

  /// Widget hiển thị khi không loading.
  final Widget? empty;

  const TvAsyncLayout({
    super.key,
    required this.isLoading,
    this.empty,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return empty ?? const SizedBox.shrink();
  }
}

// =============================================================================
// SECTION CARD
// =============================================================================

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

class TvInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
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

class TvMemberReadonlyCard extends StatelessWidget {
  final ThanhVienCuTruModel thanhVien;
  final String diaChiCanHo;
  final String badgeLabel;
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

(Color bg, Color text) tvTrangThaiColor(int id) => switch (id) {
  4 => (Colors.grey.shade100, Colors.grey.shade600),
  1 => (Colors.orange.shade50, Colors.orange.shade800),
  2 => (Colors.green.shade50, Colors.green.shade800),
  3 => (Colors.red.shade50, Colors.red.shade800),
  _ => (Colors.blue.shade50, Colors.blue.shade800),
};

IconData tvLoaiYeuCauIcon(int id) => switch (id) {
  1 => Icons.person_add_outlined,
  2 => Icons.edit_outlined,
  3 => Icons.person_remove_outlined,
  _ => Icons.description_outlined,
};