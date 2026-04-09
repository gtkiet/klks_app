import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';
import '../tokens/spacing.dart';
import '../components/buttons/app_button.dart';
import '../components/text_fields/app_text_field.dart';
import '../components/cards/app_card.dart';
import '../components/app_bar/app_scaffold.dart';
import '../components/app_bar/app_top_bar.dart';
import '../components/feedback/app_feedback.dart';

/// PKK Resident - Design System Demo Screen
///
/// Visual showcase of all design tokens and components.
/// Use this screen to verify the design system is set up correctly.
///
/// Add to your routes for development:
/// ```dart
/// '/design-demo': (_) => const DesignDemoScreen(),
/// ```
class DesignDemoScreen extends StatefulWidget {
  const DesignDemoScreen({super.key});

  @override
  State<DesignDemoScreen> createState() => _DesignDemoScreenState();
}

class _DesignDemoScreenState extends State<DesignDemoScreen> {
  bool _isLoading = false;
  final _textController = TextEditingController();
  final _pwController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    _pwController.dispose();
    super.dispose();
  }

  void _simulateLoading() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Design System',
      appBar: AppTopBar(
        title: 'Demo',
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.insetAll16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Color Palette ───────────────────────────────────────────
            _SectionHeader('1. Color Palette'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ColorChip('Primary', AppColors.primary),
                _ColorChip('Secondary', AppColors.secondary),
                _ColorChip('Success', AppColors.success),
                _ColorChip('Warning', AppColors.warning),
                _ColorChip('Error', AppColors.error),
                _ColorChip(
                  'Surface',
                  AppColors.surface,
                  textColor: AppColors.textPrimary,
                ),
                _ColorChip(
                  'Background',
                  AppColors.background,
                  textColor: AppColors.textPrimary,
                ),
                _ColorChip('Text Primary', AppColors.textPrimary),
              ],
            ),

            const SizedBox(height: 32),

            // ── Typography ──────────────────────────────────────────────
            _SectionHeader('2. Typography'),
            const SizedBox(height: 12),
            const _TypographyShowcase(),

            const SizedBox(height: 32),

            // ── Buttons ─────────────────────────────────────────────────
            _SectionHeader('3. Buttons'),
            const SizedBox(height: 12),
            AppButton(label: 'Primary Button', onPressed: _simulateLoading),
            const SizedBox(height: 8),
            AppButton(
              label: 'Secondary Button',
              variant: AppButtonVariant.secondary,
              onPressed: () {},
            ),
            const SizedBox(height: 8),
            AppButton(
              label: 'Outline Button',
              variant: AppButtonVariant.outline,
              onPressed: () {},
            ),
            const SizedBox(height: 8),
            AppButton(label: 'Disabled Button', onPressed: null),
            const SizedBox(height: 8),
            AppButton(
              label: 'Đang xử lý...',
              isLoading: _isLoading,
              onPressed: null,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                AppButton(
                  label: 'Cancel',
                  variant: AppButtonVariant.secondary,
                  expanded: false,
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
                AppButton(label: 'Proceed', expanded: false, onPressed: () {}),
              ],
            ),

            const SizedBox(height: 32),

            // ── Text Fields ─────────────────────────────────────────────
            _SectionHeader('4. Input Fields'),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Full Name',
              hint: 'Enter full name',
              controller: _textController,
            ),
            const SizedBox(height: 12),
            const AppTextField(
              label: 'Active (Focused)',
              hint: 'Active search...',
              autofocus: false,
            ),
            const SizedBox(height: 12),
            AppTextField.password(label: 'Password', controller: _pwController),
            const SizedBox(height: 12),
            const AppTextField(
              label: 'Error State',
              hint: 'Enter value',
              errorText: 'Invalid password format',
            ),
            const SizedBox(height: 12),
            const AppTextField.search(hint: 'Search services...'),

            const SizedBox(height: 32),

            // ── Cards ────────────────────────────────────────────────────
            _SectionHeader('5. Cards & Containers'),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text('Standard Info Card', style: AppTypography.subhead),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Used for static information and general announcements within the app.',
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            AppCard.utility(
              color: AppColors.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Utility Status',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textOnPrimary.withAlpha(180),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Electricity',
                    style: AppTypography.headline.copyWith(
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 0.75,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '75% of monthly budget',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textOnPrimary.withAlpha(200),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            AppServiceCard(
              icon: Icons.receipt_long_outlined,
              title: 'Payment History',
              subtitle: 'View all transactions',
              onTap: () {},
            ),
            const SizedBox(height: 8),
            AppServiceCard(
              icon: Icons.help_outline,
              title: 'Help Center',
              subtitle: 'Contact management',
              onTap: () {},
            ),

            const SizedBox(height: 32),

            // ── Badges ───────────────────────────────────────────────────
            _SectionHeader('6. Status Badges'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                AppStatusBadge(
                  label: 'Completed',
                  variant: AppBadgeVariant.success,
                ),
                AppStatusBadge(
                  label: 'Pending',
                  variant: AppBadgeVariant.warning,
                ),
                AppStatusBadge(
                  label: 'High Priority',
                  variant: AppBadgeVariant.error,
                ),
                AppStatusBadge(label: 'Info', variant: AppBadgeVariant.info),
              ],
            ),

            const SizedBox(height: 32),

            // ── Dialog ───────────────────────────────────────────────────
            _SectionHeader('7. Confirm Dialog'),
            const SizedBox(height: 12),
            AppButton(
              label: 'Show Confirm Dialog',
              variant: AppButtonVariant.outline,
              onPressed: () async {
                final result = await AppConfirmDialog.show(
                  context,
                  title: 'Confirm Action?',
                  message:
                      'This action cannot be undone. Are you sure you want to proceed with the cancellation?',
                  confirmLabel: 'Proceed',
                  cancelLabel: 'Cancel',
                );
                if (result == true && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Action confirmed!')),
                  );
                }
              },
            ),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

// ─── Internal helpers ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTypography.headline.copyWith(color: AppColors.textPrimary),
    );
  }
}

class _ColorChip extends StatelessWidget {
  const _ColorChip(
    this.label,
    this.color, {
    this.textColor = AppColors.textOnPrimary,
  });
  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 64,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border.withAlpha(80)),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: AppTypography.captionSmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TypographyShowcase extends StatelessWidget {
  const _TypographyShowcase();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Display 30px Bold', style: AppTypography.display),
        const SizedBox(height: 8),
        Text('Headline 18px Bold', style: AppTypography.headline),
        const SizedBox(height: 8),
        Text('Subhead 14px SemiBold', style: AppTypography.subhead),
        const SizedBox(height: 8),
        Text(
          'Body 14px Regular — Standard content and descriptions.',
          style: AppTypography.body,
        ),
        const SizedBox(height: 8),
        Text(
          'Caption 12px Medium — Timestamps and metadata.',
          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
