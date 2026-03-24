// file: lib/core/widgets/inputs/app_password_field.dart

import 'package:flutter/material.dart';
import 'app_input_field.dart';

class AppPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final String? label;
  final Validator? validator;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;

  /// ✅ Thêm prefix để hiển thị icon đầu field
  final Widget? prefix;

  const AppPasswordField({
    super.key,
    required this.controller,
    this.hint = 'Password',
    this.label,
    this.validator,
    this.textInputAction,
    this.onFieldSubmitted,
    this.prefix,
  });

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    return AppInputField(
      controller: widget.controller,
      hint: widget.hint,
      label: widget.label,
      obscure: obscure,
      validator: widget.validator,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,

      /// chuyển prefix xuống InputField
      prefix: widget.prefix,

      /// icon hiển thị/ẩn mật khẩu
      suffix: IconButton(
        icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
        onPressed: () => setState(() => obscure = !obscure),
      ),
    );
  }
}
