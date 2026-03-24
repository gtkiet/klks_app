// file: lib/core/widgets/inputs/app_date_field.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'app_input_field.dart';

class AppDateField extends StatelessWidget {
  final DateTime? value;
  final VoidCallback onTap;

  const AppDateField({
    super.key,
    this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final text =
        value != null ? DateFormat('dd/MM/yyyy').format(value!) : '';

    return AppInputField(
      hint: 'Select date',
      readOnly: true,
      onTap: onTap,
      suffix: const Icon(Icons.calendar_today),
      controller: TextEditingController(text: text),
    );
  }
}