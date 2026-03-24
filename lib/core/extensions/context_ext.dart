// file: lib/core/extensions/context_ext.dart

import 'package:flutter/material.dart';

extension ContextExt on BuildContext {
  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => theme.textTheme;

  ColorScheme get colors => theme.colorScheme;

  Size get screenSize => MediaQuery.of(this).size;

  bool get isDark => theme.brightness == Brightness.dark;
}