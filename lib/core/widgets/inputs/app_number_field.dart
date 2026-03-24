// file: lib/core/widgets/inputs/app_number_field.dart

import 'package:flutter/material.dart';
import 'app_input_field.dart';

class AppNumberField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;

  const AppNumberField({
    super.key,
    required this.controller,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return AppInputField(
      controller: controller,
      label: label,
      hint: 'Enter number',
      keyboardType: TextInputType.number,
    );
  }
}