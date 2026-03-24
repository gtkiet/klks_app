// core/widgets/display/app_card.dart

import 'package:flutter/material.dart';
import '../../extensions/context_ext.dart';
import '../../theme/app_constants.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius:
            BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(color: colors.outline),
      ),
      child: child,
    );
  }
}