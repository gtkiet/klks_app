import 'package:flutter/material.dart';

/// ────────────── SUBMIT BUTTON ──────────────
class SubmitButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;
  final Color backgroundColor;
  final Color foregroundColor;

  const SubmitButton({
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
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
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
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }
}

/// ────────────── LOGOUT BUTTON ──────────────
class LogoutButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const LogoutButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SubmitButton(
      onPressed: onPressed,
      label: 'Đăng xuất',
      isLoading: isLoading,
      backgroundColor: const Color(0xFFEF4444), // màu đỏ
      foregroundColor: Colors.white,
    );
  }
}

/// ────────────── EDIT BUTTON ──────────────
class EditButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const EditButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SubmitButton(
      onPressed: onPressed,
      label: 'Chỉnh sửa',
      isLoading: isLoading,
      backgroundColor: const Color(0xFF10B981), // màu xanh lá
      foregroundColor: Colors.white,
    );
  }
}

/// ────────────── CANCEL BUTTON ──────────────
class CancelButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const CancelButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SubmitButton(
      onPressed: onPressed,
      label: 'Hủy',
      isLoading: isLoading,
      backgroundColor: const Color(0xFF6B7280), // màu xám
      foregroundColor: Colors.white,
    );
  }
}
