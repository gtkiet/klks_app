// lib/core/widgets/loading/app_loading.dart

import 'package:flutter/material.dart';

/// AppLoading
///
/// Usage:
/// ```dart
/// AppLoading()
/// ```
///
/// Notes:
/// - Use for full screen loading
/// - Can be reused inside dialogs, overlays
class AppLoading extends StatelessWidget {
  final double size;

  const AppLoading({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(),
      ),
    );
  }
}
