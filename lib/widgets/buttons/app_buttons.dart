import 'package:flutter/material.dart';
import '../styles/widget_styles.dart';

/// ────────────── MAIN BUTTONS ──────────────
class MainButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;
  final Color backgroundColor;
  final Color foregroundColor;

  const MainButton({
    super.key,
    required this.onPressed,
    required this.label,
    required this.isLoading,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
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
    return MainButton(
      onPressed: onPressed,
      label: label,
      isLoading: isLoading,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
    );
  }
}

class EditButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;
  final Color backgroundColor;
  final Color foregroundColor;

  const EditButton({
    super.key,
    required this.onPressed,
    this.label = 'Chỉnh sửa',
    this.isLoading = false,
    this.backgroundColor = const Color(0xFF10B981),
    this.foregroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return MainButton(
      onPressed: onPressed,
      label: label,
      isLoading: isLoading,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
    );
  }
}

class CancelButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;
  final Color backgroundColor;
  final Color foregroundColor;

  const CancelButton({
    super.key,
    required this.onPressed,
    this.label = 'Hủy',
    this.isLoading = false,
    this.backgroundColor = const Color(0xFF6B7280),
    this.foregroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return MainButton(
      onPressed: onPressed,
      label: label,
      isLoading: isLoading,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
    );
  }
}

class LogoutButton extends StatelessWidget {
  final VoidCallback onTap;
  const LogoutButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: const [
                Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 22),
                SizedBox(width: 12),
                Text(
                  'Đăng xuất',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
