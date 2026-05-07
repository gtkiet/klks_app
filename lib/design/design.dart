// PKK Resident - Design System
//
// Single import for the entire design system.
//
// Usage:
// ```dart
// import 'package:pkk_resident/design/design.dart';
// ```
//
// Then use any token or component directly:
// ```dart
// color: AppColors.primary,
// style: AppTypography.headline,
// padding: EdgeInsets.all(AppSpacing.md),
// child: AppButton(label: 'Login', onPressed: _login),
// ```

// ── Tokens ────────────────────────────────────────────────────────────────────
export 'tokens/colors.dart';
export 'tokens/typography.dart';
export 'tokens/spacing.dart';
export 'tokens/radius.dart';
export 'tokens/elevation.dart';

// ── Theme ─────────────────────────────────────────────────────────────────────
export 'theme/app_theme.dart';
export 'theme/app_color_scheme.dart';
export 'theme/app_text_theme.dart';

// ── Foundations ───────────────────────────────────────────────────────────────
export 'foundations/constants.dart';
export 'foundations/extensions.dart';

// ── Components ────────────────────────────────────────────────────────────────
export 'components/buttons/app_button.dart';
export 'components/text_fields/app_text_field.dart';
export 'components/cards/app_card.dart';
export 'components/app_bar/app_top_bar.dart';
export 'components/app_bar/app_scaffold.dart';
export 'components/feedback/app_feedback.dart';

// ── Demo (remove in production builds) ───────────────────────────────────────
// export 'demo/design_demo_screen.dart';