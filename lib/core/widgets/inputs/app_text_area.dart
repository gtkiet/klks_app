// file: lib/core/widgets/inputs/app_text_area.dart

import 'package:flutter/material.dart';
import 'app_input_field.dart';

class AppTextArea extends StatelessWidget {
  final TextEditingController controller;
  final String? label;

  const AppTextArea({
    super.key,
    required this.controller,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return AppInputField(
      controller: controller,
      label: label,
      hint: 'Enter content...',
      maxLines: 5,
    );
  }
}