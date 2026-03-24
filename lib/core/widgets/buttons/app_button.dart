// lib/core/widgets/buttons/app_buttons.dart

// core/widgets/buttons/app_button.dart

import 'package:flutter/material.dart';
import '../../extensions/context_ext.dart';
import '../../theme/app_constants.dart';

enum AppButtonType { primary, secondary, outline, text, danger }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool loading;
  final AppButtonType type;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.loading = false,
    this.type = AppButtonType.primary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || loading;

    final colors = context.colors;

    late Color bg;
    late Color fg;
    BorderSide? border;

    switch (type) {
      case AppButtonType.primary:
        bg = colors.primary;
        fg = Colors.white;
        break;
      case AppButtonType.secondary:
        bg = colors.secondary;
        fg = Colors.white;
        break;
      case AppButtonType.outline:
        bg = Colors.transparent;
        fg = colors.primary;
        border = BorderSide(color: colors.primary);
        break;
      case AppButtonType.text:
        bg = Colors.transparent;
        fg = colors.primary;
        break;
      case AppButtonType.danger:
        bg = colors.error;
        fg = Colors.white;
        break;
    }

    return SizedBox(
      width: double.infinity,
      height: AppConstants.buttonHeight,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.radiusMD),
            side: border ?? BorderSide.none,
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(text),
                ],
              ),
      ),
    );
  }
}