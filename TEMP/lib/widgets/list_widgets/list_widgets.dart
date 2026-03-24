// File: lib/widgets/list_widgets/list_widgets.dart

import 'package:flutter/material.dart';

/// ────────────── MODEL ──────────────
class ListItem {
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final IconData? icon;
  final String? status;
  final VoidCallback? onTap;

  const ListItem({
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.icon,
    this.status,
    this.onTap,
  });
}

/// ────────────── LIST ITEM CARD ──────────────
class ListItemCard extends StatelessWidget {
  final ListItem item;
  final double imageSize;

  const ListItemCard({super.key, required this.item, this.imageSize = 50});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            if (item.imageUrl != null)
              Container(
                width: imageSize,
                height: imageSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: NetworkImage(item.imageUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else if (item.icon != null)
              Container(
                width: imageSize,
                height: imageSize,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  item.icon,
                  size: imageSize * 0.6,
                  color: Colors.blueAccent,
                ),
              )
            else
              SizedBox(width: imageSize, height: imageSize),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  if (item.subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        item.subtitle!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            if (item.status != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.yellow[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.status!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF92400E),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// ────────────── SIMPLE LIST TILE ──────────────
class SimpleListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final VoidCallback? onTap;

  const SimpleListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: leadingIcon != null
          ? Icon(leadingIcon, color: Colors.blueAccent)
          : null,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFF111827),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            )
          : null,
      trailing: const Icon(
        Icons.keyboard_arrow_right_rounded,
        color: Color(0xFF6B7280),
      ),
    );
  }
}

/// ────────────── RATING WIDGET ──────────────
class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final Color color;

  const StarRating({
    super.key,
    required this.rating,
    this.size = 16,
    this.color = Colors.amber,
  });

  @override
  Widget build(BuildContext context) {
    final fullStars = rating.floor();
    final halfStar = rating - fullStars >= 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return Icon(Icons.star, color: color, size: size);
        } else if (index == fullStars && halfStar) {
          return Icon(Icons.star_half, color: color, size: size);
        } else {
          return Icon(Icons.star_border, color: color, size: size);
        }
      }),
    );
  }
}

/// ────────────── ITEM CARD WITH ACTIONS ──────────────
class ListItemActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onPrimary;
  final String primaryLabel;
  final VoidCallback? onSecondary;
  final String? secondaryLabel;

  const ListItemActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onPrimary,
    required this.primaryLabel,
    this.onSecondary,
    this.secondaryLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton(
                onPressed: onPrimary,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: Text(primaryLabel),
              ),
              const SizedBox(width: 8),
              if (onSecondary != null && secondaryLabel != null)
                OutlinedButton(
                  onPressed: onSecondary,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(secondaryLabel!),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ────────────── ITEM CARD WITH TAGS / BADGES ──────────────
class ListItemTagCard extends StatelessWidget {
  final String title;
  final List<String> tags;

  const ListItemTagCard({super.key, required this.title, required this.tags});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            children: tags
                .map(
                  (tag) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

/// ────────────── HORIZONTAL SCROLL CARD ──────────────
class HorizontalCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? imageUrl;
  final VoidCallback? onTap;

  const HorizontalCard({
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
        width: 180,
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
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
                child: Image.network(
                  imageUrl!,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
