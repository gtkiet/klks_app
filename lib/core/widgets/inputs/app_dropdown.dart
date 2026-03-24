// file: lib/core/widgets/inputs/app_dropdown.dart

import 'package:flutter/material.dart';
import '../../extensions/context_ext.dart';
import '../../theme/app_constants.dart';

class AppDropdown<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final String? label;

  const AppDropdown({
    super.key,
    this.value,
    required this.items,
    required this.onChanged,
    this.label,
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
        DropdownButtonFormField<T>(
          value: value,
          items: items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e.toString()),
                  ))
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: colors.surface,
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.radiusMD),
            ),
          ),
        ),
      ],
    );
  }
}