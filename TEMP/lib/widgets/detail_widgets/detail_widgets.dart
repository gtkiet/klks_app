// lib/widgets/detail_widgets/detail_widgets.dart

import 'package:flutter/material.dart';

/// ────────────── DETAIL ROW MODEL ──────────────
class DetailRow {
  final String label;
  final String value;
  final IconData? icon;

  const DetailRow({required this.label, required this.value, this.icon});
}

/// ────────────── DETAIL CARD ──────────────
class DetailCard extends StatelessWidget {
  final String title;
  final List<DetailRow> rows;
  final VoidCallback? onEdit;

  const DetailCard({
    super.key,
    required this.title,
    required this.rows,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827))),
              if (onEdit != null)
                IconButton(
                  icon: const Icon(Icons.edit_rounded, color: Colors.blueAccent),
                  onPressed: onEdit,
                ),
            ],
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),

          /// ROWS
          ...rows.map((row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (row.icon != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Icon(row.icon, color: Colors.blueAccent, size: 20),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            row.label,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            row.value,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ))
        ],
      ),
    );
  }
}

/// ────────────── HORIZONTAL DETAIL CARD ──────────────
class HorizontalDetailCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? imageUrl;
  final VoidCallback? onTap;

  const HorizontalDetailCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(14)),
                child: Image.network(
                  imageUrl!,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(subtitle,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
            ),
          ],
        ),
      ),
    );
  }
}

/// ────────────── TAGS DETAIL ROW ──────────────
class TagsDetailCard extends StatelessWidget {
  final String title;
  final List<String> tags;

  const TagsDetailCard({super.key, required this.title, required this.tags});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: tags
                .map((tag) => Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF2563EB)),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}