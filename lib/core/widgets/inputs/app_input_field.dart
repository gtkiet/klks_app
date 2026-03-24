// file: lib/core/widgets/inputs/app_input_field.dart

import 'package:flutter/material.dart';
import '../../extensions/context_ext.dart';
import '../../theme/app_constants.dart';

typedef Validator = String? Function(String?);

class AppInputField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;
  final String? label;
  final bool obscure;
  final Widget? prefix;
  final Widget? suffix;
  final TextInputType keyboardType;
  final int maxLines;
  final Validator? validator;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool enabled;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;

  const AppInputField({
    super.key,
    this.controller,
    this.hint,
    this.label,
    this.obscure = false,
    this.prefix,
    this.suffix,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.enabled = true,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: context.textTheme.bodyMedium),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          maxLines: maxLines,
          readOnly: readOnly,
          enabled: enabled,
          onChanged: onChanged,
          onTap: onTap,
          validator: validator,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          style: context.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefix,
            suffixIcon: suffix,
            filled: true,
            fillColor: colors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              borderSide: BorderSide(color: colors.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              borderSide: BorderSide(color: colors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              borderSide: BorderSide(color: colors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              borderSide: BorderSide(color: colors.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
