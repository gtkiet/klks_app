// lib/design/shared/widgets/display/app_avatar.dart

import 'package:flutter/material.dart';
import '../../../constants/constants.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppAvatar
// ─────────────────────────────────────────────────────────────────────────────

/// A circular avatar that shows a network image, falls back to initials,
/// and optionally shows a status badge dot.
///
/// Example:
/// ```dart
/// AppAvatar(
///   imageUrl: user.avatarUrl,
///   name: user.fullName,
///   size: 48,
/// )
/// ```
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = 44.0,
    this.onTap,
    this.showOnlineDot = false,
    this.borderColor,
    this.borderWidth = 0,
  });

  /// Remote image URL. Falls back to initials if null or on error.
  final String? imageUrl;

  /// Used to generate initials when no image is available.
  final String? name;

  final double size;
  final VoidCallback? onTap;

  /// When `true`, renders a green dot in the bottom-right corner.
  final bool showOnlineDot;

  final Color? borderColor;
  final double borderWidth;

  String get _initials {
    if (name == null || name!.trim().isEmpty) return '?';
    final parts = name!.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final dotSize = size * 0.28;

    Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.inputFill,
        border: borderWidth > 0
            ? Border.all(
                color: borderColor ?? AppColors.divider,
                width: borderWidth,
              )
            : null,
      ),
      child: ClipOval(child: _buildImage()),
    );

    if (showOnlineDot) {
      avatar = Stack(
        children: [
          avatar,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 1.5),
              ),
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: avatar);
    }

    return avatar;
  }

  Widget _buildImage() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildInitials(),
        loadingBuilder: (_, child, event) {
          if (event == null) return child;
          return _buildInitials();
        },
      );
    }
    return _buildInitials();
  }

  Widget _buildInitials() {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.12),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: TextStyle(
          fontFamily: 'BeVietnamPro',
          fontSize: size * 0.35,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}