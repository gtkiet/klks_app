// File: lib/widgets/placeholder_widgets/placeholder_widgets.dart

import 'package:flutter/material.dart';

/// ────────────── EMPTY STATE WIDGET ──────────────
class EmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final VoidCallback? onAction;
  final String actionLabel;

  const EmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.onAction,
    this.actionLabel = 'Thử lại',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (imageUrl != null)
              Image.network(imageUrl!, height: 120, fit: BoxFit.contain),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            if (onAction != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(actionLabel),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// ────────────── LOADING WIDGET ──────────────
class LoadingState extends StatelessWidget {
  final String? message;

  const LoadingState({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                message!,
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
            ),
        ],
      ),
    );
  }
}

/// ────────────── SIMPLE NOTIFICATION / ALERT ──────────────
class NotificationCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  const NotificationCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.notifications_rounded,
    this.iconColor = Colors.blueAccent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ────────────── BADGE / ALERT ICON ──────────────
class BadgeIcon extends StatelessWidget {
  final int count;
  final Color backgroundColor;
  final Color textColor;

  const BadgeIcon({
    super.key,
    required this.count,
    this.backgroundColor = Colors.redAccent,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count.toString(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}
