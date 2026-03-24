// File: lib/widgets/buttons/buttons.dart

import 'package:flutter/material.dart';

/// ────────────── COMMON BUTTON STYLE ──────────────
const double kButtonHeight = 52;
const double kButtonBorderRadius = 14.0;
const TextStyle kButtonTextStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w700,
  letterSpacing: 0.3,
);

ButtonStyle kElevatedButtonStyle({
  required Color backgroundColor,
  required Color foregroundColor,
}) =>
    ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kButtonBorderRadius),
      ),
    );

/// ────────────── PRIMARY BUTTON / SUBMIT ──────────────
class PrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;
  final Color backgroundColor;
  final Color foregroundColor;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    this.label = 'Xác nhận',
    this.isLoading = false,
    this.backgroundColor = const Color(0xFF2563EB),
    this.foregroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kButtonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: kElevatedButtonStyle(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(label, style: kButtonTextStyle),
      ),
    );
  }
}

/// ────────────── SECONDARY BUTTON / CANCEL ──────────────
class SecondaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;
  final Color backgroundColor;

  const SecondaryButton({
    super.key,
    required this.onPressed,
    this.label = 'Hủy',
    this.isLoading = false,
    this.backgroundColor = const Color(0xFF6B7280),
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      onPressed: onPressed,
      label: label,
      isLoading: isLoading,
      backgroundColor: backgroundColor,
      foregroundColor: Colors.white,
    );
  }
}

/// ────────────── SUCCESS BUTTON / EDIT ──────────────
class SuccessButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;

  const SuccessButton({
    super.key,
    required this.onPressed,
    this.label = 'Chỉnh sửa',
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      onPressed: onPressed,
      label: label,
      isLoading: isLoading,
      backgroundColor: const Color(0xFF10B981),
      foregroundColor: Colors.white,
    );
  }
}

/// ────────────── DANGER BUTTON ──────────────
class DangerButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;

  const DangerButton({
    super.key,
    required this.onPressed,
    this.label = 'Xóa',
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      onPressed: onPressed,
      label: label,
      isLoading: isLoading,
      backgroundColor: const Color(0xFFEF4444),
      foregroundColor: Colors.white,
    );
  }
}

/// ────────────── GHOST / OUTLINE BUTTON ──────────────
class GhostButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final Color borderColor;
  final Color textColor;

  const GhostButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.borderColor = const Color(0xFF2563EB),
    this.textColor = const Color(0xFF2563EB),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kButtonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: borderColor, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kButtonBorderRadius),
          ),
        ),
        child: Text(label, style: kButtonTextStyle.copyWith(color: textColor)),
      ),
    );
  }
}

/// ────────────── ICON + TEXT BUTTON ──────────────
class IconTextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;

  const IconTextButton({
    super.key,
    required this.onPressed,
    required this.label,
    required this.icon,
    this.backgroundColor = const Color(0xFF2563EB),
    this.foregroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kButtonHeight,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label, style: kButtonTextStyle),
        style: kElevatedButtonStyle(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
        ),
      ),
    );
  }
}

/// ────────────── FLOATING ACTION BUTTON CUSTOM ──────────────
class FABCustom extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final double size;

  const FABCustom({
    super.key,
    required this.onPressed,
    required this.icon,
    this.backgroundColor = const Color(0xFF2563EB),
    this.iconColor = Colors.white,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: backgroundColor,
        foregroundColor: iconColor,
        child: Icon(icon),
      ),
    );
  }
}