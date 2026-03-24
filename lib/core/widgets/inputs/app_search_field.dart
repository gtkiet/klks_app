// file: lib/core/widgets/inputs/app_search_field.dart

import 'package:flutter/material.dart';
import 'app_input_field.dart';

class AppSearchField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onClear;

  const AppSearchField({
    super.key,
    required this.controller,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (_, _, _) {
        return AppInputField(
          controller: controller,
          hint: 'Search...',
          prefix: const Icon(Icons.search),
          suffix: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    controller.clear();
                    onClear?.call();
                  },
                )
              : null,
        );
      },
    );
  }
}