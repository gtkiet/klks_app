// lib/core/widgets/display/app_text.dart

import 'package:flutter/material.dart';
import '../../extensions/context_ext.dart';

/// Các kiểu text nhanh: title, body, caption
enum AppTextType { title, body, caption }

class AppText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? align;
  final AppTextType type;

  const AppText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.align,
    this.type = AppTextType.body,
  });

  /// Factory constructors để gọi nhanh
  const AppText.title(
    this.text, {
    super.key,
    this.style,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.align,
  }) : type = AppTextType.title;

  const AppText.body(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.align,
  }) : type = AppTextType.body;

  const AppText.caption(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.align,
  }) : type = AppTextType.caption;

  @override
  Widget build(BuildContext context) {
    final TextStyle baseStyle;

    switch (type) {
      case AppTextType.title:
        baseStyle = context.textTheme.headlineMedium!;
        break;
      case AppTextType.caption:
        baseStyle = context.textTheme.bodySmall!;
        break;
      default:
        baseStyle = context.textTheme.bodyMedium!;
    }

    return Text(
      text,
      style: style ?? baseStyle,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: align,
    );
  }
}
