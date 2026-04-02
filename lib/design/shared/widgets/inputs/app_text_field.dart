import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../constants/constants.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enum
// ─────────────────────────────────────────────────────────────────────────────

enum AppTextFieldVariant {
  /// Standard data entry — no prefix/suffix adornments.
  text,

  /// Password entry — with eye-toggle to show / hide text.
  password,

  /// Search input — with leading magnifying glass icon.
  search,
}

// ─────────────────────────────────────────────────────────────────────────────
// AppTextField
// ─────────────────────────────────────────────────────────────────────────────

/// Unified input field covering all three variants defined in the design spec:
/// [AppTextFieldVariant.text], [AppTextFieldVariant.password],
/// [AppTextFieldVariant.search].
///
/// States mirrored from spec:
/// - **Default** — light grey fill, no border.
/// - **Focused** — blue border.
/// - **Error** — red border + [errorText] message below.
/// - **Disabled** — reduced opacity, non-interactive.
///
/// Example — standard text:
/// ```dart
/// AppTextField(
///   hint: 'Enter full name',
///   controller: _nameController,
/// )
/// ```
///
/// Example — password:
/// ```dart
/// AppTextField(
///   variant: AppTextFieldVariant.password,
///   hint: 'Password',
///   controller: _passController,
///   errorText: _passError,
/// )
/// ```
///
/// Example — search:
/// ```dart
/// AppTextField(
///   variant: AppTextFieldVariant.search,
///   hint: 'Active search…',
///   onChanged: _onSearch,
/// )
/// ```
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.variant = AppTextFieldVariant.text,
    this.hint,
    this.label,
    this.controller,
    this.focusNode,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.initialValue,
  });

  final AppTextFieldVariant variant;
  final String? hint;
  final String? label;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  /// Non-null value puts the field in error state.
  final String? errorText;

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;

  final bool enabled;
  final bool readOnly;
  final bool autofocus;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;

  final int maxLines;
  final int? minLines;
  final int? maxLength;

  /// Override the leading icon (only for [AppTextFieldVariant.text]).
  final Widget? prefixIcon;

  /// Override the trailing icon (ignored for password — it manages its own).
  final Widget? suffixIcon;

  final String? initialValue;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.variant == AppTextFieldVariant.password;
  }

  // ── Derived helpers ────────────────────────────────────────────────────────
  bool get _isPassword => widget.variant == AppTextFieldVariant.password;
  bool get _isSearch => widget.variant == AppTextFieldVariant.search;

  Widget? get _prefix {
    if (_isSearch) {
      return const Padding(
        padding: EdgeInsetsDirectional.only(start: 4, end: 0),
        child: Icon(Icons.search_rounded, size: 20, color: AppColors.textDisabled),
      );
    }
    return widget.prefixIcon;
  }

  Widget? get _suffix {
    if (_isPassword) {
      return GestureDetector(
        onTap: () => setState(() => _obscure = !_obscure),
        child: Padding(
          padding: const EdgeInsetsDirectional.only(end: 4),
          child: Icon(
            _obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            size: 20,
            color: AppColors.secondary,
          ),
        ),
      );
    }
    return widget.suffixIcon;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Label ────────────────────────────────────────────────────────────
        if (widget.label != null) ...[
          Text(widget.label!, style: AppTextStyles.caption),
          const SizedBox(height: AppSpacing.xs),
        ],

        // ── Field ─────────────────────────────────────────────────────────
        TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          autofocus: widget.autofocus,
          obscureText: _obscure,
          keyboardType: _isPassword
              ? TextInputType.visiblePassword
              : (_isSearch ? TextInputType.text : widget.keyboardType),
          textInputAction: widget.textInputAction,
          inputFormatters: widget.inputFormatters,
          maxLines: _isPassword ? 1 : widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          style: AppTextStyles.body,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle:
                AppTextStyles.body.copyWith(color: AppColors.textDisabled),
            prefixIcon: _prefix,
            suffixIcon: _suffix,
            counterText: '',
            // Error is handled below; we pass null to avoid default error
            // styling overlapping our custom message.
            errorText: null,
            // Override border to show error state
            enabledBorder: widget.errorText != null
                ? OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusInput),
                    borderSide:
                        const BorderSide(color: AppColors.error, width: 1.5),
                  )
                : null,
          ),
        ),

        // ── Error message ────────────────────────────────────────────────────
        if (widget.errorText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Padding(
            padding:
                const EdgeInsetsDirectional.only(start: AppSpacing.xs),
            child: Text(
              widget.errorText!,
              style: AppTextStyles.inputHelper,
            ),
          ),
        ],
      ],
    );
  }
}